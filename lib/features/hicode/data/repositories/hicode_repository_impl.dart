import 'package:himtika_mobile_information/features/hicode/data/models/hicode_category_model.dart';
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
import '../../domain/entities/leaderboard_entry.dart';
import '../models/leaderboard_entry_model.dart';

class HiCodeRepositoryImpl implements HiCodeRepository {
  final HiCodeRemoteDatasource remoteDatasource;
  HiCodeRepositoryImpl({required this.remoteDatasource});

  @override
  Future<(List<HiCodeCategory>, List<HiCodeMaterial>, bool)> getMainScreenData() async {
    // Panggil datasource yang sudah diupdate
    final data = await remoteDatasource.getMainScreenData();

    // Parsing categories (seharusnya tidak berubah)
    final categories = (data['categories'] as List? ?? [])
        .map((category) => HiCodeCategoryModel.fromMap(category))
        .toList();

    // Parsing materials (sekarang menyertakan progress)
    final materials = (data['materials'] as List? ?? [])
        .map((material) {
          // Buat instance HiCodeMaterial langsung dari map JSON
          return HiCodeMaterial(
            id: material['id'],
            title: material['title'],
            imageUrl: material['image_url'],
            borderColor: material['border_color'],
            totalChapters: (material['total_chapters'] as int?) ?? 0,
            completedChapters: (material['completed_chapters'] as int?) ?? 0,
          );
        })
        .toList();

    // Ambil is_exam_ready
    final isExamReady = data['is_exam_ready'] as bool? ?? false;

    return (categories, materials, isExamReady);
  }

  @override
  // Perbarui tipe kembalian untuk menyertakan final_practice_status
  Future<(String title, String description, String iconPath, List<HiCodeChapter> chapters, String finalPracticeStatus)> getChapterListData(String materialId) async {
    // Panggil datasource yang sudah diupdate
    final data = await remoteDatasource.getChapterListData(materialId);

    final title = data['title'] as String? ?? 'Tanpa Judul';
    final description = data['description'] as String? ?? '';
    final iconPath = data['icon_path'] as String? ?? ''; // Atau path default
    final finalPracticeStatus = data['final_practice_status'] as String? ?? 'locked';

    // Parsing chapters dengan status baru
    final chapters = (data['chapters'] as List? ?? [])
        .map((chapter) {
          // Buat instance HiCodeChapter langsung dari map JSON
          return HiCodeChapter(
            id: chapter['id'],
            title: chapter['title'],
            details: chapter['details'] ?? 'Info tidak tersedia',
            isCompleted: chapter['is_completed'] ?? false,
            isLocked: chapter['is_locked'] ?? true, // Default terkunci jika data tidak ada
          );
        })
        .toList();

    return (title, description, iconPath, chapters, finalPracticeStatus);
  }


  @override
  Future<HiCodeChapterContent> getChapterContent(String chapterId, String userId) async {
    // Teruskan userId ke datasource
    final data = await remoteDatasource.getChapterContent(chapterId, userId);
    // Parsing model sudah diupdate untuk handle field baru
    return HiCodeChapterContentModel.fromMap(data);
  }

  @override
  Future<List<HiCodeQuestion>> getQuestions(String relatedId, String questionType) async {
    final data = await remoteDatasource.getQuestions(relatedId, questionType);
    return data.map((q) => HiCodeQuestionModel.fromMap(q)).toList();
  }

  @override
  Future<QuizResult> submitAnswers(Map<String, String> answers, {int? timeTakenSeconds}) async {
    // Teruskan parameter waktu ke datasource
    final data = await remoteDatasource.submitAnswers(answers, timeTakenSeconds: timeTakenSeconds);
    return QuizResultModel.fromMap(data);
  }

  @override
  Future<void> updateScrollPosition(String chapterId, double position, bool hasReachedBottom) async {
     // Teruskan ke datasource
     await remoteDatasource.updateScrollPosition(chapterId, position, hasReachedBottom);
  }
  @override
  Future<List<LeaderboardEntry>> getLeaderboard(String filter) async { // <-- Tambahkan ini nanti
    final data = await remoteDatasource.getLeaderboard(filter);
    return data.map((map) => LeaderboardEntryModel.fromMap(map)).toList();
  }
}