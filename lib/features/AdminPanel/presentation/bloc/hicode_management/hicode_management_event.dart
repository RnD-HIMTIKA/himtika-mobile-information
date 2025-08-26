part of 'hicode_management_bloc.dart';
abstract class HicodeManagementEvent extends Equatable {
  const HicodeManagementEvent();
  @override
  List<Object> get props => [];
}

class LoadHicodeMaterials extends HicodeManagementEvent {}