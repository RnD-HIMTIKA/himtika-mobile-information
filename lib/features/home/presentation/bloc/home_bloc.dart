import 'package:flutter_bloc/flutter_bloc.dart';
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
    emit(state.copyWith(isLoading: true));
    try {
      final user = await _getCurrentUser();
      final roles = await _getMyRoles();
      final (banners, divisions) = await _getHomeContent();

      final isPengurus = roles.any((role) => role.groupName == 'Pengurus');

      emit(state.copyWith(
        isLoading: false,
        currentUser: user,
        isPengurus: isPengurus,
        banners: banners,
        divisions: divisions,
        currentUserRoles: roles,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // Opsional: tangani error
    }
  }
}