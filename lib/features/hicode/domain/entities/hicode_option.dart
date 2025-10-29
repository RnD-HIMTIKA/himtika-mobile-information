import 'package:equatable/equatable.dart';

class HiCodeOption extends Equatable {
  final String id;
  final String optionText;
  final String? imageUrl;

  const HiCodeOption({
    required this.id,
    required this.optionText,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, optionText, imageUrl];
}