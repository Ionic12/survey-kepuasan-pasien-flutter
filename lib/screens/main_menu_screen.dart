import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'survey_screen.dart';
import 'admin_dashboard_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00897B), Color(0xFF00796B), Color(0xFF004D40)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 900;
              final bool isTablet = constraints.maxWidth > 600;

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 60 : (isTablet ? 40 : 20),
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isWide ? 40 : (isTablet ? 60 : 40)),
                        // Logo and Title Section
                        _buildHeader(isWide, isTablet),

                        SizedBox(height: isWide ? 60 : (isTablet ? 80 : 60)),

                        // Menu Options - Responsive Layout
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 1100 : 700,
                          ),
                          child: isWide
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildMenuButton(
                                        context,
                                        title: 'Mulai Survey',
                                        subtitle: 'Beri kami masukan Anda',
                                        icon: Icons.assignment_outlined,
                                        color: Colors.white,
                                        textColor: const Color(0xFF00796B),
                                        isTablet: true,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SurveyScreen(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _buildMenuButton(
                                        context,
                                        title: 'Dashboard Admin',
                                        subtitle: 'Lihat hasil & statistik',
                                        icon:
                                            Icons.dashboard_customize_outlined,
                                        color: Colors.white,
                                        textColor: const Color(0xFF00796B),
                                        isTablet: true,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AdminDashboardScreen(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _buildMenuButton(
                                        context,
                                        title: 'Keluar',
                                        subtitle: 'Tutup aplikasi',
                                        icon: Icons.exit_to_app,
                                        color: Colors.white,
                                        textColor: const Color(0xFFD32F2F),
                                        isTablet: true,
                                        onTap: () => _showExitDialog(context),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildMenuButton(
                                      context,
                                      title: 'Mulai Survey',
                                      subtitle: 'Beri kami masukan Anda',
                                      icon: Icons.assignment_outlined,
                                      color: Colors.white,
                                      textColor: const Color(0xFF00796B),
                                      isTablet: isTablet,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SurveyScreen(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 24 : 16),
                                    _buildMenuButton(
                                      context,
                                      title: 'Dashboard Admin',
                                      subtitle: 'Lihat hasil & statistik',
                                      icon: Icons.dashboard_customize_outlined,
                                      color: Colors.white,
                                      textColor: const Color(0xFF00796B),
                                      isTablet: isTablet,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminDashboardScreen(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 24 : 16),
                                    _buildMenuButton(
                                      context,
                                      title: 'Keluar Aplikasi',
                                      subtitle: 'Tutup aplikasi',
                                      icon: Icons.exit_to_app,
                                      color: Colors.white,
                                      textColor: const Color(0xFFD32F2F),
                                      isTablet: isTablet,
                                      onTap: () => _showExitDialog(context),
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWide, bool isTablet) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isWide ? 40 : (isTablet ? 30 : 20)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: isWide ? 150 : (isTablet ? 120 : 80),
          ),
        ),
        SizedBox(height: isWide ? 40 : (isTablet ? 40 : 24)),
        Text(
          'KLINIK NOVI MAHARANI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 60 : (isTablet ? 48 : 38),
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Sistem Survey Kepuasan Pasien',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isWide ? 22 : (isTablet ? 18 : 14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    required bool isTablet,
    bool isOutlined = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 28 : 20,
            horizontal: isTablet ? 32 : 24,
          ),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(25),
            border: isOutlined
                ? Border.all(color: Colors.white30, width: 2)
                : null,
            boxShadow: isOutlined
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: isTablet ? 15 : 10,
                      offset: Offset(0, isTablet ? 6 : 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: isOutlined
                      ? Colors.white10
                      : textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: textColor, size: isTablet ? 40 : 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: textColor.withOpacity(0.5),
                size: isTablet ? 30 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Apakah Anda yakin ingin menutup aplikasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
