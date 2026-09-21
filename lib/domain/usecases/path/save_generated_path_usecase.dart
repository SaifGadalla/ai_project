import 'package:ai_project/domain/repository/path_repository.dart';

class SaveGeneratedPathUseCase {
  final PathRepository _repository;

  SaveGeneratedPathUseCase(this._repository);

  Future<String> call({
    required String userId,
    required Map<String, dynamic> pathData,
    required String originalPrompt,
  }) {
    return _repository.savePath(
      userId: userId,
      pathData: pathData,
      originalPrompt: originalPrompt,
    );
  }
}
