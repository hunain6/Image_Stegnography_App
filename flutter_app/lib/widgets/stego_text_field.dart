import 'package:flutter/material.dart';

class StegoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool obscure;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const StegoTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.obscure = false,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: obscure ? 1 : maxLines,
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }
}