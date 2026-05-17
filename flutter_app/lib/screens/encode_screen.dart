import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/stego_api_service.dart';
import '../widgets/image_drop_zone.dart';
import '../widgets/stego_text_field.dart';
import '../widgets/result_card.dart';

class EncodeScreen extends StatefulWidget {
  const EncodeScreen({super.key});

  @override
  State<EncodeScreen> createState() => _EncodeScreenState();
}

class _EncodeScreenState extends State<EncodeScreen> {
  Uint8List? _selectedImageBytes;
  final _messageCtrl  = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass   = true;

  bool _loading       = false;
  String? _errorMsg;
  String? _savedPath;

  // Capacity info
  int?    _maxChars;
  String? _dimensions;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!await _isPngBytes(bytes)) {
      _setError('Please select a valid PNG image.');
      return;
    }

    setState(() {
      _selectedImageBytes = bytes;
      _errorMsg   = null;
      _savedPath  = null;
      _maxChars   = null;
      _dimensions = null;
    });
    _fetchCapacity(bytes);
  }

  Future<bool> _isPngBytes(Uint8List bytes) async {
    return bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }

  Future<void> _fetchCapacity(Uint8List bytes) async {
    try {
      final info = await StegoApiService.getCapacity(imageBytes: bytes);
      if (mounted) {
        setState(() {
          _maxChars   = info['max_chars'] as int?;
          _dimensions = info['dimensions'] as String?;
        });
      }
    } catch (_) { /* non-critical */ }
  }

  Future<void> _encode() async {
    final message  = _messageCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (_selectedImageBytes == null) {
      _setError('Please select a cover image first.');
      return;
    }
    if (message.isEmpty) {
      _setError('Please enter a secret message.');
      return;
    }
    if (password.isEmpty) {
      _setError('Please enter an encryption password.');
      return;
    }
    if (_maxChars != null && message.length > _maxChars!) {
      _setError('Message too long. Max $_maxChars characters for this image.');
      return;
    }

    setState(() { _loading = true; _errorMsg = null; _savedPath = null; });

    try {
      final pngBytes = await StegoApiService.encodeMessage(
        imageBytes: _selectedImageBytes!,
        message: message,
        password: password,
      );

      // Save to app documents directory
      final dir  = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/stego_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(pngBytes);

      if (mounted) setState(() { _savedPath = path; _loading = false; });
    } on StegoApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  void _setError(String msg) {
    if (mounted) setState(() { _errorMsg = msg; _loading = false; });
  }

  void _reset() {
    setState(() {
      _selectedImageBytes = null;
      _messageCtrl.clear();
      _passwordCtrl.clear();
      _errorMsg  = null;
      _savedPath = null;
      _maxChars  = null;
      _dimensions = null;
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step 1 – Image picker
          _SectionHeader(number: '01', title: 'Select Cover Image'),
          const SizedBox(height: 12),
          ImageDropZone(
            imageBytes: _selectedImageBytes,
            onTap: _pickImage,
            dimensions: _dimensions,
            maxChars: _maxChars,
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Step 2 – Message
          _SectionHeader(number: '02', title: 'Secret Message'),
          const SizedBox(height: 12),
          StegoTextField(
            controller: _messageCtrl,
            hint: 'Enter the message to hide…',
            maxLines: 4,
            onChanged: (v) => setState(() {}),
          ).animate(delay: 50.ms).fadeIn(),
          if (_maxChars != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_messageCtrl.text.length} / $_maxChars chars',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: _messageCtrl.text.length > (_maxChars ?? 999999)
                          ? const Color(0xFFFF4D6D)
                          : const Color(0xFF78909C),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Step 3 – Password
          _SectionHeader(number: '03', title: 'Encryption Password'),
          const SizedBox(height: 12),
          StegoTextField(
            controller: _passwordCtrl,
            hint: 'AES encryption key…',
            obscure: _obscurePass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF78909C),
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 28),

          // Error
          if (_errorMsg != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x1FFF4D6D),
                borderRadius: BorderRadius.circular(12),
                border: const Border.fromBorderSide(BorderSide(color: Color(0x66FF4D6D))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFFF4D6D), size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_errorMsg!,
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFFFF4D6D), fontSize: 13))),
                ],
              ),
            ).animate().shake(),

          // Encode button
          _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
              : ElevatedButton.icon(
                  onPressed: _encode,
                  icon: const Icon(Icons.lock, size: 18),
                  label: const Text('ENCODE & SAVE'),
                ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 16),

          // Success result
          if (_savedPath != null) ...[
            ResultCard(
              title: 'Stego Image Saved!',
              subtitle: _savedPath!,
              imagePath: _savedPath,
              onReset: _reset,
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String number;
  final String title;

  const _SectionHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(number,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}