part of 'divisi_detail_bloc.dart';

abstract class DivisiDetailEvent extends Equatable {
  const DivisiDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchDivisiData extends DivisiDetailEvent {
  final String
      divisiId; // Akan berisi "Steering Committee" atau "Divisi Internal"
  const FetchDivisiData({required this.divisiId});
}
