import '../../domain/entities/hicode_option.dart';

class HiCodeOptionModel extends HiCodeOption {
  const HiCodeOptionModel({
    required super.id,
    required super.optionText,
  });

  factory HiCodeOptionModel.fromMap(Map<String, dynamic> map) {
    return HiCodeOptionModel(
      id: map['id'],
      optionText: map['option_text'],
    );
  }
}