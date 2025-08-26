import 'package:equatable/equatable.dart';

class HiCodeCategory extends Equatable {
  final String id;
  final String name;
  final String iconUrl;

  const HiCodeCategory({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name, iconUrl];
}