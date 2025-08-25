import '../../domain/entities/division.dart';

class DivisionModel extends Division {
  const DivisionModel({
    required super.id,
    required super.name,
    required super.logoUrl,
    required super.order,
  });

  factory DivisionModel.fromMap(Map<String, dynamic> map) {
    return DivisionModel(
      id: map['id'],
      name: map['name'],
      logoUrl: map['logo_url'],
      order: map['order'],
    );
  }
}