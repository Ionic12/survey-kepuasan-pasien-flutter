import 'package:flutter/material.dart';
import '../models/survey_question.dart';
import 'survey_screen.dart';

class ResultScreen extends StatelessWidget {
  final List<SurveyQuestion> questions;

  const ResultScreen({Key? key, required this.questions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SurveyScreen()),
            (route) => route.isFirst,
          );
        },
        child: Container(
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 24,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 40 : 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: isTablet ? 140 : 90,
                          ),
                        ),
                        SizedBox(height: isTablet ? 48 : 32),
                        Text(
                          'Terima Kasih!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 48 : 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 12),
                        Text(
                          'Masukan Anda sangat berharga bagi kami.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 22 : 16,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: isTablet ? 80 : 50),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : 24,
                            vertical: isTablet ? 18 : 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Colors.white.withOpacity(0.7),
                                size: isTablet ? 24 : 18,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Ketuk di mana saja untuk kembali',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: isTablet ? 16 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
