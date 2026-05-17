import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageDropZone extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final String label;
  final String? dimensions;
  final int? maxChars;

  const ImageDropZone({
    super.key,
    required this.imageBytes,
    required this.onTap,
    this.label = 'Tap to select a PNG image',
    this.dimensions,
    this.maxChars,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            height: imageBytes == null ? 180 : 240,
            decoration: BoxDecoration(
              color: imageBytes == null ? const Color(0xFF0D1526) : const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: imageBytes == null ? const Color(0xFF2A3A5C) : const Color(0x6600D4FF),
                width: 1.5,
              ),
            ),
            child: imageBytes == null ? _emptyState() : _imagePreview(),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2537),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: Color(0xFF00D4FF),
            size: 28,
          ),
        ),
        const SizedBox(height: 14),
        Text(label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: const Color(0xFF78909C),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text('PNG format recommended',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: const Color(0xFF3D5170),
          ),
        ),
      ],
    );
  }

  Widget _imagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.memory(
            imageBytes!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Overlay info badge
        Positioned(
          bottom: 10, left: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xCC0A0E1A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2A3A5C)),
            ),
            child: Row(
              children: [
                const Icon(Icons.image, color: Color(0xFF00D4FF), size: 14),
                const SizedBox(width: 6),
                if (dimensions != null)
                  Text(dimensions!,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11, color: const Color(0xFF78909C))),
                const Spacer(),
                if (maxChars != null)
                  Text('≤ $maxChars chars',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11, color: const Color(0xFF00D4FF),
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text('Tap to change',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 11, color: const Color(0xFF3D5170))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}