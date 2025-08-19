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


final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Supabase client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<AuthRemoteDataSource>()));

  // Usecases
  sl.registerLazySingleton(() => SignInWithEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()));
  
  // PERBARUI BARIS INI: Tambahkan sl<SupabaseClient>()
  sl.registerLazySingleton(() => SignUpWithEmail(sl<AuthRepository>(), sl<SupabaseClient>()));
  
  sl.registerLazySingleton(() => VerifyOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResendSignUpOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));
  
  sl.registerLazySingleton(() => GetProfileFormData(sl<AuthRepository>(), sl<SupabaseClient>()));
  sl.registerLazySingleton(() => SubmitProfileForm(sl<AuthRepository>(), sl<SupabaseClient>()));
  sl.registerLazySingleton(() => CheckUserProfileCompleteness(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ValidateProfileStep1(sl<SupabaseClient>()));

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
        
  // Application Controllers
  sl.registerLazySingleton(() => AuthController());
}