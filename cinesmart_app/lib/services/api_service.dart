import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/chat_response_model.dart';
import '../models/movie_model.dart';
import '../models/booking_model.dart';

class ApiService {
  // Use --dart-define=API_BASE_URL=<url> for production/web builds.
  static final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Logged-in user (set after login)
  static String? currentUserName;
  static int? currentUserId;

  // 🔐 LOGIN API
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        currentUserName = (data["name"] ?? "").toString().trim().isEmpty
            ? null
            : data["name"].toString();
        currentUserId = data["user_id"] is int ? data["user_id"] as int : null;
        return data;
      } else {
        return {
          "message": data["detail"] ?? "Login failed"
        };
      }
    } catch (e) {
      return {
        "message": "Network error: $e"
      };
    }
  }

  // 📝 SIGNUP API
  static Future<Map<String, dynamic>> signup(
      String name, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/auth/signup"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        return {
          "message": data["detail"] ?? "Signup failed"
        };
      }
    } catch (e) {
      return {
        "message": "Network error: $e"
      };
    }
  }

  // 🎬 GET ALL MOVIES
  static Future<List<dynamic>> getMovies({String? genre}) async {
    String url = "$baseUrl/movies/";
    if (genre != null && genre.isNotEmpty) {
      url += "?genre=$genre";
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load movies");
    }
  }

  // 🎭 GET ALL GENRES
  static Future<List<dynamic>> getGenres() async {
    final response = await http.get(Uri.parse("$baseUrl/movies/genres"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load genres");
    }
  }

  // � GET LIVE EVENTS
  static Future<List<dynamic>> getEvents() async {
    final response = await http.get(Uri.parse("$baseUrl/events/"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load events");
    }
  }

  // �🎟️ BOOKING API (FINAL FIXED)
  static Future<Map<String, dynamic>> bookTickets({
    required int userId,
    required int movieId,
    required String showTime,
    required List<String> seats,
    required int totalPrice,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/booking/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "movie_id": movieId,
          "show_time": showTime,
          "seats": seats,
          "total_price": totalPrice,
        }),
      );

      final data = jsonDecode(response.body);

      // ✅ HANDLE BOTH SUCCESS TYPES
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        return {
          "message": data["detail"] ?? "Booking failed"
        };
      }
    } catch (e) {
      return {
        "message": "Network error: $e"
      };
    }
  }

  // 🎟️ GET BOOKED SEATS FOR A SHOWTIME
  static Future<List<String>> getBookedSeats({
    required int movieId,
    required String showTime,
  }) async {
    final uri = Uri.parse("$baseUrl/booking/seats/$movieId")
        .replace(queryParameters: {"show_time": showTime});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception("Failed to load booked seats");
    }
  }

  // 📋 GET USER BOOKINGS FOR PROFILE
  static Future<List<Booking>> getUserBookings(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/booking/user/$userId"),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Booking.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception("Failed to load bookings");
      }
    } catch (e) {
      throw Exception("Error fetching bookings: $e");
    }
  }

  // ❌ CANCEL BOOKING
  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/booking/$bookingId"),
      ).timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        return {"message": data["detail"] ?? "Cancel failed"};
      }
    } catch (e) {
      return {"message": "Network error: $e"};
    }
  }

  static Future<Movie> getMovie(int movieId) async {
    final response = await http.get(Uri.parse("$baseUrl/movies/$movieId"));

    if (response.statusCode == 200) {
      return Movie.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to load movie");
  }

  // 💬 CHATBOT
  static Future<ChatResponseModel> chat({
    required String message,
    String? sessionId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "message": message,
        if (sessionId != null && sessionId.isNotEmpty) "session_id": sessionId,
        if (currentUserId != null) "user_id": currentUserId,
      }),
    );

    if (response.statusCode == 200) {
      return ChatResponseModel.fromJson(jsonDecode(response.body));
    }
    throw Exception("Chat request failed");
  }
}
