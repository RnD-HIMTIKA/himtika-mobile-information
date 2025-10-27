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
import 'package:himtika_mobile_information/features/auth/domain/usecases/update_fcm_token.dart';

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
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_my_roles.dart'; 

// --- Calendar Imports ---
import 'package:himtika_mobile_information/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:himtika_mobile_information/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:himtika_mobile_information/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/bloc/workspace/workspace_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/create_workspace.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/get_events.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/create_event.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/bloc/event/event_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/update_event.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/delete_event.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/update_workspace.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/delete_workspace.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/invite_user_to_workspace.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/bloc/share_workspace/share_workspace_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/get_my_invitations.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/accept_invitation_by_id.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/accept_invitation_by_token.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/decline_invitation.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/search_users.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/create_invitation_link.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/invite_by_role.dart';
import 'package:himtika_mobile_information/features/calendar/domain/usecases/create_recurring_event.dart';

// --- Home Imports ---
import 'package:himtika_mobile_information/features/home/presentation/bloc/home_bloc.dart';
import 'package:himtika_mobile_information/features/home/data/datasources/home_remote_datasource.dart';
import 'package:himtika_mobile_information/features/home/data/repositories/home_repository_impl.dart';
import 'package:himtika_mobile_information/features/home/domain/repositories/home_repository.dart';
import 'package:himtika_mobile_information/features/home/domain/usecases/get_home_content.dart';

// --- Admin Panel Imports ---
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_dashboard_info.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_user.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/admin_panel_repository.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/roles_management_repository.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/get_admin_dashboard_info.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/get_assignable_roles.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/search_admin_users.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/update_user_roles.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/get_all_roles_grouped.dart';
import 'package:himtika_mobile_information/features/AdminPanel/data/datasources/admin_panel_remote_datasource.dart';
import 'package:himtika_mobile_information/features/AdminPanel/data/datasources/roles_management_remote_datasource.dart';
import 'package:himtika_mobile_information/features/AdminPanel/data/repositories/admin_panel_repository_impl.dart';
import 'package:himtika_mobile_information/features/AdminPanel/data/repositories/roles_management_repository_impl.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/roles_management/roles_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/hicode_management/hicode_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/repositories/hicode_management_repository.dart';
import 'package:himtika_mobile_information/features/AdminPanel/data/repositories/hicode_management_repository_impl.dart';
import 'package:himtika_mobile_information/features/AdminPanel/data/datasources/hicode_management_remote_datasource.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_hicode_categories.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_hicode_category.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/update_hicode_category.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/delete_hicode_category.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/category_management/category_management_bloc.dart';
// Import untuk HiCode Management Materi
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_admin_hicode_materials.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_hicode_material.dart';
// IMPORT USE CASES UNTUK CHAPTER MANAGEMENT:
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_chapters_by_material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/update_hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/delete_hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/reorder_hicode_chapters.dart';
// Import BLoC baru yang akan kita buat
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/material_management/material_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/chapter_management/chapter_management_bloc.dart';

