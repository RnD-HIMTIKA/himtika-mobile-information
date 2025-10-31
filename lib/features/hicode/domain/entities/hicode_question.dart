import 'package:equatable/equatable.dart';
import 'hicode_option.dart'; // Pastikan import benar

class HiCodeQuestion extends Equatable {
  final String id;
  final String questionText;
  final String? imageUrl;
  final List<HiCodeOption> options;

  const HiCodeQuestion({
    required this.id,
    required this.questionText,
    this.imageUrl,
    required this.options,
  });

  @override
  List<Object?> get props => [id, questionText, imageUrl, options];
}