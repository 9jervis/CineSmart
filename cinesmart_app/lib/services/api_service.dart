import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ Correct for Android emulator
static const String baseUrl = 'http://10.0.2.2:8000';

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
}