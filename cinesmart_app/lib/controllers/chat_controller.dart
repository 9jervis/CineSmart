import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/chat_response_model.dart';
import '../services/api_service.dart';

class ChatController extends ChangeNotifier {
  ChatController({String? greeting}) {
    _messages = [
      ChatMessage(
        text: greeting ??
            'Hi! Ask me to show movies, check showtimes, or book tickets with your voice.',
        sender: ChatSender.bot,
      ),
    ];
  }

  late List<ChatMessage> _messages;
  bool _sending = false;
  String? _sessionId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;

  Future<ChatResponseModel?> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) {
      return null;
    }

    _sending = true;
    _messages = [
      ChatMessage(text: trimmed, sender: ChatSender.user),
      ..._messages,
    ];
    notifyListeners();

    try {
      final response = await ApiService.chat(
        message: trimmed,
        sessionId: _sessionId,
      );
      _sessionId = response.sessionId;
      _messages = [
        ChatMessage(text: response.reply, sender: ChatSender.bot),
        ..._messages,
      ];
      notifyListeners();
      return response;
    } catch (error) {
      _messages = [
        ChatMessage(
          text: "Sorry, I couldn't reach the server. ($error)",
          sender: ChatSender.bot,
        ),
        ..._messages,
      ];
      notifyListeners();
      rethrow;
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
