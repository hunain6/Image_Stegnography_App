import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String?> savePngBytes(Uint8List bytes) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/stego_${DateTime.now().millisecondsSinceEpoch}.png';
  await File(path).writeAsBytes(bytes);
  return path;
}
