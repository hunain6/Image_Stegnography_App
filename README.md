# 📸 Image Steganography with AES Encryption

A secure Image Steganography system that hides encrypted messages inside images using LSB (Least Significant Bit) technique combined with AES encryption.

The project consists of:
- 📱 Flutter Frontend
- 🐍 Python Flask Backend (API + Encryption + Steganography Engine)

---

## 🚀 Features

- 🔐 AES-256 encryption for messages
- 🖼️ Hide encrypted messages inside images (LSB technique)
- 🔓 Extract hidden messages using password
- 📊 Image capacity calculation before encoding
- 📱 Flutter UI for easy interaction
- 🌐 REST API backend (Flask)
- 🔄 Secure communication via HTTP requests

---

## 🏗️ Project Structure

Image_Stegnography_App/
│
├── backend/ (Flask API)
│ ├── app.py
│ ├── requirements.txt
│
├── frontend/ (Flutter App)
│ ├── lib/
│ ├── pubspec.yaml
│
└── README.md


---

## ⚙️ Backend Setup (Flask API)

### 📌 Install Dependencies

```bash
pip install flask flask-cors pycryptodome opencv-python numpy Pillow

▶️ Run Backend Server

python app.py

🔌 API Endpoints

{
  "status": "ok",
  "service": "StegoServer v1.0"
}

🖼️ Encode Image (Hide Message)
POST /encode

Form Data:

image → file
message → text
password → encryption key

Response:

Returns stego image (PNG)

🔓 Decode Image (Extract Message)
POST /decode

Form Data:

image → stego image
password → encryption key

Response:

{
  "message": "your hidden text"
}


📱 Flutter Frontend Setup
🔗 API Base URL

For Emulator:

http://127.0.0.1:5000

For Physical Device:

http://YOUR_PC_IP:5000
🔐 How It Works
User enters a message and password
Message is encrypted using AES-256
Encrypted text is hidden inside image using LSB technique
Image is generated and returned
To decode:
Extract hidden data from image
Decrypt using the same password
🧪 Tech Stack

Frontend:

Flutter
Dart

Backend:

Python
Flask
OpenCV
NumPy
PyCryptodome
Pillow


⚠️ Important Notes
Use PNG images for best results
Same password required for decoding
Large messages may exceed image capacity
Avoid heavily compressed images (low quality JPGs)


👨‍💻 Author

Hunain Farhat

⭐ Support

If you like this project, give it a star on GitHub ⭐
