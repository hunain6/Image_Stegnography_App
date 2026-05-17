import requests
with open('..\\flutter_app\\web\\favicon.png', 'rb') as f:
    png_data = f.read()
files = {'image': ('favicon.png', png_data, 'image/png')}
resp = requests.post('http://127.0.0.1:5000/capacity', files=files, timeout=10)
print('status', resp.status_code)
print(resp.text)
