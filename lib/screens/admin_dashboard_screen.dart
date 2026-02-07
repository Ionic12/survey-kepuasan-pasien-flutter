import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../services/excel_service.dart';
import 'survey_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final ExcelService _excelService = ExcelService();

  bool _isLoading = true;
  bool _isDownloading = false;
  List<Map<String, dynamic>> _responses = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final responses = await _supabaseService.getSurveyResponses();
      final stats = await _supabaseService.getSurveyStats();

      setState(() {
        _responses = responses;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadExcel() async {
    if (_responses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data untuk diexport'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Logic for Android storage permission
      if (Platform.isAndroid) {
        // On Android 13+ (SDK 33), WRITE_EXTERNAL_STORAGE is not used/needed for many cases
        // We'll try to request if possible, but continue if it fails as Scoped Storage might handle it
        try {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            // We don't throw immediately here for SDK 33+ compatibility
          }
        } catch (e) {
          print('Permission request skipped or failed: $e');
        }
      }

      // Generate Excel bytes
      final bytes = await _excelService.generateExcel(_responses);

      // Get appropriate directory
      Directory? directory;
      if (Platform.isAndroid) {
        // Try to use public Downloads first (might fail on 11+ without MANAGE permission)
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to app-specific external storage (always works and visible to user)
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Tidak dapat menemukan direktori penyimpanan');
      }

      // Save file with beautiful name
      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filePath = '${directory.path}/Survey_Klinik_$dateStr.xlsx';
      final file = File(filePath);

      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ Excel Berhasil Diunduh!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lokasi: ${file.path}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00796B),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      print('Error downloading Excel: $e');
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('permission')) {
          errorMsg =
              'Akses penyimpanan ditolak. Silakan berikan izin di pengaturan.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal download: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade500,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 30 : 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 32 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Hasil Survey Kepuasan',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _isLoading ? null : _loadData,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _responses.isEmpty
                        ? _buildEmptyState()
                        : _buildContent(isTablet),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data survey',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan isi survey terlebih dahulu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SurveyScreen()),
              );
            },
            icon: const Icon(Icons.edit_note),
            label: const Text('Isi Survey'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isTablet) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            _buildStatisticsCards(isTablet),

            const SizedBox(height: 24),

            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadExcel,
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.deepPurple,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isDownloading ? 'Downloading...' : 'Download Excel',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Recent Responses
            _buildRecentResponses(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(bool isTablet) {
    final totalResponses = _stats['total_responses'] ?? 0;
    final avgQ1 = _stats['avg_question_1'] ?? 0.0;
    final avgQ2 = _stats['avg_question_2'] ?? 0.0;
    final avgQ3 = _stats['avg_question_3'] ?? 0.0;
    final avgQ4 = _stats['avg_question_4'] ?? 0.0;
    final avgOverall = _stats['avg_overall'] ?? 0.0;
    final satisfactionRate = _stats['satisfaction_rate'] ?? 0.0;

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  title: 'Total Responden',
                  value: totalResponses.toString(),
                  color: Colors.blue,
                  isTablet: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  title: 'Rata-rata Skor',
                  value: avgOverall.toStringAsFixed(1),
                  color: Colors.amber,
                  isTablet: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.thumb_up,
                  title: 'Tingkat Kepuasan',
                  value: '${satisfactionRate.toStringAsFixed(0)}%',
                  color: Colors.lightGreenAccent,
                  isTablet: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.analytics,
                  title: 'Skor per Q',
                  value:
                      '${avgQ1.toStringAsFixed(1)} / ${avgQ2.toStringAsFixed(1)} / ${avgQ3.toStringAsFixed(1)} / ${avgQ4.toStringAsFixed(1)}',
                  color: Colors.purpleAccent,
                  isTablet: true,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // First Row - 2 cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                title: 'Total',
                value: totalResponses.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                title: 'Rata-rata',
                value: avgOverall.toStringAsFixed(1),
                color: Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Second Row - 2 cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.thumb_up,
                title: 'Kepuasan',
                value: '${satisfactionRate.toStringAsFixed(0)}%',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.analytics,
                title: 'Per Q',
                value:
                    '${avgQ1.toStringAsFixed(1)}/${avgQ2.toStringAsFixed(1)}/${avgQ3.toStringAsFixed(1)}/${avgQ4.toStringAsFixed(1)}',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isTablet = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25), // Harmonized correctly
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isTablet ? 32 : 24),
          SizedBox(height: isTablet ? 10 : 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isTablet ? 13 : 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentResponses(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Respon Terbaru',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _responses.length > 5 ? 5 : _responses.length,
          itemBuilder: (context, index) {
            final response = _responses[index];
            final createdAt = DateTime.parse(response['created_at']).toLocal();
            final q1 = response['question_1_rating'];
            final q2 = response['question_2_rating'];
            final q3 = response['question_3_rating'];
            final q4 = response['question_4_rating'] ?? 3;
            final avg = (q1 + q2 + q3 + q4) / 4;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(isTablet ? 20 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isTablet ? 13 : 11,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 6,
                          vertical: isTablet ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: avg >= 3 ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          avg.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 13 : 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildRatingBadge('Alur', q1, isTablet),
                      _buildRatingBadge('Tarif', q2, isTablet),
                      _buildRatingBadge('Petugas', q3, isTablet),
                      _buildRatingBadge('Fasilitas', q4, isTablet),
                    ],
                  ),
                  if (response['additional_comments'] != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      response['additional_comments'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isTablet ? 13 : 11,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingBadge(String label, int rating, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 6,
        vertical: isTablet ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        '$label: $rating',
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 12 : 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
