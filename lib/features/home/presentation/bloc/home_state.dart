import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final String username;
  final bool isLoading;
  final List<String> latestItems;
  final int selectedIndex;

  const HomeState({
    this.username = '',
    this.isLoading = false,
    this.latestItems = const [],
    this.selectedIndex = 0,
  });

  HomeState copyWith({
    String? username,
    bool? isLoading,
    List<String>? latestItems,
    int? selectedIndex,
  }) {
    return HomeState(
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      latestItems: latestItems ?? this.latestItems,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [username, isLoading, latestItems, selectedIndex];
}
