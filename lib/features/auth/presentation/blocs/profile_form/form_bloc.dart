import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'form_event.dart';
import 'form_state.dart';

class ProfileFormBloc extends Bloc<ProfileFormEvent, ProfileFormState> {
  final SupabaseClient client;

  ProfileFormBloc(this.client) : super(const ProfileFormState()) {
    on<ProfileFormStarted>(_onStarted);
    on<ProfileFormNextStep>(_onNextStep);
    on<ProfileFormPrevStep>(_onPrevStep);
    on<ProfileFormSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
      ProfileFormStarted event, Emitter<ProfileFormState> emit) async {
    emit(state.copyWith(status: ProfileFormStatus.loading, clearError: true));
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Ambil public.users by auth_id
      final userRow = await client
          .from('users')
          .select('id, is_from_unsika, email, username')
          .eq('auth_id', authUser.id)
          .maybeSingle();

      if (userRow == null) {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage: 'User not found',
        ));
        return;
      }

      final String userId = userRow['id'] as String;
      final bool isFromUnsika = (userRow['is_from_unsika'] as bool?) ?? false;
      final String? email = userRow['email'] as String?;
      // Username tidak di-prefill, set null agar user isi manual
      final String? username = null;

      String? angkatan;
      String? fakultas;
      String? prodi;

      if (isFromUnsika) {
        final rolesRef = await client
            .from('user_roles')
            .select('role_id')
            .eq('user_id', userId);

        final roleIds = (rolesRef as List)
            .map((e) => (e as Map)['role_id'] as String)
            .toList();

        if (roleIds.isNotEmpty) {
          final roles = await client
              .from('roles')
              .select('name, group_name')
              .inFilter('id', roleIds);

          for (final r in (roles as List)) {
            final m = r as Map<String, dynamic>;
            final g = (m['group_name'] as String?)?.toLowerCase();
            final n = m['name'] as String?;
            if (g == 'angkatan') angkatan = n;
            if (g == 'fakultas') fakultas = n;
            if (g == 'prodi') prodi = n;
          }
        }
      }

      emit(state.copyWith(
        status: ProfileFormStatus.loaded,
        isFromUnsika: isFromUnsika,
        email: email,
        username: username, // Null, tidak prefill
        angkatan: angkatan,
        fakultas: fakultas,
        prodi: prodi,
        currentStep: 0,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: 'Error fetching data: $e',
      ));
    }
  }

  void _onNextStep(
      ProfileFormNextStep event, Emitter<ProfileFormState> emit) {
    final lastIndex = state.totalSteps - 1;
    if (state.currentStep < lastIndex) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPrevStep(
      ProfileFormPrevStep event, Emitter<ProfileFormState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _onSubmitted(
      ProfileFormSubmitted event, Emitter<ProfileFormState> emit) async {
    emit(state.copyWith(status: ProfileFormStatus.submitting, clearError: true));
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // 1) VALIDASI INPUT
      final validationError = _validateInputs(
        isFromUnsika: state.isFromUnsika,
        fullName: event.fullName,
        username: event.username,
        email: event.email,
        phone: event.phone,
        dob: event.dob,
        kelas: event.kelas,
      );
      if (validationError != null) {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage: validationError,
        ));
        return;
      }

      // Normalisasi beberapa field
      final normalizedUsername = event.username.trim();
      final normalizedPhone = _normalizePhone(event.phone.trim());
      final isoDob = _toIsoDateOrNull(event.dob.trim());
      final kelas = state.isFromUnsika ? (event.kelas ?? '').trim() : null;

      // 3) CEK DUPLIKASI USERNAME (case-insensitive)
      final unameDup = await client
          .from('users')
          .select('auth_id')
          .ilike('username', normalizedUsername)
          .neq('auth_id', authUser.id)
          .maybeSingle();

      if (unameDup != null) {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage:
              'Username sudah digunakan. Pilih username lain (huruf/angka/._, 3–20 char).',
        ));
        return;
      }

      // 4) CEK DUPLIKASI NOMOR TELEPON
      if (normalizedPhone == null) {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage: 'Nomor telepon tidak valid setelah normalisasi.',
        ));
        return;
      }

      final phoneDup = await client
          .from('users')
          .select('auth_id')
          .eq('phone_number', normalizedPhone)
          .neq('auth_id', authUser.id)
          .maybeSingle();

      if (phoneDup != null) {
        emit(state.copyWith(
          status: ProfileFormStatus.failure,
          errorMessage: 'Nomor telepon sudah digunakan.',
        ));
        return;
      }

      // 5) GET USER ID
      final userRow = await client
          .from('users')
          .select('id')
          .eq('auth_id', authUser.id)
          .single();

      final String userId = userRow['id'] as String;

      // 6) HANDLE KELAS AS ROLE (jika isFromUnsika)
      if (state.isFromUnsika && kelas != null && kelas.isNotEmpty) {
        // Cari role dengan name=kelas dan group_name='Kelas'
        final roleRow = await client
            .from('roles')
            .select('id')
            .eq('name', kelas)
            .eq('group_name', 'Kelas')
            .maybeSingle();

        String roleId;
        if (roleRow == null) {
          // Buat role baru jika tidak ada
          final newRole = await client
              .from('roles')
              .insert({
                'name': kelas,
                'group_name': 'Kelas',
              })
              .select('id')
              .single();
          roleId = newRole['id'] as String;
        } else {
          roleId = roleRow['id'] as String;
        }

        // Upsert ke user_roles (replace jika sudah ada)
        await client.from('user_roles').upsert({
          'user_id': userId,
          'role_id': roleId,
        }, onConflict: 'user_id,role_id');
      }

      // 7) UPDATE TABLE users
      final payload = <String, dynamic>{
        'full_name': event.fullName.trim(),
        'username': normalizedUsername,
        'phone_number': normalizedPhone,
      };
      if (isoDob != null) payload['date_of_birth'] = isoDob; // Match schema column

      await client.from('users').update(payload).eq('auth_id', authUser.id);

      emit(state.copyWith(status: ProfileFormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: 'Gagal menyimpan data: $e',
      ));
    }
  }

  // ---------- Helpers ----------

  String? _validateInputs({
    required bool isFromUnsika,
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String dob,
    required String? kelas,
  }) {
    final name = fullName.trim();
    final uname = username.trim();
    final mail = email.trim();
    final ph = phone.trim();
    final birth = dob.trim();

    if (name.isEmpty || name.length < 2) {
      return 'Nama lengkap minimal 2 karakter.';
    }

    // Username: huruf/angka/._ ; panjang 3–20
    final unameOk = RegExp(r'^[a-zA-Z0-9._]{3,20}$').hasMatch(uname);
    if (!unameOk) {
      return 'Username hanya boleh huruf/angka/._ dan 3–20 karakter.';
    }

    // Email basic check
    final emailOk = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(mail);
    if (!emailOk) {
      return 'Format email tidak valid.';
    }

    // Phone: validasi sebelum normalisasi
    final normalizedPh = _normalizePhone(ph);
    if (normalizedPh == null) {
      return 'Nomor telepon harus 10–15 digit, mulai dengan 0 (akan diubah ke +62).';
    }

    // DOB dd/mm/yyyy & tidak boleh di masa depan
    final dt = _parseDob(birth);
    if (dt == null) {
      return 'Tanggal lahir tidak valid (gunakan format dd/mm/yyyy).';
    }
    final now = DateTime.now();
    if (dt.isAfter(DateTime(now.year, now.month, now.day))) {
      return 'Tanggal lahir tidak boleh di masa depan.';
    }

    // Kelas wajib jika from UNSIKA
    if (isFromUnsika) {
      if (kelas == null || kelas.trim().isEmpty) {
        return 'Silakan pilih Kelas.';
      }
      final allowed = const ['A', 'B', 'C', 'D', 'E', 'F'];
      if (!allowed.contains(kelas.trim())) {
        return 'Kelas tidak valid.';
      }
    }

    return null;
  }

  DateTime? _parseDob(String ddmmyyyy) {
    final p = ddmmyyyy.split('/');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    try {
      final dt = DateTime(y, m, d);
      if (dt.year != y || dt.month != m || dt.day != d) return null;
      return dt;
    } catch (_) {
      return null;
    }
  }

  String? _toIsoDateOrNull(String ddmmyyyy) {
    final dt = _parseDob(ddmmyyyy);
    if (dt == null) return null;
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }

  String? _normalizePhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('0') && clean.length >= 10 && clean.length <= 15) {
      return '+62${clean.substring(1)}';
    } else if (clean.startsWith('62') && clean.length >= 11 && clean.length <= 16) {
      return '+$clean';
    }
    return null;
  }
}