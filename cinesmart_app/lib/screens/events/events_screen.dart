import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/api_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> events = [];
  bool isLoading = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final data = await ApiService.getEvents();
      setState(() {
        events = List<Event>.from(data.map((e) => Event.fromJson(e)));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading events: $e');
    }
  }

  String _formatDate(String dateString) {
    final parts = dateString.split('-');
    if (parts.length != 3) return dateString;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return dateString;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${day.toString().padLeft(2, '0')} ${months[month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  titleSpacing: 16,
                  title: const Text(
                    'Live Events',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  actions: const [
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.search, color: Colors.black87),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      'Latest events for you',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return GestureDetector(
                          onTap: () => setState(() => selectedIndex = index),
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.only(right: index == events.length - 1 ? 0 : 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedIndex == index ? Colors.red : Colors.grey[100],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(event.date),
                                  style: TextStyle(
                                    color: selectedIndex == index ? Colors.white70 : Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  event.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: selectedIndex == index ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = events[index];
                        return _EventCard(
                          event: event,
                          isSelected: selectedIndex == index,
                        );
                      },
                      childCount: events.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isSelected;

  const _EventCard({required this.event, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              event.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.event, size: 60, color: Colors.black38),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event.category,
                        style: const TextStyle(
                          color: Color(0xFF991B1B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(event.venue, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text('${event.date} • ${event.time}', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: event.showTimes.take(3).map((time) {
                    return GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Event seatmap is not implemented yet.'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          time,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

