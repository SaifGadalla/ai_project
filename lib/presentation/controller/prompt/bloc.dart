import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/domain/repository/ai_repository.dart';

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
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final List<ChatMessage> _uiMessages = [];

  CreationBloc({
    required this.localizations,
    required this._aiRepository,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       super(
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
    } on FirebaseException catch (e) {
      Logger('Firebase Error Code').finer(e.code);
      Logger('Firebase Error Message').finer(e.message);

      String errorMessage =
          localizations.promptErrorSafety; // Default to safety message

      if (e.message?.contains('attestation failed') == true ||
          e.code == 'app-check-failed') {
        errorMessage = "App Check Failed: Please register your debug token.";
      } else if (e.code == 'unavailable' ||
          e.code == 'network-request-failed') {
        errorMessage = "Network Error: Please check your internet connection.";
      }

      _uiMessages.add(ChatMessage(text: errorMessage, isUser: false));

      emitter(
        CreationChatActive(
          messages: List.from(_uiMessages),
          isTyping: false,
          canGenerate: false,
        ),
      );
    } catch (e) {
      Logger('General Error').finer(e);

      _uiMessages.add(
        ChatMessage(text: localizations.promptErrorGeneric, isUser: false),
      );
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
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emitter(CreationFailure(localizations.promptErrorUnauthenticated));
        return;
      }

      // 1. Get the final structured data from repository
      final responseText = await _aiRepository.generatePathJson('');

      // 2. Parse and save to Firestore
      final Map<String, dynamic> pathData = jsonDecode(responseText);
      pathData['createdAt'] = FieldValue.serverTimestamp();
      pathData['userId'] = userId;
      pathData['originalPrompt'] = _uiMessages.firstWhere((m) => m.isUser).text;

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paths')
          .add(pathData);

      emitter(CreationSuccess(docRef.id));
    } catch (e) {
      emitter(CreationFailure(e.toString()));
    }
  }
}
