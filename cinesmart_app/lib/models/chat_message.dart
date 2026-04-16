enum ChatSender { user, bot }

enum MessageType { text, movieList, movieDetail }

class ChatMessage {
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final MessageType messageType;
  final Map<String, dynamic>? richData;

  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
    this.messageType = MessageType.text,
    this.richData,
  }) : timestamp = timestamp ?? DateTime.now();
}

