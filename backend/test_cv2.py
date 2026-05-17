import cv2, numpy as np, base64
png_data = base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=')
arr = np.frombuffer(png_data, np.uint8)
img = cv2.imdecode(arr, cv2.IMREAD_UNCHANGED)
print('img', type(img), img)
