import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:himtika_mobile_information/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:himtika_mobile_information/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:himtika_mobile_information/features/auth/domain/repositories/auth_repository.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/sign_out.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/login/login_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Supabase client (already initialized elsewhere)
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(sl<SupabaseClient>()));

  // Repository (bind to interface)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<AuthRemoteDataSource>()));

  // Usecases
  sl.registerLazySingleton(() => SignInWithEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));

  // BLoCs (factory so UI gets new instance when needed)
  sl.registerFactory(() => LoginBloc(
        signInWithEmail: sl<SignInWithEmail>(),
        signInWithGoogle: sl<SignInWithGoogle>(),
        getCurrentUser: sl<GetCurrentUser>(),
      ));

  // (Nanti: register ProfileFormBloc, AdminPanelBloc, dsb)
}