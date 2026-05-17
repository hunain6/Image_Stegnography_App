import 'dart:typed_data';

Future<String?> savePngBytes(Uint8List bytes) async {
  // Web cannot write to a local filesystem in the same way.
  // Return null and keep the encoded bytes in memory for preview.
  return null;
}
