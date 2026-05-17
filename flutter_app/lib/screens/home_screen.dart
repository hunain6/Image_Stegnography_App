import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'encode_screen.dart';
import 'decode_screen.dart';
import '../services/stego_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _serverOnline = false;
  bool _checkingServer = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkServer();
  }

  Future<void> _checkServer() async {
    final ok = await StegoApiService.isServerRunning();
    if (mounted) setState(() { _serverOnline = ok; _checkingServer = false; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 800 ? 12.0 : 24.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildServerBadge(),
                      _buildTabBar(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: const [EncodeScreen(), DecodeScreen()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF0D1526)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
                  ),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                'StegoVault',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'AES Encryption + LSB Image Steganography',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: const Color(0xFF00D4FF),
              letterSpacing: 0.5,
            ),
          ).animate(delay: 100.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildServerBadge() {
    Color dot;
    String label;
    if (_checkingServer) {
      dot = Colors.orange;
      label = 'Checking server…';
    } else if (_serverOnline) {
      dot = const Color(0xFF00E676);
      label = 'Backend connected';
    } else {
      dot = const Color(0xFFFF4D6D);
      label = 'Backend offline — start stego_server.py';
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFF0D1526),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          AnimatedContainer(
            duration: 300.ms,
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: dot.withAlpha((0.6 * 255).round()), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: const Color(0xFF78909C),
            ),
          ),
          const Spacer(),
          if (!_serverOnline && !_checkingServer)
            GestureDetector(
              onTap: () { setState(() => _checkingServer = true); _checkServer(); },
              child: Text('Retry',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: const Color(0xFF00D4FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF0D1526),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A3A5C)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorPadding: const EdgeInsets.all(4),
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelColor: const Color(0xFF0A0E1A),
          unselectedLabelColor: const Color(0xFF78909C),
          tabs: const [
            Tab(text: '🔒  Encode'),
            Tab(text: '🔓  Decode'),
          ],
        ),
      ),
    );
  }
}