import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Auth Imports ---
import 'package:himtika_mobile_information/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:himtika_mobile_information/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:himtika_mobile_information/features/auth/domain/repositories/auth_repository.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/sign_out.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/validate_profile_step1.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:himtika_mobile_information/features/auth/application/auth_controller.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/check_user_profile_completeness.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_profile_form_data.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/submit_profile_form.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/profile_form/form_bloc.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/resend_signup_otp.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/verify_otp.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/otp/otp_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/registration/registration_bloc.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/send_password_reset_otp.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/verify_password_reset_otp.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/update_user_password.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/forgot_password/forgot_password_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/verify_reset_otp/verify_reset_otp_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/reset_password/reset_password_bloc.dart';

// --- Roles Imports ---
import 'package:himtika_mobile_information/features/roles/data/datasources/roles_remote_datasource.dart';
import 'package:himtika_mobile_information/features/roles/data/repositories/roles_repository_impl.dart';
import 'package:himtika_mobile_information/features/roles/domain/repositories/roles_repository.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/assign_permission_to_role.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/assign_role.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_all_roles.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_permissions_by_role.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_roles_by_user.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_user_permissions.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/revoke_permission_from_role.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/revoke_role.dart';
import 'package:himtika_mobile_information/features/roles/application/roles_controller/roles_controller.dart';

// --- Calendar Imports ---
import 'package:himtika_mobile_information/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:himtika_mobile_information/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:himtika_mobile_information/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/get_my_workspaces.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/bloc/workspace/workspace_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/create_workspace.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Supabase client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ==================== AUTH FEATURE ====================
  // Datasource
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<AuthRemoteDataSource>()));
  // Usecases
  sl.registerLazySingleton(() => SignInWithEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl<AuthRepository>(), sl<SupabaseClient>()));
  sl.registerLazySingleton(() => VerifyOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResendSignUpOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetProfileFormData(sl<AuthRepository>(), sl<SupabaseClient>()));
  sl.registerLazySingleton(() => SubmitProfileForm(sl<AuthRepository>(), sl<SupabaseClient>()));
  sl.registerLazySingleton(() => CheckUserProfileCompleteness(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ValidateProfileStep1(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => SendPasswordResetOtp(sl<AuthRepository>(), sl<SupabaseClient>()));
  sl.registerLazySingleton(() => VerifyPasswordResetOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateUserPassword(sl<AuthRepository>()));
  // BLoCs
  sl.registerFactory(() => LoginBloc(
        signInWithEmail: sl<SignInWithEmail>(),
        signInWithGoogle: sl<SignInWithGoogle>(),
        getCurrentUser: sl<GetCurrentUser>(),
      ));
  sl.registerFactory(() => ProfileFormBloc(
        getProfileFormData: sl<GetProfileFormData>(),
        submitProfileForm: sl<SubmitProfileForm>(),
        validateProfileStep1: sl<ValidateProfileStep1>(),
      ));
  sl.registerFactory(() => RegistrationBloc(signUpWithEmail: sl<SignUpWithEmail>()));
  sl.registerFactory(() => OtpBloc(
        verifyOtp: sl<VerifyOtp>(),
        resendSignUpOtp: sl<ResendSignUpOtp>(),
      ));

  sl.registerFactory(() => ForgotPasswordBloc(sendPasswordResetOtp: sl<SendPasswordResetOtp>()));
  sl.registerFactory(() => VerifyResetOtpBloc(verifyPasswordResetOtp: sl<VerifyPasswordResetOtp>()));
  sl.registerFactory(() => ResetPasswordBloc(updateUserPassword: sl<UpdateUserPassword>()));
  // Controller
  sl.registerLazySingleton(() => AuthController());


  // ==================== ROLES FEATURE ====================
  // Datasource
  sl.registerLazySingleton<RolesRemoteDatasource>(() => RolesRemoteDatasource());
  // Repository
  sl.registerLazySingleton<RolesRepository>(() => RolesRepositoryImpl(sl<RolesRemoteDatasource>()));
  // Usecases
  sl.registerLazySingleton(() => AssignPermissionToRole(sl<RolesRepository>()));
  sl.registerLazySingleton(() => AssignRole(sl<RolesRepository>()));
  sl.registerLazySingleton(() => GetAllRoles(sl<RolesRepository>()));
  sl.registerLazySingleton(() => GetPermissionsByRole(sl<RolesRepository>()));
  sl.registerLazySingleton(() => GetRolesByUser(sl<RolesRepository>()));
  sl.registerLazySingleton(() => GetUserPermissions(sl<RolesRepository>()));
  sl.registerLazySingleton(() => RevokePermissionFromRole(sl<RolesRepository>()));
  sl.registerLazySingleton(() => RevokeRole(sl<RolesRepository>()));

  // Controller
  sl.registerLazySingleton<IRolesController>(() => RolesController(
        getUserPermissions: sl<GetUserPermissions>(),
        getPermissionsByRoleUsecase: sl<GetPermissionsByRole>(),
        getAllRoles: sl<GetAllRoles>(),
        getRolesByUser: sl<GetRolesByUser>(),
      ));

  // ==================== CALENDAR FEATURE ====================
  // Datasource
  sl.registerLazySingleton<CalendarRemoteDatasource>(() => CalendarRemoteDatasource(sl(), sl<GetCurrentUser>()));
  // Repository
  sl.registerLazySingleton<CalendarRepository>(() => CalendarRepositoryImpl(
        remoteDatasource: sl(),
        getCurrentUser: sl(),
      ));
  // Usecases
  sl.registerLazySingleton(() => GetMyWorkspaces(sl()));
  sl.registerLazySingleton(() => CreateWorkspace(sl()));
  // BLoC
  sl.registerFactory(() => WorkspaceBloc(
        calendarRepository: sl(),
        createWorkspace: sl(),
      ));

}