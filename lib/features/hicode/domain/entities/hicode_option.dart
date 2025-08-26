import 'package:equatable/equatable.dart';

class HiCodeOption extends Equatable {
  final String id;
  final String optionText;

  const HiCodeOption({
    required this.id,
    required this.optionText,
  });

  @override
  List<Object?> get props => [id, optionText];
}