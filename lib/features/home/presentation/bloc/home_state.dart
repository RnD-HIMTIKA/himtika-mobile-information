import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final String username;
  final bool isLoading;
  final List<String> latestItems;

  const HomeState({
    this.username = '',
    this.isLoading = false,
    this.latestItems = const [],
  });

  HomeState copyWith({
    String? username,
    bool? isLoading,
    List<String>? latestItems,
  }) {
    return HomeState(
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      latestItems: latestItems ?? this.latestItems,
    );
  }

  @override
  List<Object?> get props => [username, isLoading, latestItems];
}
