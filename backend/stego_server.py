"""
Image Steganography with AES Encryption - Python Backend
Flask REST API serving Flutter frontend
Dependencies: flask, pycryptodome, opencv-python, numpy, Pillow
"""

from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
from Crypto.Hash import SHA256
import numpy as np
import cv2
import base64
import io
import os
import json

app = Flask(__name__)
CORS(app)

# ─────────────────────────────────────────────
#  AES Helpers
# ─────────────────────────────────────────────

def derive_key(password: str) -> bytes:
    """Derive a 32-byte AES key from a human-readable password via SHA-256."""
    h = SHA256.new()
    h.update(password.encode("utf-8"))
    return h.digest()


def aes_encrypt(plaintext: str, password: str) -> str:
    """AES-CBC encrypt → base64-encoded string (IV prepended)."""
    key = derive_key(password)
    cipher = AES.new(key, AES.MODE_CBC)
    ct_bytes = cipher.encrypt(pad(plaintext.encode("utf-8"), AES.block_size))
    iv_ct = cipher.iv + ct_bytes
    return base64.b64encode(iv_ct).decode("utf-8")


def aes_decrypt(b64_ciphertext: str, password: str) -> str:
    """AES-CBC decrypt from base64-encoded string (IV prepended)."""
    key = derive_key(password)
    raw = base64.b64decode(b64_ciphertext)
    iv = raw[:16]
    ct = raw[16:]
    cipher = AES.new(key, AES.MODE_CBC, iv=iv)
    plaintext = unpad(cipher.decrypt(ct), AES.block_size)
    return plaintext.decode("utf-8")


# ─────────────────────────────────────────────
#  LSB Steganography Helpers
# ─────────────────────────────────────────────

DELIMITER = "<<END>>"


def text_to_bits(text: str) -> str:
    """Convert a string to its binary bit representation."""
    bits = ""
    for char in text:
        bits += format(ord(char), "08b")
    return bits


def bits_to_text(bits: str) -> str:
    """Convert binary bit string back to text."""
    chars = []
    for i in range(0, len(bits), 8):
        byte = bits[i:i + 8]
        if len(byte) < 8:
            break
        chars.append(chr(int(byte, 2)))
    return "".join(chars)


def embed_lsb(image_bytes: bytes, secret_text: str) -> bytes:
    """Embed secret_text into image using LSB technique. Returns PNG bytes."""
    # Decode image from bytes
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
    if img is None:
        raise ValueError("Could not decode image.")

    # Ensure 3-channel (RGB); drop alpha if present
    if len(img.shape) == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    elif img.shape[2] == 4:
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)

    message = secret_text + DELIMITER
    bits = text_to_bits(message)

    flat = img.flatten()
    if len(bits) > len(flat):
        raise ValueError(
            f"Message too large for image. "
            f"Need {len(bits)} bits, image has {len(flat)} pixels."
        )

    flat = flat.astype(np.uint8)
    for i, bit in enumerate(bits):
       flat[i] = (flat[i] & 0xFE) | int(bit)

    stego = flat.reshape(img.shape)
    success, buffer = cv2.imencode(".png", stego)
    if not success:
        raise RuntimeError("Failed to encode stego image.")
    return buffer.tobytes()


def extract_lsb(image_bytes: bytes) -> str:
    """Extract hidden text from stego image using LSB technique."""
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
    if img is None:
        raise ValueError("Could not decode image.")

    if len(img.shape) == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    elif img.shape[2] == 4:
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)

    flat = img.flatten().astype(np.uint8)
    max_bits = min(len(flat), 10_000_000)  # cap at 10M pixels
    bits = ""
    chars = []

    for pixel in flat:
        bits += str(pixel & 1)
        if len(bits) == 8:
            char = chr(int(bits, 2))
            chars.append(char)
            bits = ""
            current = "".join(chars)
            if current.endswith(DELIMITER):
                return current[: -len(DELIMITER)]

    raise ValueError("Delimiter not found — image may not contain hidden data.")


# ─────────────────────────────────────────────
#  Flask Routes
# ─────────────────────────────────────────────

@app.route('/')
def home():
    return "StegoServer is running successfully!"

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "StegoServer v1.0"})


@app.route("/encode", methods=["POST"])
def encode():
    """
    Encode endpoint.
    Expects multipart/form-data:
      - image: PNG file
      - message: plaintext string
      - password: AES key (string)
    Returns: stego PNG image (application/octet-stream)
    """
    try:
        if "image" not in request.files:
            return jsonify({"error": "No image file provided."}), 400
        if "message" not in request.form:
            return jsonify({"error": "No message provided."}), 400
        if "password" not in request.form:
            return jsonify({"error": "No password provided."}), 400

        image_file = request.files["image"]
        message = request.form["message"]
        password = request.form["password"]

        if not message.strip():
            return jsonify({"error": "Message cannot be empty."}), 400
        if not password.strip():
            return jsonify({"error": "Password cannot be empty."}), 400

        image_bytes = image_file.read()

        # Step 1: AES-encrypt the message
        encrypted = aes_encrypt(message, password)

        # Step 2: Embed cipher text into image via LSB
        stego_bytes = embed_lsb(image_bytes, encrypted)

        # Return stego image as file
        return send_file(
            io.BytesIO(stego_bytes),
            mimetype="image/png",
            as_attachment=True,
            download_name="stego_image.png",
        )

    except ValueError as ve:
        return jsonify({"error": str(ve)}), 422
    except Exception as e:
        return jsonify({"error": f"Encoding failed: {str(e)}"}), 500


@app.route("/decode", methods=["POST"])
def decode():
    """
    Decode endpoint.
    Expects multipart/form-data:
      - image: stego PNG file
      - password: AES key (string)
    Returns JSON: { "message": "..." }
    """
    try:
        if "image" not in request.files:
            return jsonify({"error": "No image file provided."}), 400
        if "password" not in request.form:
            return jsonify({"error": "No password provided."}), 400

        image_file = request.files["image"]
        password = request.form["password"]

        image_bytes = image_file.read()

        # Step 1: Extract cipher text from image via LSB
        encrypted = extract_lsb(image_bytes)

        # Step 2: AES-decrypt cipher text
        plaintext = aes_decrypt(encrypted, password)

        return jsonify({"message": plaintext})

    except ValueError as ve:
        return jsonify({"error": str(ve)}), 422
    except Exception as e:
        # Likely wrong password → padding error
        return jsonify({"error": "Decryption failed. Wrong password or corrupted image."}), 422


@app.route("/capacity", methods=["POST"])
def capacity():
    """
    Returns max characters embeddable in an image.
    Expects multipart/form-data: image
    """
    try:
        if "image" not in request.files:
            return jsonify({"error": "No image file provided."}), 400

        image_file = request.files["image"]
        nparr = np.frombuffer(image_file.read(), np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
        if img is None:
            return jsonify({"error": "Could not decode image."}), 400

        if len(img.shape) == 2:
            channels = 3
        elif img.shape[2] == 4:
            channels = 3
        else:
            channels = img.shape[2]

        total_pixels = img.shape[0] * img.shape[1] * channels
        max_chars = (total_pixels // 8) - len(DELIMITER) - 50  # safety margin

        return jsonify({
            "max_chars": max(0, max_chars),
            "dimensions": f"{img.shape[1]}x{img.shape[0]}"
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    print("=" * 50)
    print("  StegoServer running on http://127.0.0.1:5000")
    print("=" * 50)
    app.run(debug=True, host="127.0.0.1", port=5000)