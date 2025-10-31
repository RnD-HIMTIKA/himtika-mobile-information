import 'package:equatable/equatable.dart';

class AdminOptionDetail extends Equatable {
  final String id;
  final String optionText;
  final bool isCorrect;
  final String? imageUrl; // <-- Tambahkan field ini

  const AdminOptionDetail({
    required this.id,
    required this.optionText,
    required this.isCorrect,
    this.imageUrl, // <-- Tambahkan di constructor
  });

  @override
  // Tambahkan imageUrl ke props
  List<Object?> get props => [id, optionText, isCorrect, imageUrl];
}