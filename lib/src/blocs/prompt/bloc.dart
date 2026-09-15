import 'dart:convert';
import 'package:ai_project/src/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:ai_project/l10n/app_localizations.dart';

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
  final FirebaseAI _ai;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  late final GenerativeModel _chatModel;
  late final ChatSession _chatSession;

  final List<ChatMessage> _uiMessages = [];

  CreationBloc({
    required this.localizations,
    FirebaseAI? ai,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _ai = ai ?? FirebaseAI.googleAI(),
       _firestore = firestore ?? FirebaseFirestore.instance,
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
    // 1. Initialize the conversational chat model with system instructions
    _chatModel = _ai.generativeModel(
      model: geminiModel,
      systemInstruction: Content.system(
        'You are an expert curriculum planner. A user will tell you what they want to learn. '
        'Ask a maximum of 2 clarifying questions (e.g., duration, current skill level). '
        'CRITICAL RULE 1: The maximum duration for any single learning path is 365 days. Warn them if their timeline is unrealistic. '
        'CRITICAL RULE 2 (STRICT BOUNDARY): You ONLY discuss learning paths and curriculum planning. '
        'If the user asks about anything unrelated to building a study plan (e.g., general trivia, writing code, casual chat, recipes), '
        'you must politely decline, state that you are exclusively a learning planner, and steer the conversation back to their learning goals. '
        'Keep your responses short, conversational, and friendly.',
      ),
    );

    _chatSession = _chatModel.startChat(
      history: [
        Content.model([
          TextPart(
            'Hi! What do you want to learn today, and how much time do you have?',
          ),
        ]),
      ],
    );

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
      // Send to Gemini Chat Session
      final response = await _chatSession.sendMessage(Content.text(event.text));

      final aiResponseText =
          response.text ?? localizations.promptErrorNoResponse;
      _uiMessages.add(ChatMessage(text: aiResponseText, isUser: false));

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

      // Check if it's actually an App Check or Network issue
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
      // This catches standard Dart exceptions (like no internet connection)
      Logger('General Error').finer(e);

      _uiMessages.add(
        ChatMessage(text: localizations.promptErrorGeneric, isUser: false),
      );
      emitter(
        CreationChatActive(
          messages: List.from(_uiMessages),
          isTyping: false,
          canGenerate: true, // They can try sending again
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

      // 1. Define the strictly enforced JSON schema
      final schema = Schema.object(
        properties: {
          'title': Schema.string(
            description: 'A concise title in the language of the conversation',
          ),
          'description': Schema.string(
            description:
                'A short summary of the curriculum in the language of the conversation',
          ),
          'days': Schema.array(
            items: Schema.object(
              properties: {
                'dayNumber': Schema.integer(),
                'title': Schema.string(
                  description:
                      'Topic for this specific day in the language of the conversation',
                ),
                'tasks': Schema.array(
                  items: Schema.object(
                    properties: {
                      'title': Schema.string(
                        description:
                            'Task title in the language of the conversation',
                      ),
                      'description': Schema.string(
                        description:
                            'Task description in the language of the conversation',
                      ),
                      'isCompleted': Schema.boolean(),
                    },
                  ),
                ),
              },
            ),
          ),
        },
      );

      // 2. Initialize a NEW model purely for JSON generation
      final jsonModel = _ai.generativeModel(
        model: geminiModel,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: schema,
          temperature: 0.2, // Low temperature keeps it focused on these rules
        ),
      );

      // 3. Grab the chat history and append the JSON command
      final history = _chatSession.history.toList();
      history.add(
        Content.text(
          'Based on our agreement in the conversation above, generate the structured learning path. '
          'CRITICAL INSTRUCTIONS: '
          '1. LANGUAGE OVERRIDE: You MUST write all generated text values (titles, descriptions, tasks) in the EXACT SAME LANGUAGE used by the user in the conversation above. If they spoke Arabic, the JSON values MUST be in Arabic. '
          '2. Determine the exact number of days agreed upon in the chat (MAXIMUM 365). '
          '   If no valid learning topic was agreed upon, generate a 1-day path titled "Invalid Topic". '
          '3. You MUST generate exactly that many items in the "days" array. '
          '4. Do NOT skip any days. Do NOT group days together. '
          '5. Break it down day by day with actionable tasks. '
          '6. For every task, explicitly set "isCompleted" to false.',
        ),
      );

      // 4. Request the final structured data
      final response = await jsonModel.generateContent(history);
      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw Exception('AI returned empty JSON.');
      }

      // 5. Parse and save to Firestore
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
