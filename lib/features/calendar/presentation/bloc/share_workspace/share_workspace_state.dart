part of 'share_workspace_bloc.dart';

enum ShareStatus { initial, loading, success, failure }
enum SearchStatus { initial, loading, loaded, failure }

class ShareWorkspaceState extends Equatable {
  // Status untuk aksi invite/create link
  final ShareStatus shareStatus;
  final String? shareErrorMessage;
  
  // State khusus untuk pencarian
  final SearchStatus searchStatus;
  final List<User> searchResults;
  final String? searchErrorMessage;

  const ShareWorkspaceState({
    this.shareStatus = ShareStatus.initial,
    this.shareErrorMessage,
    this.searchStatus = SearchStatus.initial,
    this.searchResults = const [],
    this.searchErrorMessage,
  });

  ShareWorkspaceState copyWith({
    ShareStatus? shareStatus,
    String? shareErrorMessage,
    SearchStatus? searchStatus,
    List<User>? searchResults,
    String? searchErrorMessage,
    bool clearShareError = false,
  }) {
    return ShareWorkspaceState(
      shareStatus: shareStatus ?? this.shareStatus,
      shareErrorMessage: clearShareError ? null : shareErrorMessage ?? this.shareErrorMessage,
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      searchErrorMessage: searchErrorMessage ?? this.searchErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        shareStatus,
        shareErrorMessage,
        searchStatus,
        searchResults,
        searchErrorMessage,
      ];
}