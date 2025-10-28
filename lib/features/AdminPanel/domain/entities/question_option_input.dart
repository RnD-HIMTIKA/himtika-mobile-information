import 'package:equatable/equatable.dart';

class QuestionOptionInput extends Equatable {
  final String optionText;
  final bool isCorrect;
  // final String? imageUrl; // Bisa ditambahkan nanti

  const QuestionOptionInput({
    required this.optionText,
    required this.isCorrect,
    // this.imageUrl,
  });

  // Helper untuk konversi ke Map JSON yang dibutuhkan RPC
  Map<String, dynamic> toJson() {
    return {
      'option_text': optionText,
      'is_correct': isCorrect,
      // 'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [optionText, isCorrect /*, imageUrl*/];
}