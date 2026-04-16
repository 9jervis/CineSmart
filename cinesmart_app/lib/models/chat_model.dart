/// Enum for chat message roles
enum ChatMessageRole { user, assistant }

/// Model for a single chat message
class ChatMessage {
  final String id;
  final String content;
  final ChatMessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      role: json['role'] == 'assistant' ? ChatMessageRole.assistant : ChatMessageRole.user,
      timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'role': role == ChatMessageRole.assistant ? 'assistant' : 'user',
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Enum for chatbot action types
enum ChatAction {
  none,
  openSeatPage,
  openMovieList,
  openMovieDetails,
  confirmBooking,
  showAvailableShows,
}

/// Model for action data
class ChatActionData {
  final String? movie;
  final int? seats;
  final String? showId;
  final Map<String, dynamic>? additionalInfo;

  ChatActionData({
    this.movie,
    this.seats,
    this.showId,
    this.additionalInfo,
  });

  factory ChatActionData.fromJson(Map<String, dynamic> json) {
    return ChatActionData(
      movie: json['movie'],
      seats: json['seats'],
      showId: json['show_id'],
      additionalInfo: json['additional_info'],
    );
  }
}

/// Model for chatbot response
class ChatResponse {
  final String reply;
  final ChatAction action;
  final ChatActionData? data;
  final Map<String, dynamic>? contextUpdate;

  ChatResponse({
    required this.reply,
    required this.action,
    this.data,
    this.contextUpdate,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    ChatAction parseAction(String? actionStr) {
      switch (actionStr) {
        case 'open_seat_page':
          return ChatAction.openSeatPage;
        case 'open_movie_list':
          return ChatAction.openMovieList;
        case 'open_movie_details':
          return ChatAction.openMovieDetails;
        case 'confirm_booking':
          return ChatAction.confirmBooking;
        case 'show_available_shows':
          return ChatAction.showAvailableShows;
        default:
          return ChatAction.none;
      }
    }

    return ChatResponse(
      reply: json['reply'] ?? 'Let me help you with that.',
      action: parseAction(json['action']),
      data: json['data'] != null ? ChatActionData.fromJson(json['data']) : null,
      contextUpdate: json['context_update'],
    );
  }
}
