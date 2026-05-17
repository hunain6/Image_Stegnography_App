import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final VoidCallback onReset;

  const ResultCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 8),
              Text(title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: const Color(0xFF00E676))),
            ],
          ),
          const SizedBox(height: 10),
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(File(imagePath!), height: 150,
                  width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 10),
          Text(subtitle,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 11, color: const Color(0xFF78909C))),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Encode Another'),
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