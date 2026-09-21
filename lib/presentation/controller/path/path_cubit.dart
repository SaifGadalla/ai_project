import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/domain/usecases/path/get_path_stream_usecase.dart';
import 'package:ai_project/domain/usecases/path/delete_path_usecase.dart';
import 'package:ai_project/domain/usecases/auth/get_auth_state_usecase.dart';

abstract class PathState extends Equatable {
  const PathState();

  @override
  List<Object?> get props => [];
}

class PathInitial extends PathState {}

class PathLoading extends PathState {}

class PathLoaded extends PathState {
  final LearningPath path;

  const PathLoaded(this.path);

  @override
  List<Object?> get props => [path];
}

class PathNotFound extends PathState {}

class PathError extends PathState {
  final String message;

  const PathError(this.message);

  @override
  List<Object?> get props => [message];
}

class PathCubit extends Cubit<PathState> {
  final String _pathId;
  final GetPathStreamUseCase _getPathStreamUseCase;
  final DeletePathUseCase _deletePathUseCase;
  final GetAuthStateUseCase _getAuthStateUseCase;
  StreamSubscription<LearningPath?>? _pathSubscription;

  PathCubit({
    required this._pathId,
    required this._getPathStreamUseCase,
    required this._deletePathUseCase,
    required this._getAuthStateUseCase,
  }) : super(PathInitial()) {
    _loadPath();
  }

  void _loadPath() {
    final userId = _getAuthStateUseCase.currentUser?.uid;
    if (userId == null) {
      emit(const PathError('User not authenticated'));
      return;
    }

    emit(PathLoading());

    _pathSubscription?.cancel();
    _pathSubscription = _getPathStreamUseCase(userId, _pathId).listen(
      (path) {
        if (path != null) {
          emit(PathLoaded(path));
        } else {
          emit(PathNotFound());
        }
      },
      onError: (error) {
        emit(PathError(error.toString()));
      },
    );
  }

  Future<void> deletePath() async {
    final userId = _getAuthStateUseCase.currentUser?.uid;
    if (userId != null) {
      await _deletePathUseCase(userId, _pathId);
    }
  }

  @override
  Future<void> close() {
    _pathSubscription?.cancel();
    return super.close();
  }
}
