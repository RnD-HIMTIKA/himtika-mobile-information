import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import '../repositories/calendar_repository.dart';

class SearchUsers {
  final CalendarRepository repository;

  SearchUsers(this.repository);

  // Mengambil query pencarian dan mengembalikan daftar User
  Future<List<User>> call(String query) async {
    return await repository.searchUsers(query);
  }
}