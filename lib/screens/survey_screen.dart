import 'package:flutter/material.dart';
import '../models/survey_question.dart';
import '../widgets/emoji_button.dart';
import '../widgets/question_card.dart';
import '../services/supabase_service.dart';
import 'result_screen.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  final List<SurveyQuestion> _questions = [
    SurveyQuestion(
      id: 'q1',
      question:
          'Bagaimana pendapat Anda tentang alur, kecepatan dan jenis pelayanan yang diberikan di Klinik Novi Maharani?',
    ),
    SurveyQuestion(
      id: 'q2',
      question:
          'Bagaimana pendapat Anda tentang kewajaran tarif pelayanan dan kesesuaian produk yang diberikan di Klinik Novi Maharani?',
    ),
    SurveyQuestion(
      id: 'q3',
      question:
          'Bagaimana pendapat Anda tentang kesopanan, keramahan dan kemahiran petugas dalam pelayanan di Klinik Novi Maharani?',
    ),
    SurveyQuestion(
      id: 'q4',
      question:
          'Bagaimana pendapat Anda tentang kualitas sarana dan prasarana?',
    ),
  ];

  void _selectRating(int questionIndex, int rating) {
    if (_isSubmitting) return;

    setState(() {
      _questions[questionIndex].selectedRating = rating;
    });

    // Auto navigate after a slightly longer delay to let emoji animation finish
    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      if (_currentPage < _questions.length - 1) {
        _nextPage();
      } else {
        _submitSurvey();
      }
    });
  }

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  Future<void> _submitSurvey() async {
    // Check if all questions are answered
    bool allAnswered = _questions.every((q) => q.selectedRating != null);

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon jawab semua pertanyaan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ratings = _questions
          .map((q) => q.selectedRating ?? 3) // Default to 3 if somehow null
          .toList();

      await _supabaseService.submitSurveyResponse(
        question1Rating: ratings[0],
        question2Rating: ratings[1],
        question3Rating: ratings[2],
        question4Rating: _questions.length > 3 ? ratings[3] : 3,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(questions: _questions),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FBFA), Colors.white, Color(0xFFE0F2F1)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 40 : 20),
                    child: Column(
                      children: [
                        Text(
                          'Survey Kepuasan Pasien',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF00796B),
                            fontSize: isTablet ? 36 : 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bantu kami meningkatkan layanan',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: isTablet ? 18 : 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      allowImplicitScrolling: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isTablet = constraints.maxWidth > 450;
                            final bool isDesktop = constraints.maxWidth > 750;

                            return Center(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 40 : 20,
                                    vertical: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      QuestionCard(
                                        question: _questions[index].question,
                                        questionNumber: index + 1,
                                        totalQuestions: _questions.length,
                                        isWide: isDesktop,
                                      ),
                                      const SizedBox(height: 32),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: isDesktop
                                              ? 1200
                                              : double.infinity,
                                        ),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              EmojiButton(
                                                rating: RatingLevel.tidakSesuai,
                                                isSelected:
                                                    _questions[index]
                                                        .selectedRating ==
                                                    RatingLevel
                                                        .tidakSesuai
                                                        .value,
                                                onTap: () => _selectRating(
                                                  index,
                                                  RatingLevel.tidakSesuai.value,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              EmojiButton(
                                                rating:
                                                    RatingLevel.kurangSesuai,
                                                isSelected:
                                                    _questions[index]
                                                        .selectedRating ==
                                                    RatingLevel
                                                        .kurangSesuai
                                                        .value,
                                                onTap: () => _selectRating(
                                                  index,
                                                  RatingLevel
                                                      .kurangSesuai
                                                      .value,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              EmojiButton(
                                                rating: RatingLevel.sesuai,
                                                isSelected:
                                                    _questions[index]
                                                        .selectedRating ==
                                                    RatingLevel.sesuai.value,
                                                onTap: () => _selectRating(
                                                  index,
                                                  RatingLevel.sesuai.value,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              EmojiButton(
                                                rating:
                                                    RatingLevel.sangatSesuai,
                                                isSelected:
                                                    _questions[index]
                                                        .selectedRating ==
                                                    RatingLevel
                                                        .sangatSesuai
                                                        .value,
                                                onTap: () => _selectRating(
                                                  index,
                                                  RatingLevel
                                                      .sangatSesuai
                                                      .value,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (_isSubmitting)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00897B)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
