import 'package:himtika_mobile_information/features/hicode/data/models/hicode_category_model.dart';
import 'package:himtika_mobile_information/features/hicode/data/models/hicode_material_model.dart';
import 'package:himtika_mobile_information/features/hicode/data/models/hicode_chapter_model.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_material.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_chapter.dart';
import 'package:himtika_mobile_information/features/hicode/domain/repositories/hicode_repository.dart';
import '../datasources/hicode_remote_datasource.dart';
import '../models/hicode_chapter_content_model.dart';
import '../../domain/entities/hicode_chapter_content.dart';
import '../models/hicode_question_model.dart';
import '../../domain/entities/hicode_question.dart';
import '../models/quiz_result_model.dart';
import '../../domain/entities/quiz_result.dart';

class HiCodeRepositoryImpl implements HiCodeRepository {
  final HiCodeRemoteDatasource remoteDatasource;
  HiCodeRepositoryImpl({required this.remoteDatasource});

  @override
  Future<(List<HiCodeCategory>, List<HiCodeMaterial>, bool)> getMainScreenData() async {
    final data = await remoteDatasource.getMainScreenData();
    
    final categories = (data['categories'] as List)
        .map((category) => HiCodeCategoryModel.fromMap(category))
        .toList();
        
    final materials = (data['materials'] as List)
        .map((material) => HiCodeMaterialModel.fromMap(material))
        .toList();
        
    final isExamReady = data['is_exam_ready'] as bool;

    return (categories, materials, isExamReady);
  }

  @override
  Future<(String, String, String, List<HiCodeChapter>)> getChapterListData(String materialId) async {
    final data = await remoteDatasource.getChapterListData(materialId);

    final title = data['title'] as String;
    final description = data['description'] as String;
    final iconPath = data['icon_path'] as String;
    final chapters = (data['chapters'] as List)
        .map((chapter) => HiCodeChapterModel.fromMap(chapter))
        .toList();

    return (title, description, iconPath, chapters);
  }

  @override
  Future<HiCodeChapterContent> getChapterContent(String chapterId) async {
    final data = await remoteDatasource.getChapterContent(chapterId);
    return HiCodeChapterContentModel.fromMap(data);
  }

  @override
  Future<List<HiCodeQuestion>> getQuestions(String relatedId, String questionType) async {
    final data = await remoteDatasource.getQuestions(relatedId, questionType);
    return data.map((q) => HiCodeQuestionModel.fromMap(q)).toList();
  }

  @override
  Future<QuizResult> submitAnswers(Map<String, String> answers) async {
    final data = await remoteDatasource.submitAnswers(answers);
    return QuizResultModel.fromMap(data);
  }
}