part of 'sejarah_bloc.dart';

enum SejarahStatus { initial, loading, success, failure }

class SejarahState extends Equatable {
  const SejarahState({
    this.status = SejarahStatus.initial,
    this.heroImagePath = '',
    this.initialDescription = '', 
    this.finalDescription =
        '', 
    this.historyEntries = const [],
  });

  final SejarahStatus status;
  final String heroImagePath;
  final String initialDescription; 
  final String finalDescription; 
  // Perbarui List historyEntries agar bisa menampung Map<String, dynamic>
  final List<Map<String, dynamic>> historyEntries;

  SejarahState copyWith({
    SejarahStatus? status,
    String? heroImagePath,
    String? initialDescription, 
    String? finalDescription, 
    List<Map<String, dynamic>>? historyEntries, // Perbarui tipe data
  }) {
    return SejarahState(
      status: status ?? this.status,
      heroImagePath: heroImagePath ?? this.heroImagePath,
      initialDescription:
          initialDescription ?? this.initialDescription, 
      finalDescription: finalDescription ?? this.finalDescription, 
      historyEntries: historyEntries ?? this.historyEntries,
    );
  }

  @override
  List<Object?> get props => [
        status,
        heroImagePath,
        initialDescription, 
        finalDescription, 
        historyEntries,
      ];
}
