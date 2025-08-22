part of 'hicode_bloc.dart';

abstract class HicodeEvent extends Equatable {
  const HicodeEvent();

  @override
  List<Object> get props => [];
}

// Nama kelas event diubah
class HicodeDataFetched extends HicodeEvent {}