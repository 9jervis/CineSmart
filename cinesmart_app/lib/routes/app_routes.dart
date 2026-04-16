import 'package:get/get.dart';
import 'package:cinesmart_app/models/movie_model.dart';
import 'package:cinesmart_app/screens/chat/chat_screen.dart';
import 'package:cinesmart_app/screens/booking/seat_selection_screen.dart';
import 'package:cinesmart_app/screens/movie/movie_details_screen.dart';

class AppRoutes {
  static const String chat = '/chat';
  static const String seatBooking = '/seat-booking';
  static const String movieList = '/movies';
  static const String movieDetails = '/movie-details';

  static final routes = [
    GetPage(
      name: chat,
      page: () => const ChatScreen(),
    ),
    GetPage(
      name: seatBooking,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return SeatSelectionScreen(
          itemId: args?['itemId'] as int? ?? 0,
          itemTitle: args?['itemTitle'] as String? ?? 'Movie',
          itemSubtitle: args?['itemSubtitle'] as String? ?? 'Booking',
          initialShowTime: args?['initialShowTime'] as String? ?? '07:15 PM',
          requestedSeats: args?['requestedSeats'] as int?,
        );
      },
    ),
    GetPage(
      name: movieDetails,
      page: () {
        final movie = Get.arguments as Movie;
        return MovieDetailsScreen(movie: movie);
      },
    ),
  ];
}
