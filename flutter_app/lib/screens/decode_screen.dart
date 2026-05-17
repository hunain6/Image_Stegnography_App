import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/stego_api_service.dart';
import '../widgets/image_drop_zone.dart';
import '../widgets/stego_text_field.dart';

class DecodeScreen extends StatefulWidget {
  const DecodeScreen({super.key});

  @override
  State<DecodeScreen> createState() => _DecodeScreenState();
}

class _DecodeScreenState extends State<DecodeScreen> {
  Uint8List? _selectedImageBytes;
  final _passwordCtrl = TextEditingController();
  bool _obscurePass   = true;

  bool    _loading    = false;
  String? _errorMsg;
  String? _decodedMsg;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!_isPngBytes(bytes)) {
      _setError('Please select a valid PNG image.');
      return;
    }

    setState(() {
      _selectedImageBytes = bytes;
      _errorMsg   = null;
      _decodedMsg = null;
    });
  }

  bool _isPngBytes(Uint8List bytes) {
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

  Future<void> _decode() async {
    final password = _passwordCtrl.text.trim();

    if (_selectedImageBytes == null) {
      _setError('Please select a stego image first.');
      return;
    }
    if (password.isEmpty) {
      _setError('Please enter the decryption password.');
      return;
    }

    setState(() { _loading = true; _errorMsg = null; _decodedMsg = null; });

    try {
      final message = await StegoApiService.decodeMessage(
        imageBytes: _selectedImageBytes!,
        password: password,
      );
      if (mounted) setState(() { _decodedMsg = message; _loading = false; });
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
      _passwordCtrl.clear();
      _errorMsg   = null;
      _decodedMsg = null;
    });
  }

  @override
  void dispose() {
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
          // Step 1 – Stego image
          _header('01', 'Select Stego Image'),
          const SizedBox(height: 12),
          ImageDropZone(
            imageBytes: _selectedImageBytes,
            onTap: _pickImage,
            label: 'Tap to load stego image',
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Step 2 – Password
          _header('02', 'Decryption Password'),
          const SizedBox(height: 12),
          StegoTextField(
            controller: _passwordCtrl,
            hint: 'Enter the password used during encoding…',
            obscure: _obscurePass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF78909C),
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ).animate(delay: 50.ms).fadeIn(),

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

          // Decode button
          _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
              : ElevatedButton.icon(
                  onPressed: _decode,
                  icon: const Icon(Icons.lock_open, size: 18),
                  label: const Text('EXTRACT MESSAGE'),
                ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 16),

          // Decoded message
          if (_decodedMsg != null)
            _DecodedMessageCard(
              message: _decodedMsg!,
              onReset: _reset,
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _header(String n, String title) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF00D4FF)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(n,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Text(title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }
}

// ─── Decoded Message Display ──────────────────────────────────────────────────

class _DecodedMessageCard extends StatelessWidget {
  final String message;
  final VoidCallback onReset;

  const _DecodedMessageCard({required this.message, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F0A),
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(BorderSide(color: Color(0x6600E676))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 8),
              Text('Message Extracted!',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00E676),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Copy message',
                icon: const Icon(Icons.copy, color: Color(0xFF00D4FF), size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied to clipboard',
                        style: GoogleFonts.spaceGrotesk()),
                      backgroundColor: const Color(0xFF1C2537),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1F0D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1A4A1A)),
            ),
            child: SelectableText(
              message,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Decode Another'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF78909C),
              side: const BorderSide(color: Color(0xFF2A3A5C)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}