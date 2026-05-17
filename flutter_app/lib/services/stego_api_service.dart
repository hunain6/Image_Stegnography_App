import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
/// Wrapper around the Python Flask steganography backend.
class StegoApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://127.0.0.1:5000';
  }

  // Timeout for long image operations
  static const Duration _timeout = Duration(seconds: 60);

  // ──────────────────────────────────────────
  //  Health Check
  // ──────────────────────────────────────────

  /// Ping the backend. Returns true if reachable.
  static Future<bool> isServerRunning() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(_timeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ──────────────────────────────────────────
  //  Encode
  // ──────────────────────────────────────────

  /// Sends [image], [message], and [password] to the backend.
  /// Returns raw PNG bytes of the stego image on success.
  /// Throws [StegoApiException] on failure.
  static Future<List<int>> encodeMessage({
    required Uint8List imageBytes,
    required String message,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/encode');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await _createMultipartImage('image', imageBytes));
    request.fields['message']  = message;
    request.fields['password'] = password;

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return _throwFromResponse(response);
  }

  // ──────────────────────────────────────────
  //  Decode
  // ──────────────────────────────────────────

  /// Sends stego [image] and [password] to backend.
  /// Returns the original plaintext message.
  static Future<String> decodeMessage({
    required Uint8List imageBytes,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/decode');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await _createMultipartImage('image', imageBytes));
    request.fields['password'] = password;

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] as String;
    }
    return _throwFromResponse(response);
  }

  // ──────────────────────────────────────────
  //  Capacity Check
  // ──────────────────────────────────────────

  /// Returns image capacity info: {max_chars, dimensions}
  static Future<Map<String, dynamic>> getCapacity({required Uint8List imageBytes}) async {
    final uri = Uri.parse('$baseUrl/capacity');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await _createMultipartImage('image', imageBytes));

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return _throwFromResponse(response);
  }

  // ──────────────────────────────────────────
  //  Helpers
  // ──────────────────────────────────────────

  static Future<http.MultipartFile> _createMultipartImage(String field, Uint8List imageBytes) async {
    return http.MultipartFile.fromBytes(
      field,
      imageBytes,
      filename: 'image.png',
    );
  }

  static Never _throwFromResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw StegoApiException(data['error']?.toString() ?? 'Unknown server error.');
    } on StegoApiException {
      rethrow;
    } catch (_) {
      throw StegoApiException('Server error (${response.statusCode}).');
    }
  }
}

/// Typed exception for API errors.
class StegoApiException implements Exception {
  final String message;
  const StegoApiException(this.message);

  @override
  String toString() => message;
}