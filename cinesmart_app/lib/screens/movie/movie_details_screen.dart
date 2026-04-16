import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/movie_model.dart';
import '../booking/seat_selection_screen.dart';

class Theater {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String rating;
  final String format;

  Theater({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.format,
  });
}

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final List<DateTime> _dates = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  int _selectedDateIndex = 0;
  bool _isLocating = true;
  String _locationLabel = 'Locating nearby theaters...';
  Position? _position;

  final List<Theater> _theaters = [
    Theater(
      name: 'INOX: R-City, Ghatkopar',
      address: 'Ghatkopar East, Mumbai',
      latitude: 19.0728,
      longitude: 72.8974,
      rating: '4.5',
      format: '2D • IMAX',
    ),
    Theater(
      name: 'Cinepolis: Seawoods, Navi Mumbai',
      address: 'Seawoods, Navi Mumbai',
      latitude: 19.0330,
      longitude: 73.0183,
      rating: '4.3',
      format: '2D • 3D',
    ),
    Theater(
      name: 'INOX: Raghuleela Mall, Vashi',
      address: 'Vashi, Navi Mumbai',
      latitude: 19.0806,
      longitude: 72.9975,
      rating: '4.4',
      format: '2D • 4DX',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationLabel = 'Location service is disabled';
          _isLocating = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationLabel = 'Allow location permission in settings';
          _isLocating = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _position = position;
        _locationLabel = 'Nearby theaters';
        _isLocating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationLabel = 'Unable to get location';
        _isLocating = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  double _distanceTo(Theater theater) {
    if (_position == null) return double.infinity;
    final lat1 = _position!.latitude * pi / 180;
    final lon1 = _position!.longitude * pi / 180;
    final lat2 = theater.latitude * pi / 180;
    final lon2 = theater.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return 6371.0 * c;
  }

  @override
  Widget build(BuildContext context) {
    final showtimes = [
      '10:15 AM',
      '01:30 PM',
      '04:00 PM',
      '07:15 PM',
      '10:30 PM',
    ];
    final sortedTheaters = List<Theater>.from(_theaters);
    if (_position != null) {
      sortedTheaters.sort((a, b) => _distanceTo(a).compareTo(_distanceTo(b)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.movie.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.movie, size: 80),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Book showtimes'),
                SizedBox(height: 2),
                Text(
                  'Choose date and theater',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(widget.movie.genre,
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(widget.movie.rating.toString()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Duration: ${widget.movie.duration} mins',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 22),
                  const Text(
                    'Select Date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dates.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final date = _dates[index];
                        final isSelected = index == _selectedDateIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDateIndex = index),
                          child: Container(
                            width: 90,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(date),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  index == 0 ? 'Today' : '',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : Colors.black45,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationLabel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_isLocating)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Nearby Theaters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: sortedTheaters.map((theater) {
                      final distance = _position == null ? null : _distanceTo(theater);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    theater.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Text(theater.rating, style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(theater.address, style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text(
                              '${theater.format}${distance == null ? '' : ' • ${distance.toStringAsFixed(1)} km'}',
                              style: const TextStyle(color: Colors.black45),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: showtimes.map((time) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SeatSelectionScreen(
                                          itemId: widget.movie.id,
                                          itemTitle: widget.movie.title,
                                          itemSubtitle:
                                              '${theater.name} • ${_formatDate(_dates[_selectedDateIndex])}',
                                          initialShowTime: time,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      border: Border.all(color: Colors.green),
                                    ),
                                    child: Text(
                                      time,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About Movie',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.movie.description,
                    style: const TextStyle(color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
