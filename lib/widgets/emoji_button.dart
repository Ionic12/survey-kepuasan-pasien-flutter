import 'package:flutter/material.dart';
import '../models/survey_question.dart';

class EmojiButton extends StatelessWidget {
  final RatingLevel rating;
  final bool isSelected;
  final VoidCallback onTap;

  const EmojiButton({
    Key? key,
    required this.rating,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  Color _getColor() {
    switch (rating) {
      case RatingLevel.tidakSesuai:
        return const Color(0xFFEF5350); // Red
      case RatingLevel.kurangSesuai:
        return const Color(0xFFFF9800); // Orange
      case RatingLevel.sesuai:
        return const Color(0xFF66BB6A); // Green
      case RatingLevel.sangatSesuai:
        return const Color(0xFF00897B); // Teal (SatuSehat)
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic sizes based on available width
        // On mobile, width is typically ~150-180. On tablets, it could be larger.
        final double availableWidth = constraints.maxWidth;
        final double emojiSize = (availableWidth * 0.45).clamp(40.0, 90.0);
        final double fontSize = (availableWidth * 0.12).clamp(12.0, 20.0);

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: RepaintBoundary(
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Selection background
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: emojiSize * 1.4,
                        height: emojiSize * 1.4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? _getColor().withOpacity(0.12)
                              : Colors.transparent,
                        ),
                      ),
                      Text(
                        rating.emoji,
                        style: TextStyle(
                          fontSize: emojiSize,
                          shadows: isSelected
                              ? [
                                  Shadow(
                                    color: _getColor().withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? _getColor() : Colors.grey.shade600,
                      fontSize: fontSize,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      height: 1.2,
                    ),
                    child: Text(
                      rating.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
