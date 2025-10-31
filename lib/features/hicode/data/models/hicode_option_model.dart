import '../../domain/entities/hicode_option.dart';

class HiCodeOptionModel extends HiCodeOption {
  const HiCodeOptionModel({
    required super.id,
    required super.optionText,
    super.imageUrl,
  });

  factory HiCodeOptionModel.fromMap(Map<String, dynamic> map) {
    // Cek format map dari RPC baru (ROW type)
    final optionData = map['row'] ?? map; // Handle jika dibungkus 'row' atau tidak

    return HiCodeOptionModel(
      id: optionData['id'],
      optionText: optionData['option_text'],
      imageUrl: optionData['image_url'], // <-- Ambil image_url
    );
  }

  // Overload fromMap lama jika masih dipakai di tempat lain (misal get_question_details admin)
   factory HiCodeOptionModel.fromAdminMap(Map<String, dynamic> map) {
    return HiCodeOptionModel(
      id: map['id'],
      optionText: map['option_text'],
      imageUrl: map['image_url'],
    );
  }
}