// --- Hicode Imports ---
import 'package:himtika_mobile_information/features/hicode/domain/repositories/hicode_repository.dart';
import 'package:himtika_mobile_information/features/hicode/data/repositories/hicode_repository_impl.dart';
import 'package:himtika_mobile_information/features/hicode/data/datasources/hicode_remote_datasource.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/get_main_screen_data.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/get_chapter_list_data.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/main_screen/main_screen_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/chapter_detail/chapter_detail_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/sub_chapter_detail/sub_chapter_detail_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/get_chapter_content.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/get_questions.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/submit_quiz_answers.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/quiz/quiz_bloc.dart';

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
  sl.registerLazySingleton(() => UpdateFcmToken(sl<AuthRepository>()));
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
  sl.registerLazySingleton(() => GetMyRoles(rolesRepository: sl(), getCurrentUser: sl()));
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
  sl.registerLazySingleton(() => CreateWorkspace(sl()));
  sl.registerLazySingleton(() => GetEvents(sl()));
  sl.registerLazySingleton(() => CreateEvent(sl()));
  sl.registerLazySingleton(() => UpdateEvent(sl()));
  sl.registerLazySingleton(() => DeleteEvent(sl()));
  sl.registerLazySingleton(() => UpdateWorkspace(sl()));
  sl.registerLazySingleton(() => DeleteWorkspace(sl()));
  sl.registerLazySingleton(() => InviteUserToWorkspace(sl()));
  sl.registerLazySingleton(() => GetMyInvitations(sl()));
  sl.registerLazySingleton(() => AcceptInvitationById(sl()));
  sl.registerLazySingleton(() => AcceptInvitationByToken(sl()));
  sl.registerLazySingleton(() => DeclineInvitation(sl()));
  sl.registerLazySingleton(() => SearchUsers(sl()));
  sl.registerLazySingleton(() => CreateInvitationLink(sl()));
  sl.registerLazySingleton(() => InviteByRole(sl()));
  sl.registerLazySingleton(() => CreateRecurringEvent(sl()));
  // BLoCs
  sl.registerFactory(() => WorkspaceBloc(
        calendarRepository: sl(),
        createWorkspace: sl(),
        updateWorkspace: sl(),
        deleteWorkspace: sl(),
      ));
  sl.registerFactory(() => EventBloc(
        getEvents: sl(),
        createEvent: sl(),
        updateEvent: sl(),
        deleteEvent: sl(),
        createRecurringEvent: sl(),
      ));
  sl.registerFactory(() => ShareWorkspaceBloc(
        inviteUserToWorkspace: sl(),
        searchUsers: sl(),
        createInvitationLink: sl(),
        inviteByRole: sl(),
      ));
  sl.registerFactory(() => InvitationBloc(
        getMyInvitations: sl(),
        acceptInvitationById: sl(),
        acceptInvitationByToken: sl(),
        declineInvitation: sl(),
      ));
  

  // ==================== HOME FEATURE ====================
  // Datasource
  sl.registerLazySingleton<HomeRemoteDatasource>(
      () => HomeRemoteDatasourceImpl(client: sl()));
  // Repository
  sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDatasource: sl()));
  // Usecases
  sl.registerLazySingleton(() => GetHomeContent(sl()));
  // BLoCs
  sl.registerFactory(() => HomeBloc(
        getCurrentUser: sl(),
        getMyRoles: sl(),
        getHomeContent: sl(),
      ));

  // ==================== ADMIN PANEL FEATURE ====================
  // Datasource
  sl.registerLazySingleton<AdminPanelRemoteDatasource>(
      () => AdminPanelRemoteDatasourceImpl(client: sl()));
  sl.registerLazySingleton<RolesManagementRemoteDatasource>( // <-- BARU
      () => RolesManagementRemoteDatasourceImpl(client: sl()));
  // Repository
  sl.registerLazySingleton<AdminPanelRepository>(
      () => AdminPanelRepositoryImpl(remoteDatasource: sl()));
  sl.registerLazySingleton<RolesManagementRepository>( // <-- BARU
      () => RolesManagementRepositoryImpl(remoteDatasource: sl()));
  // Usecases
  sl.registerLazySingleton(() => GetAdminDashboardInfo(sl()));
  sl.registerLazySingleton(() => SearchAdminUsers(sl())); // <-- BARU
  sl.registerLazySingleton(() => GetAssignableRoles(sl())); // <-- BARU
  sl.registerLazySingleton(() => UpdateUserRoles(sl())); // <-- BARU
  sl.registerLazySingleton(() => GetAllRolesGrouped(sl()));
  // BLoCs
  sl.registerFactory(() => AdminPanelBloc(
        getAdminDashboardInfo: sl(),
        getMyRoles: sl(), // <-- TAMBAHKAN INI
      ));
  sl.registerFactory(() => RolesManagementBloc( // <-- BARU
        searchAdminUsers: sl(),
        getAssignableRoles: sl(),
        updateUserRoles: sl(),
        getAllRolesGrouped: sl(),
      ));

  // ==================== ADMIN PANEL HICODE MANAGEMENT ====================
  // Datasource
  sl.registerLazySingleton<HiCodeManagementRemoteDatasource>(
      () => HiCodeManagementRemoteDatasourceImpl(client: sl()));

  // Repository
  sl.registerLazySingleton<HiCodeManagementRepository>(
      () => HiCodeManagementRepositoryImpl(remoteDatasource: sl()));

  // Usecases (Category)
  sl.registerLazySingleton(() => GetHiCodeCategories(sl()));
  sl.registerLazySingleton(() => CreateHiCodeCategory(sl()));
  sl.registerLazySingleton(() => UpdateHiCodeCategory(sl()));
  sl.registerLazySingleton(() => DeleteHiCodeCategory(sl()));

  // Usecases (Material)
  sl.registerLazySingleton(() => GetAdminHiCodeMaterials(sl()));
  sl.registerLazySingleton(() => CreateHiCodeMaterial(sl()));
  // TODO: Tambahkan Usecase UpdateHiCodeMaterial dan DeleteHiCodeMaterial nanti

  // --- TAMBAHKAN REGISTRASI USE CASES CHAPTER DI SINI ---
  sl.registerLazySingleton(() => GetChaptersByMaterial(sl()));
  sl.registerLazySingleton(() => CreateHiCodeChapter(sl()));
  sl.registerLazySingleton(() => UpdateHiCodeChapter(sl()));
  sl.registerLazySingleton(() => DeleteHiCodeChapter(sl()));
  sl.registerLazySingleton(() => ReorderHiCodeChapters(sl()));
  // --- END TAMBAHAN USE CASES CHAPTER ---

  // BLoCs
  sl.registerFactory(() => CategoryManagementBloc(
        getCategories: sl(),
        createCategory: sl(),
        updateCategory: sl(),
        deleteCategory: sl(),
      ));
  sl.registerFactory(() => MaterialManagementBloc(
        getAdminHiCodeMaterials: sl(),
        createHiCodeMaterial: sl(),
        getHiCodeCategories: sl(),
      ));

  // --- TAMBAHKAN REGISTRASI BLOC CHAPTER DI SINI ---
  sl.registerFactory(() => ChapterManagementBloc(
       getChaptersByMaterial: sl(),
       createChapter: sl(),
       updateChapter: sl(),
       deleteChapter: sl(),
       reorderChapters: sl(),
     ));

  // ==================== HICODE FEATURE ====================
  // Datasource
  sl.registerLazySingleton<HiCodeRemoteDatasource>(
      () => HiCodeRemoteDatasourceImpl(client: sl(), getCurrentUser: sl()));
  // Repository
  sl.registerLazySingleton<HiCodeRepository>(
      () => HiCodeRepositoryImpl(remoteDatasource: sl()));
  // Usecases
  sl.registerLazySingleton(() => GetMainScreenData(sl()));
  sl.registerLazySingleton(() => GetChapterListData(sl()));
  sl.registerLazySingleton(() => GetQuestions(sl()));
  sl.registerLazySingleton(() => SubmitQuizAnswers(sl()));
  // BLoCs
  sl.registerFactory(() => HicodeBloc(getMainScreenData: sl()));
  sl.registerFactory(() => MaterialDetailBloc(getChapterListData: sl()));
  sl.registerLazySingleton(() => GetChapterContent(sl()));
  sl.registerFactory(() => QuizBloc(getQuestions: sl(), submitQuizAnswers: sl()));
}