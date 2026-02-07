class SurveyQuestion {
  final String id;
  final String question;
  int? selectedRating;

  SurveyQuestion({
    required this.id,
    required this.question,
    this.selectedRating,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'rating': selectedRating};
  }
}

enum RatingLevel {
  tidakSesuai(1, '😞', 'Tidak Sesuai'),
  kurangSesuai(2, '😐', 'Kurang Sesuai'),
  sesuai(3, '🙂', 'Sesuai'),
  sangatSesuai(4, '😄', 'Sangat Sesuai');

  final int value;
  final String emoji;
  final String label;

  const RatingLevel(this.value, this.emoji, this.label);

  static RatingLevel fromValue(int value) {
    return RatingLevel.values.firstWhere((e) => e.value == value);
  }
}
