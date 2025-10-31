import 'package:equatable/equatable.dart';

// ...
class QuestionOptionInput extends Equatable {
  final String optionText;
  final bool isCorrect;
  final String? imageUrl; // <-- Tambahkan ini

  const QuestionOptionInput({
    required this.optionText,
    required this.isCorrect,
    this.imageUrl, // <-- Tambahkan ini
  });

  Map<String, dynamic> toJson() {
    return {
      'option_text': optionText,
      'is_correct': isCorrect,
      'image_url': imageUrl, // <-- Tambahkan ini
    };
  }

  @override
  // Tambahkan imageUrl ke props
  List<Object?> get props => [optionText, isCorrect, imageUrl];
}