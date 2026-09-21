import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/domain/repository/ai_repository.dart';
import 'package:ai_project/domain/usecases/path/save_generated_path_usecase.dart';
import 'package:ai_project/domain/usecases/auth/get_auth_state_usecase.dart';

// --- Models ---
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// --- Events ---
abstract class CreationEvent {}

class SendMessage extends CreationEvent {
  final String text;
  SendMessage(this.text);
}

class FinalizePath extends CreationEvent {}

// --- States ---
abstract class CreationState {}

class CreationChatActive extends CreationState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool canGenerate;

  CreationChatActive({
    required this.messages,
    required this.isTyping,
    required this.canGenerate,
  });
}

class CreationLoading
    extends CreationState {} // Used when generating final JSON

class CreationSuccess extends CreationState {
  final String pathId;
  CreationSuccess(this.pathId);
}

class CreationFailure extends CreationState {
  final String error;
  CreationFailure(this.error);
}

// --- BLoC ---
class CreationBloc extends Bloc<CreationEvent, CreationState> {
  final AppLocalizations localizations;
  final AiRepository _aiRepository;
  final SaveGeneratedPathUseCase _saveGeneratedPathUseCase;
  final GetAuthStateUseCase _getAuthStateUseCase;

  final List<ChatMessage> _uiMessages = [];

  CreationBloc({
    required this.localizations,
    required this._aiRepository,
    required this._saveGeneratedPathUseCase,
    required this._getAuthStateUseCase,
  }) : super(
         CreationChatActive(
           messages: [
             ChatMessage(
               text: localizations.promptInitialMessage,
               isUser: false,
             ),
           ],
           isTyping: false,
           canGenerate: false,
         ),
       ) {
    _uiMessages.addAll((state as CreationChatActive).messages);

    on<SendMessage>(_onSendMessage);
    on<FinalizePath>(_onFinalizePath);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<CreationState> emitter,
  ) async {
    // Add user message to UI
    _uiMessages.add(ChatMessage(text: event.text, isUser: true));
    emitter(
      CreationChatActive(
        messages: List.from(_uiMessages),
        isTyping: true,
        canGenerate: false,
      ),
    );

    try {
      // Send to AI Repository
      final aiResponseText = await _aiRepository.sendMessage(event.text);
      final finalResponse = aiResponseText.isEmpty
          ? localizations.promptErrorNoResponse
          : aiResponseText;

      _uiMessages.add(ChatMessage(text: finalResponse, isUser: false));

      // Once the user has sent at least one message, allow generation
      final canGen = _uiMessages.where((m) => m.isUser).isNotEmpty;

      emitter(
        CreationChatActive(
          messages: List.from(_uiMessages),
          isTyping: false,
          canGenerate: canGen,
        ),
      );
    } catch (e) {
      Logger('General Error').finer(e);

      // We still want to handle the Firebase exception if it bubbles up from the repository
      if (e.toString().contains('firebase')) {
        _uiMessages.add(
          ChatMessage(text: localizations.promptErrorSafety, isUser: false),
        );
      } else {
        _uiMessages.add(
          ChatMessage(text: localizations.promptErrorGeneric, isUser: false),
        );
      }

      emitter(
        CreationChatActive(
          messages: List.from(_uiMessages),
          isTyping: false,
          canGenerate: true,
        ),
      );
    }
  }

  Future<void> _onFinalizePath(
    FinalizePath event,
    Emitter<CreationState> emitter,
  ) async {
    emitter(CreationLoading());

    try {
      final userId = _getAuthStateUseCase.currentUser?.uid;
      if (userId == null) {
        emitter(CreationFailure(localizations.promptErrorUnauthenticated));
        return;
      }

      // 1. Get the final structured data from repository
      final responseText = await _aiRepository.generatePathJson('');

      // 2. Parse and save to Firestore using Use Case
      final Map<String, dynamic> pathData = jsonDecode(responseText);
      final originalPrompt = _uiMessages.firstWhere((m) => m.isUser).text;

      final docId = await _saveGeneratedPathUseCase(
        userId: userId,
        pathData: pathData,
        originalPrompt: originalPrompt,
      );

      emitter(CreationSuccess(docId));
    } catch (e) {
      emitter(CreationFailure(e.toString()));
    }
  }
}
