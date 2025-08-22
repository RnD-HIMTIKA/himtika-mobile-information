part of 'share_workspace_bloc.dart';

enum ShareStatus { initial, loading, success, failure }

class ShareWorkspaceState extends Equatable {
  final ShareStatus status;
  final String? errorMessage;

  const ShareWorkspaceState({
    this.status = ShareStatus.initial,
    this.errorMessage,
  });

  ShareWorkspaceState copyWith({
    ShareStatus? status,
    String? errorMessage,
  }) {
    return ShareWorkspaceState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}