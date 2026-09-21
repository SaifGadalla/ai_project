import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/domain/usecases/path/get_user_paths_usecase.dart';
import 'package:ai_project/domain/usecases/auth/get_auth_state_usecase.dart';

abstract class PathsState extends Equatable {
  const PathsState();

  @override
  List<Object> get props => [];
}

class PathsInitial extends PathsState {}

class PathsLoading extends PathsState {}

class PathsLoaded extends PathsState {
  final List<LearningPath> paths;

  const PathsLoaded(this.paths);

  @override
  List<Object> get props => [paths];
}

class PathsError extends PathsState {
  final String message;

  const PathsError(this.message);

  @override
  List<Object> get props => [message];
}

class PathsCubit extends Cubit<PathsState> {
  final GetUserPathsUseCase _getUserPathsUseCase;
  final GetAuthStateUseCase _getAuthStateUseCase;
  StreamSubscription<List<LearningPath>>? _pathsSubscription;

  PathsCubit(this._getUserPathsUseCase, this._getAuthStateUseCase) : super(PathsInitial()) {
    _loadPaths();
  }

  void _loadPaths() {
    final userId = _getAuthStateUseCase.currentUser?.uid;
    if (userId == null) {
      emit(const PathsError('User not authenticated'));
      return;
    }

    emit(PathsLoading());

    _pathsSubscription?.cancel();
    _pathsSubscription = _getUserPathsUseCase(userId).listen(
      (paths) {
        emit(PathsLoaded(paths));
      },
      onError: (error) {
        emit(PathsError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _pathsSubscription?.cancel();
    return super.close();
  }
}
