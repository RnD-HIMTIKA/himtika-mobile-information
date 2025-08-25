import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import 'package:himtika_mobile_information/features/home/domain/entities/division.dart';
import 'package:himtika_mobile_information/features/home/domain/entities/home_banner.dart';

class HomeState extends Equatable {
  final User? currentUser;
  final bool isPengurus;
  final bool isLoading;
  final List<HomeBanner> banners;
  final List<Division> divisions;
  final List<Role> currentUserRoles;

  const HomeState({
    this.currentUser,
    this.isPengurus = false,
    this.isLoading = false,
    this.banners = const [],
    this.divisions = const [],
    this.currentUserRoles = const [],
  });

  HomeState copyWith({
    User? currentUser,
    bool? isPengurus,
    bool? isLoading,
    List<HomeBanner>? banners,
    List<Division>? divisions,
    List<Role>? currentUserRoles,
  }) {
    return HomeState(
      currentUser: currentUser ?? this.currentUser,
      isPengurus: isPengurus ?? this.isPengurus,
      isLoading: isLoading ?? this.isLoading,
      banners: banners ?? this.banners,
      divisions: divisions ?? this.divisions,
      currentUserRoles: currentUserRoles ?? this.currentUserRoles,
    );
  }

  @override
  List<Object?> get props => [currentUser, isPengurus, isLoading, banners, divisions, currentUserRoles];
}