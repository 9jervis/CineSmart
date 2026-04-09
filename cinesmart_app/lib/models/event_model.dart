class Event {
  final int id;
  final String title;
  final String venue;
  final String city;
  final String date;
  final String time;
  final String category;
  final int price;
  final String imageUrl;
  final String description;
  final List<String> showTimes;

  Event({
    required this.id,
    required this.title,
    required this.venue,
    required this.city,
    required this.date,
    required this.time,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.showTimes,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      venue: json['venue'],
      city: json['city'],
      date: json['date'],
      time: json['time'],
      category: json['category'],
      price: json['price'],
      imageUrl: json['image_url'],
      description: json['description'],
      showTimes: List<String>.from(json['show_times'] ?? []),
    );
  }
}
