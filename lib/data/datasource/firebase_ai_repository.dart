import 'package:firebase_ai/firebase_ai.dart';
import 'package:ai_project/core/constants.dart';
import 'package:ai_project/domain/repository/ai_repository.dart';

class FirebaseAiRepository implements AiRepository {
  final FirebaseAI _ai;
  late final GenerativeModel _chatModel;
  late final ChatSession _chatSession;

  FirebaseAiRepository({FirebaseAI? ai}) : _ai = ai ?? FirebaseAI.googleAI() {
    _initChat();
  }

  void _initChat() {
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
  }

  @override
  Future<String> sendMessage(String message) async {
    final response = await _chatSession.sendMessage(Content.text(message));
    return response.text ?? '';
  }

  @override
  Future<String> generatePathJson(String promptOverride) async {
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

    final jsonModel = _ai.generativeModel(
      model: geminiModel,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
        temperature: 0.2,
      ),
    );

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

    final response = await jsonModel.generateContent(history);
    final responseText = response.text;
    
    if (responseText == null || responseText.isEmpty) {
      throw Exception('AI returned empty JSON.');
    }
    
    return responseText;
  }
}
