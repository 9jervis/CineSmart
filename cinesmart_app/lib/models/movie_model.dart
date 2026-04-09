class Movie {
  final int id;
  final String title;
  final String description;
  final String genre;
  final double rating;
  final int duration;
  final String imageUrl;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.rating,
    required this.duration,
    required this.imageUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      genre: json["genre"],
      rating: (json["rating"] as num).toDouble(),
      duration: json["duration"],
      imageUrl: json["image_url"],
    );
  }
}