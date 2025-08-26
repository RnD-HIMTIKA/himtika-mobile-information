import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_question.dart';
import '../repositories/hicode_repository.dart';

class GetQuestions {
  final HiCodeRepository repository;
  GetQuestions(this.repository);

  Future<List<HiCodeQuestion>> call(String relatedId, String questionType) {
    return repository.getQuestions(relatedId, questionType);
  }
}