import 'package:equatable/equatable.dart';

class AdminOptionDetail extends Equatable {
  final String id;
  final String optionText;
  final bool isCorrect;

  const AdminOptionDetail({
    required this.id,
    required this.optionText,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [id, optionText, isCorrect];
}