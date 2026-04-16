class ChatResponseModel {
  final String reply;
  final String sessionId;
  final String? action;
  final String? expecting;
  final Map<String, dynamic> data;

  const ChatResponseModel({
    required this.reply,
    required this.sessionId,
    required this.data,
    this.action,
    this.expecting,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      reply: (json['reply'] ?? '').toString(),
      sessionId: (json['session_id'] ?? '').toString(),
      action: json['action']?.toString(),
      expecting: json['expecting']?.toString(),
      data: Map<String, dynamic>.from(json['data'] ?? const {}),
    );
  }
}
