import 'package:equatable/equatable.dart';

class Division extends Equatable {
  final String id;
  final String name;
  final String logoUrl;
  final int order;

  const Division({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.order,
  });

  @override
  List<Object?> get props => [id, name, logoUrl, order];
}