import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase Client

part 'hicode_management_event.dart';
part 'hicode_management_state.dart';

class HicodeManagementBloc extends Bloc<HicodeManagementEvent, HicodeManagementState> {
  final SupabaseClient _client;

  HicodeManagementBloc({required SupabaseClient client})
      : _client = client,
        super(const HicodeManagementState()) {
    on<LoadHicodeMaterials>(_onLoadHicodeMaterials);
  }

  Future<void> _onLoadHicodeMaterials(
      LoadHicodeMaterials event, Emitter<HicodeManagementState> emit) async {
    emit(state.copyWith(status: HicodeManagementStatus.loading));
    try {
      final data = await _client.rpc('get_admin_hicode_materials');
      final materials = List<Map<String, dynamic>>.from(data);
      emit(state.copyWith(status: HicodeManagementStatus.success, materials: materials));
    } catch (e) {
      emit(state.copyWith(status: HicodeManagementStatus.failure, errorMessage: e.toString()));
    }
  }
}