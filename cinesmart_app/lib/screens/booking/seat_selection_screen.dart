import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../profile/bookings_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final int itemId;
  final String itemTitle;
  final String itemSubtitle;
  final String initialShowTime;
  final int? requestedSeats;

  const SeatSelectionScreen({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.initialShowTime,
    this.requestedSeats,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _showTimes = const [
    '10:15 AM',
    '01:30 PM',
    '04:00 PM',
    '07:15 PM',
    '10:30 PM',
  ];

  String _selectedShowTime = '';

  final Set<String> _selectedSeats = {};
  final Set<String> _soldSeats = {};
  bool _loadingSeats = true;
  bool _booking = false;
  int? _seatCount;
  bool _seatCountPromptShown = false;

  @override
  void initState() {
    super.initState();
    _selectedShowTime = widget.initialShowTime;
    
    // If seats were provided by chatbot, use them
    if (widget.requestedSeats != null && widget.requestedSeats! > 0) {
      _seatCount = widget.requestedSeats;
      _seatCountPromptShown = true;
    }
    
    _loadSoldSeats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_seatCountPromptShown) {
        _promptSeatCountIfNeeded();
      }
    });
  }

  Future<void> _promptSeatCountIfNeeded() async {
    if (_seatCountPromptShown) return;
    _seatCountPromptShown = true;

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SeatCountDialog(
        initial: _seatCount ?? 2,
      ),
    );

    if (!mounted) return;
    setState(() {
      _seatCount = result ?? 2;
      _selectedSeats.clear();
    });
  }

  Future<void> _loadSoldSeats() async {
    setState(() => _loadingSeats = true);
    try {
      final seats = await ApiService.getBookedSeats(
        movieId: widget.itemId,
        showTime: _selectedShowTime,
      );
      setState(() {
        _soldSeats
          ..clear()
          ..addAll(seats);
        _selectedSeats.removeWhere(_soldSeats.contains);
        _loadingSeats = false;
      });
    } catch (_) {
      setState(() => _loadingSeats = false);
    }
  }

  int _priceForSeat(String seatNumber) {
    final row = seatNumber[0];
    if ('ABCD'.contains(row)) return 210; // SILVER
    if ('EFGHI'.contains(row)) return 210; // PREMIER
    return 190; // EXECUTIVE
  }

  int get _totalPrice =>
      _selectedSeats.fold(0, (sum, s) => sum + _priceForSeat(s));

  void _toggleSeat(String seat) {
    if (_soldSeats.contains(seat)) return;
    final limit = _seatCount ?? 0;
    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
      } else {
        if (limit > 0 && _selectedSeats.length >= limit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can select up to $limit seats.'),
              duration: const Duration(milliseconds: 900),
            ),
          );
          return;
        }
        _selectedSeats.add(seat);
      }
    });
  }

  List<_SeatSection> _sections() => [
        _SeatSection(
          title: 'SILVER',
          priceLabel: '₹210',
          rows: [
            _SeatRow(
              rowLabel: 'A',
              seats: [
                // left block (a couple hidden like screenshot feel)
                null,
                null,
                for (var i = 3; i <= 9; i++) 'A$i',
                null,
                for (var i = 10; i <= 14; i++) 'A$i',
              ],
            ),
            _SeatRow(
              rowLabel: 'B',
              seats: [
                null,
                for (var i = 2; i <= 9; i++) 'B$i',
                null,
                for (var i = 10; i <= 14; i++) 'B$i',
              ],
            ),
            _SeatRow(
              rowLabel: 'C',
              seats: [
                for (var i = 1; i <= 9; i++) 'C$i',
                null,
                for (var i = 10; i <= 14; i++) 'C$i',
              ],
            ),
            _SeatRow(
              rowLabel: 'D',
              seats: [
                for (var i = 1; i <= 9; i++) 'D$i',
                null,
                for (var i = 10; i <= 14; i++) 'D$i',
              ],
            ),
          ],
        ),
        _SeatSection(
          title: 'PREMIER',
          priceLabel: '₹210',
          rows: [
            for (final r in ['E', 'F', 'G', 'H', 'I'])
              _SeatRow(
                rowLabel: r,
                seats: [
                  // left block
                  null,
                  for (var i = 2; i <= 7; i++) '$r$i',
                  null,
                  // middle block
                  for (var i = 8; i <= 12; i++) '$r$i',
                  null,
                  // right block
                  for (var i = 13; i <= 16; i++) '$r$i',
                ],
              ),
          ],
        ),
        _SeatSection(
          title: 'EXECUTIVE',
          priceLabel: '₹190',
          rows: [
            for (final r in ['J', 'K', 'L'])
              _SeatRow(
                rowLabel: r,
                seats: [
                  null,
                  for (var i = 2; i <= 7; i++) '$r$i',
                  null,
                  for (var i = 8; i <= 12; i++) '$r$i',
                  null,
                  for (var i = 13; i <= 16; i++) '$r$i',
                ],
              ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.itemTitle),
            const SizedBox(height: 2),
            Text(
              widget.itemSubtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Change seats count',
            onPressed: _promptSeatCountIfNeeded,
            icon: const Icon(Icons.event_seat_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _showTimes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final t = _showTimes[i];
                final selected = t == _selectedShowTime;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (_selectedShowTime == t) return;
                    setState(() {
                      _selectedShowTime = t;
                      _selectedSeats.clear();
                    });
                    _loadSoldSeats();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected ? const Color(0xFFE11D48) : Colors.white,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFE11D48)
                            : const Color(0xFFEAEAF0),
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _seatCount == null
                        ? 'How many seats?'
                        : '$_seatCount Ticket(s)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _promptSeatCountIfNeeded,
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loadingSeats
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        ..._sections().map((section) => _SectionWidget(
                              section: section,
                              soldSeats: _soldSeats,
                              selectedSeats: _selectedSeats,
                              onSeatTap: _toggleSeat,
                            )),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _Legend(color: Colors.white, border: true, text: "Available"),
                            _Legend(color: Colors.green, text: "Selected"),
                            _Legend(color: Color(0xFFBDBDBD), text: "Sold"),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _ScreenIndicator(),
                      ],
                    ),
                  ),
          ),
          _BottomBar(
            selectedSeats: _selectedSeats.toList()..sort(),
            totalPrice: _totalPrice,
            booking: _booking,
            onConfirm: _selectedSeats.isEmpty || _booking
                ? null
                : () async {
                    setState(() => _booking = true);
                    
                    // Use current user's ID from ApiService
                    final userId = ApiService.currentUserId;
                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User not logged in")),
                      );
                      setState(() => _booking = false);
                      return;
                    }
                    
                    final response = await ApiService.bookTickets(
                      userId: userId,
                      movieId: widget.itemId,
                      showTime: _selectedShowTime,
                      seats: _selectedSeats.toList(),
                      totalPrice: _totalPrice,
                    );
                    setState(() => _booking = false);

                    if (response["id"] != null) {
                      await _loadSoldSeats();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking Successful! 🎉")),
                      );
                      // Navigate to bookings screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingsScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response["message"] ?? "Booking failed"),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }
}

