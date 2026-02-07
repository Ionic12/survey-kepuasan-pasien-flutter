import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'survey_screen.dart';
import 'admin_dashboard_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                  child: Column(
                    children: [
                      SizedBox(height: isTablet ? 60 : 40),
                      // Logo or App Name
                      Container(
                        padding: EdgeInsets.all(isTablet ? 30 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: isTablet ? 120 : 80,
                        ),
                      ),
                      SizedBox(height: isTablet ? 40 : 24),
                      Text(
                        'KLINIK NOVI MAHARANI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 48 : 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Sistem Survey Kepuasan Pasien',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 80 : 60),

                      // Menu Options
                      Column(
                        children: [
                          _buildMenuButton(
                            context,
                            title: 'Mulai Survey',
                            subtitle: 'Beri kami masukan Anda',
                            icon: Icons.assignment_outlined,
                            color: Colors.white,
                            textColor: const Color(0xFF00796B),
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SurveyScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                          _buildMenuButton(
                            context,
                            title: 'Dashboard Admin',
                            subtitle: 'Lihat hasil & statistik',
                            icon: Icons.dashboard_customize_outlined,
                            color: Colors.white.withOpacity(0.2),
                            textColor: Colors.white,
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminDashboardScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                          _buildMenuButton(
                            context,
                            title: 'Keluar Aplikasi',
                            subtitle: 'Tutup aplikasi',
                            icon: Icons.exit_to_app,
                            color: Colors.transparent,
                            textColor: Colors.white70,
                            isOutlined: true,
                            isTablet: isTablet,
                            onTap: () {
                              _showExitDialog(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 60 : 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
