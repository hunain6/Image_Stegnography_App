#📸 Image Steganography with AES Encryption

A secure Image Steganography system that hides encrypted messages inside images using LSB (Least Significant Bit) technique combined with AES encryption.

#The project consists of:

📱 Flutter Frontend (User Interface)

🐍 Python Flask Backend (API + Encryption + Steganography Engine)

🚀 Features
🔐 AES-256 encryption for messages

🖼️ Hide encrypted data inside images using LSB technique

🔓 Extract hidden messages securely with password

📊 Image capacity calculation before encoding

📱 Cross-platform Flutter UI

🌐 REST API backend (Flask)

🔄 Secure communication via JSON / multipart requests


🏗️ Project Structure

Image_Stegnography_App/
│
├── backend/ (Flask API)
│   ├── app.py
│   ├── requirements.txt
│
├── frontend/ (Flutter App)
│   ├── lib/
│   ├── pubspec.yaml
│
└── README.md


#Install dependencies:

pip install flask flask-cors pycryptodome opencv-python numpy Pillow

▶️ Run Backend Server

python app.py

#Server runs at:

http://127.0.0.1:5000
🔌 API Endpoints
🟢 Health Check
GET /health

#Response:

{
  "status": "ok",
  "service": "StegoServer v1.0"
}
🖼️ Encode Image (Hide Message)
POST /encode

Form Data:

image → PNG/JPG file
message → text message
password → encryption key

Response:

Returns stego image (stego_image.png)
🔓 Decode Image (Extract Message)
POST /decode

Form Data:

image → stego image
password → encryption key

Response:

{
  "message": "your hidden text"
}
📊 Image Capacity
POST /capacity

Form Data:

image → image file

Response:

{
  "max_chars": 12345,
  "dimensions": "800x600"
}
📱 Flutter Frontend

The Flutter app provides:

Image picker
Message input field
Password-based encryption
Encode/Decode buttons
API communication with Flask backend
🔗 Backend Connection

Update your API base URL in Flutter:

http://127.0.0.1:5000

For real device testing:

http://YOUR_PC_IP:5000

#🔐 How It Works
User enters a message + password
Message is encrypted using AES-256
Encrypted text is hidden inside image using LSB technique
Image is returned to user

#To decode:
Extract LSB data
Decrypt using same password
🧪 Tech Stack

#Frontend:

Flutter
Dart


#Backend:

Python
Flask
OpenCV
NumPy
PyCryptodome
Pillow

#⚠️ Important Notes
Use PNG images for best results
Same password is required for decoding
Large messages may exceed image capacity
Do NOT use compressed images (like heavily compressed JPG)

#👨‍💻 Author

Hunain Farhat

#📜 License

This project is for educational purposes.
