import 'package:flutter_bloc/flutter_bloc.dart';
import 'adminpanel_event.dart';
import 'adminpanel_state.dart';

class AdminPanelBloc extends Bloc<AdminPanelEvent, AdminPanelState> {
  AdminPanelBloc() : super(AdminPanelInitial()) {
    on<LoadAdminPanel>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AdminPanelLoaded(userName: 'Ferdi Yansah', userRole: 'RnD'));
    });
  }
}