// 🎯 LEGEND WIDGET (CLEAN CODE)
class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  final bool border;

  const _Legend({required this.color, required this.text, this.border = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: const Color(0xFFBDBDBD)) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}

class _SeatSection {
  final String priceLabel;
  final String title;
  final List<_SeatRow> rows;
  const _SeatSection({
    required this.priceLabel,
    required this.title,
    required this.rows,
  });
}

class _SeatRow {
  final String rowLabel;
  final List<String?> seats; // null = aisle / gap
  const _SeatRow({required this.rowLabel, required this.seats});
}

class _SectionWidget extends StatelessWidget {
  final _SeatSection section;
  final Set<String> soldSeats;
  final Set<String> selectedSeats;
  final void Function(String seat) onSeatTap;

  const _SectionWidget({
    required this.section,
    required this.soldSeats,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              '${section.priceLabel}  ${section.title}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...section.rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    child: Text(
                      row.rowLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: row.seats.map((seat) {
                          if (seat == null) {
                            return const SizedBox(width: 22, height: 28);
                          }
                          final sold = soldSeats.contains(seat);
                          final selected = selectedSeats.contains(seat);
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _SeatPill(
                              label: seat.substring(1).padLeft(2, '0'),
                              state: sold
                                  ? _SeatState.sold
                                  : selected
                                      ? _SeatState.selected
                                      : _SeatState.available,
                              onTap: sold ? null : () => onSeatTap(seat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SeatState { available, selected, sold }

class _SeatPill extends StatelessWidget {
  final String label;
  final _SeatState state;
  final VoidCallback? onTap;

  const _SeatPill({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      _SeatState.available => Colors.white,
      _SeatState.selected => Colors.green,
      _SeatState.sold => const Color(0xFFE0E0E0),
    };
    final fg = switch (state) {
      _SeatState.available => const Color(0xFF0E7A3A),
      _SeatState.selected => Colors.white,
      _SeatState.sold => const Color(0xFF8E8E8E),
    };
    final border = switch (state) {
      _SeatState.available => const Color(0xFF2BB673),
      _SeatState.selected => Colors.green,
      _SeatState.sold => const Color(0xFFE0E0E0),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: fg,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _ScreenIndicator extends StatelessWidget {
  const _ScreenIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 28),
          painter: _ScreenPainter(),
        ),
        const SizedBox(height: 6),
        const Text(
          'SCREEN THIS WAY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.black45,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomBar extends StatelessWidget {
  final List<String> selectedSeats;
  final int totalPrice;
  final bool booking;
  final VoidCallback? onConfirm;

  const _BottomBar({
    required this.selectedSeats,
    required this.totalPrice,
    required this.booking,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAF0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedSeats.isEmpty
                        ? 'Select seats'
                        : '${selectedSeats.length} seat(s): ${selectedSeats.join(", ")}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total ₹$totalPrice',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: booking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Select Seats',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatCountDialog extends StatefulWidget {
  final int initial;
  const _SeatCountDialog({required this.initial});

  @override
  State<_SeatCountDialog> createState() => _SeatCountDialogState();
}

class _SeatCountDialogState extends State<_SeatCountDialog> {
  late int _count = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How many seats?',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              children: List.generate(10, (i) {
                final n = i + 1;
                final selected = n == _count;
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => setState(() => _count = n),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFE11D48) : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFE11D48)
                            : const Color(0xFFEAEAF0),
                      ),
                    ),
                    child: Text(
                      '$n',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: selected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _PriceMini(title: 'PREMIER', price: '₹210', sub: 'AVAILABLE'),
                _PriceMini(title: 'SILVER', price: '₹210', sub: 'FILLING FAST'),
                _PriceMini(title: 'EXECUTIVE', price: '₹190', sub: 'AVAILABLE'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context, _count),
                child: const Text(
                  'Select Seats',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceMini extends StatelessWidget {
  final String title;
  final String price;
  final String sub;
  const _PriceMini({
    required this.title,
    required this.price,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final subColor =
        sub == 'FILLING FAST' ? const Color(0xFFB45309) : const Color(0xFF15803D);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(
          sub,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: subColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}