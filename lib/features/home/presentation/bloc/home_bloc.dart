import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import 'package:himtika_mobile_information/features/home/domain/usecases/get_home_content.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_my_roles.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentUser _getCurrentUser;
  final GetMyRoles _getMyRoles;
  final GetHomeContent _getHomeContent;

  HomeBloc({
    required GetCurrentUser getCurrentUser,
    required GetMyRoles getMyRoles,
    required GetHomeContent getHomeContent,
  })  : _getCurrentUser = getCurrentUser,
        _getMyRoles = getMyRoles,
        _getHomeContent = getHomeContent,
        super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    // Tampilkan loading HANYA jika data belum ada
    if (state.currentUser == null) {
      emit(state.copyWith(isLoading: true));
    }
    
    try {
      final user = await _getCurrentUser();
      final roles = await _getMyRoles();
      final (banners, divisions) = await _getHomeContent();

      final isPengurus = roles.any((role) => 
          role.groupName == 'Pengurus' || 
          role.groupName == 'System' || 
          role.name == 'RnD'
      );

      emit(state.copyWith(
        isLoading: false, // Selalu set false setelah selesai
        currentUser: user,
        isPengurus: isPengurus,
        banners: banners,
        divisions: divisions,
        currentUserRoles: roles,
      ));
    } catch (e, stackTrace) { // <-- UBAH DI SINI
      // 2. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);

      // 3. Pesan Profesional (untuk Home, kita tidak tampilkan error, cukup set isLoading = false)
      emit(state.copyWith(
        isLoading: false 
        // Kita tidak perlu errorMessage di home, 
        // tapi jika ingin, tambahkan propertinya di HomeState
      )); 
    }
  }
}