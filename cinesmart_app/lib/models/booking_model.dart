class Booking {
  final int id;
  final int userId;
  final int movieId;
  final String movieTitle;
  final String movieImage;
  final String showTime;
  final String seats;
  final int totalPrice;

  Booking({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    required this.movieImage,
    required this.showTime,
    required this.seats,
    required this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      movieId: json['movie_id'] as int? ?? 0,
      movieTitle: json['movie_title'] as String? ?? 'Unknown Movie',
      movieImage: json['movie_image'] as String? ?? '',
      showTime: json['show_time'] as String? ?? '',
      seats: json['seats'] as String? ?? '',
      totalPrice: json['total_price'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'movie_title': movieTitle,
      'movie_image': movieImage,
      'show_time': showTime,
      'seats': seats,
      'total_price': totalPrice,
    };
  }
}
