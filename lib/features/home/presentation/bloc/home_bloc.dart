import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<ChangeTab>(_onChangeTab); // ✅ tambahkan event baru
  }

  void _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));

    await Future.delayed(const Duration(seconds: 1)); // simulasi fetch data

    emit(state.copyWith(
      username: "Mahesa Muhamad Nabil",
      latestItems: ["item1", "item2"],
      isLoading: false,
    ));
  }

  void _onChangeTab(ChangeTab event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedIndex: event.index)); // ubah tab aktif
  }
}
