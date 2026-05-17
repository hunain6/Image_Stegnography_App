import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StegoApp());
}

class StegoApp extends StatelessWidget {
  const StegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StegoVault',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF0A0E1A);
    const accentColor  = Color(0xFF00D4FF);
    const surfaceColor = Color(0xFF111827);
    const cardColor    = Color(0xFF1C2537);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryColor,
      primaryColor: accentColor,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: Color(0xFF7C3AED),
        surface: surfaceColor,
        error: Color(0xFFFF4D6D),
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: Colors.white),
          bodyLarge:  TextStyle(color: Color(0xFFB0BEC5)),
          bodyMedium: TextStyle(color: Color(0xFF78909C)),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D1526),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A3A5C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A3A5C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF78909C)),
        hintStyle: const TextStyle(color: Color(0xFF3D5170)),
      ),
      useMaterial3: true,
    );
  }
}