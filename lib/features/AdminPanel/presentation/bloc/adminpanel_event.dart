import 'package:equatable/equatable.dart';

abstract class AdminPanelEvent extends Equatable {
  const AdminPanelEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminPanel extends AdminPanelEvent {}