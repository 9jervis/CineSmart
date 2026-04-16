import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinesmart_app/models/chat_model.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:8000/api/chat';
  static const String chatMessageEndpoint = '$baseUrl/message';
  static const String moviesEndpoint = '$baseUrl/movies';

  /// Send a message to the chatbot and get response
  Future<ChatResponse> sendMessage(
    String message, {
    String? movieContext,
    Map<String, dynamic>? bookingContext,
  }) async {
    try {
      final requestBody = {
        'message': message,
        'movie_context': movieContext,
        'booking_context': bookingContext ?? {},
      };

      final response = await http.post(
        Uri.parse(chatMessageEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ChatResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Get list of available movies
  Future<List<String>> getAvailableMovies() async {
    try {
      final response = await http.get(
        Uri.parse(moviesEndpoint),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final moviesList = List<String>.from(jsonResponse['movies'] ?? []);
        return moviesList;
      } else {
        throw Exception('Failed to fetch movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }
}
