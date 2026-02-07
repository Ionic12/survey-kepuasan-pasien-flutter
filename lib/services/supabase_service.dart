import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  /// Submit survey response to Supabase
  ///
  /// Parameters:
  /// - question1Rating: Rating untuk pertanyaan 1 (1-4)
  /// - question2Rating: Rating untuk pertanyaan 2 (1-4)
  /// - question3Rating: Rating untuk pertanyaan 3 (1-4)
  /// - respondentName: Nama responden (opsional)
  /// - respondentEmail: Email responden (opsional)
  /// - additionalComments: Komentar tambahan (opsional)
  Future<bool> submitSurveyResponse({
    required int question1Rating,
    required int question2Rating,
    required int question3Rating,
    required int question4Rating,
    String? respondentName,
    String? respondentEmail,
    String? respondentPhone,
    String? additionalComments,
  }) async {
    try {
      print('🔄 Memulai pengiriman survey...');

      // Validasi rating (1-4)
      if (question1Rating < 1 ||
          question1Rating > 4 ||
          question2Rating < 1 ||
          question2Rating > 4 ||
          question3Rating < 1 ||
          question3Rating > 4 ||
          question4Rating < 1 ||
          question4Rating > 4) {
        print('❌ Error: Rating harus antara 1-4');
        print(
          '   Q1: $question1Rating, Q2: $question2Rating, Q3: $question3Rating, Q4: $question4Rating',
        );
        return false;
      }

      print('✅ Validasi rating berhasil');
      print(
        '   Q1: $question1Rating, Q2: $question2Rating, Q3: $question3Rating, Q4: $question4Rating',
      );

      final data = {
        'question_1_rating': question1Rating,
        'question_2_rating': question2Rating,
        'question_3_rating': question3Rating,
        'question_4_rating': question4Rating,
        'respondent_name': respondentName,
        'respondent_email': respondentEmail,
        'respondent_phone': respondentPhone,
        'additional_comments': additionalComments,
        'app_version': '1.0.0',
      };

      // Remove null values
      data.removeWhere((key, value) => value == null);

      print('📦 Data yang akan dikirim: $data');
      print('🌐 Mengirim ke Supabase...');

      final response = await client
          .from('survey_responses')
          .insert(data)
          .select();

      print('✅ Response dari Supabase: $response');
      print('✅ Survey berhasil dikirim ke Supabase!');
      return true;
    } catch (e, stackTrace) {
      print('❌ ERROR DETAIL:');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('   StackTrace: $stackTrace');

      // Check specific error types
      if (e.toString().contains('relation') &&
          e.toString().contains('does not exist')) {
        print('');
        print('⚠️  TABEL BELUM DIBUAT!');
        print('   Silakan jalankan SQL schema di Supabase Dashboard:');
        print('   1. Buka https://app.supabase.com');
        print('   2. Pilih project Anda');
        print('   3. Klik SQL Editor → New Query');
        print('   4. Copy-paste isi file supabase_schema.sql');
        print('   5. Klik Run');
        print('');
      } else if (e.toString().contains('JWT') ||
          e.toString().contains('expired')) {
        print('');
        print('⚠️  API KEY EXPIRED!');
        print('   Silakan update anon key di main.dart');
        print('');
      } else if (e.toString().contains('policy')) {
        print('');
        print('⚠️  RLS POLICY ERROR!');
        print('   Pastikan RLS policy sudah diaktifkan dengan benar');
        print('');
      }

      return false;
    }
  }

  /// Get all survey responses (untuk analytics/admin)
  Future<List<Map<String, dynamic>>> getSurveyResponses({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = client
          .from('survey_responses')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      var results = List<Map<String, dynamic>>.from(response);

      // Filter by date in Dart if needed
      if (startDate != null || endDate != null) {
        results = results.where((item) {
          final createdAt = DateTime.parse(item['created_at'] as String);
          if (startDate != null && createdAt.isBefore(startDate)) {
            return false;
          }
          if (endDate != null && createdAt.isAfter(endDate)) {
            return false;
          }
          return true;
        }).toList();
      }

      return results;
    } catch (e) {
      print('❌ Error fetching responses: $e');
      return [];
    }
  }

  /// Get survey statistics
  Future<Map<String, dynamic>> getSurveyStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final responses = await getSurveyResponses(
        startDate: startDate,
        endDate: endDate,
      );

      if (responses.isEmpty) {
        return {
          'total_responses': 0,
          'avg_question_1': 0.0,
          'avg_question_2': 0.0,
          'avg_question_3': 0.0,
          'avg_question_4': 0.0,
          'avg_overall': 0.0,
          'satisfaction_rate': 0.0,
        };
      }

      // Calculate averages
      double sumQ1 = 0, sumQ2 = 0, sumQ3 = 0, sumQ4 = 0;
      int satisfiedCount = 0;

      for (var response in responses) {
        final q1 = response['question_1_rating'] as int;
        final q2 = response['question_2_rating'] as int;
        final q3 = response['question_3_rating'] as int;
        final q4 = response['question_4_rating'] as int;

        sumQ1 += q1;
        sumQ2 += q2;
        sumQ3 += q3;
        sumQ4 += q4;

        // Count as satisfied if average >= 3
        if ((q1 + q2 + q3 + q4) / 4 >= 3) {
          satisfiedCount++;
        }
      }

      final total = responses.length;
      final avgQ1 = sumQ1 / total;
      final avgQ2 = sumQ2 / total;
      final avgQ3 = sumQ3 / total;
      final avgQ4 = sumQ4 / total;
      final avgOverall = (avgQ1 + avgQ2 + avgQ3 + avgQ4) / 4;
      final satisfactionRate = (satisfiedCount / total) * 100;

      return {
        'total_responses': total,
        'avg_question_1': double.parse(avgQ1.toStringAsFixed(2)),
        'avg_question_2': double.parse(avgQ2.toStringAsFixed(2)),
        'avg_question_3': double.parse(avgQ3.toStringAsFixed(2)),
        'avg_question_4': double.parse(avgQ4.toStringAsFixed(2)),
        'avg_overall': double.parse(avgOverall.toStringAsFixed(2)),
        'satisfaction_rate': double.parse(satisfactionRate.toStringAsFixed(2)),
      };
    } catch (e) {
      print('❌ Error calculating stats: $e');
      return {
        'total_responses': 0,
        'avg_question_1': 0.0,
        'avg_question_2': 0.0,
        'avg_question_3': 0.0,
        'avg_question_4': 0.0,
        'avg_overall': 0.0,
        'satisfaction_rate': 0.0,
      };
    }
  }

  /// Get daily summary using Supabase view
  Future<List<Map<String, dynamic>>> getDailySummary({int? limit}) async {
    try {
      var query = client
          .from('daily_survey_summary')
          .select()
          .order('survey_date', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching daily summary: $e');
      return [];
    }
  }

  /// Get rating distribution
  Future<List<Map<String, dynamic>>> getRatingDistribution() async {
    try {
      final response = await client
          .from('rating_distribution')
          .select()
          .order('question')
          .order('rating');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching rating distribution: $e');
      return [];
    }
  }

  /// Test connection to Supabase
  Future<bool> testConnection() async {
    try {
      await client.from('survey_questions').select().limit(1);
      print('✅ Koneksi ke Supabase berhasil!');
      return true;
    } catch (e) {
      print('❌ Koneksi ke Supabase gagal: $e');
      return false;
    }
  }
}
