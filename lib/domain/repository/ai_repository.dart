abstract class AiRepository {
  /// Sends a message to the AI chat session and returns the text response.
  Future<String> sendMessage(String message);

  /// Generates the final learning path JSON based on the chat history.
  Future<String> generatePathJson(String promptOverride);
}
