import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import '../settings/account_settings_screen.dart';
import '../settings/edit_profile_screen.dart';
import 'bookings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    if (ApiService.currentUserId != null) {
      _bookingsFuture = ApiService.getUserBookings(ApiService.currentUserId!);
    } else {
      _bookingsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loadBookings());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(isDark),
              const SizedBox(height: 16),
              _buildMenuSection(isDark),
              const SizedBox(height: 16),
              _buildBookingsPreview(isDark),
              const SizedBox(height: 16),
              _buildBottomLinks(isDark),
              const SizedBox(height: 30),
              // App branding
              Column(
                children: [
                  const Icon(Icons.movie, color: Color(0xFFE11D48), size: 28),
                  const SizedBox(height: 6),
                  Text(
                    'CineSmart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'App Version: 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Profile Header â”€â”€
  Widget _buildProfileHeader(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE11D48).withAlpha(25),
            ),
            child: const Icon(
              Icons.person,
              size: 36,
              color: Color(0xFFE11D48),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi! ${ApiService.currentUserName ?? 'User'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                    if (updated == true) setState(() {});
                  },
                  child: const Text(
                    'Edit Profile âœŽ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE11D48),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Menu Options â”€â”€
  Widget _buildMenuSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]!,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.fastfood_outlined,
              title: 'Food & Beverages',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Food & Beverages coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              showDivider: true,
              isDark: isDark,
            ),
            _buildMenuItem(
              icon: Icons.theater_comedy_outlined,
              title: 'List your Show',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('List your Show coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              showDivider: true,
              isDark: isDark,
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Account & Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountSettingsScreen(),
                  ),
                );
              },
              showDivider: false,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
    required bool isDark,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 22),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 52,
            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
          ),
      ],
    );
  }

  // â”€â”€ Bookings Preview â”€â”€
  Widget _buildBookingsPreview(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingsScreen()),
          );
          // Refresh on return
          setState(() => _loadBookings());
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]!,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        color: Colors.grey[600], size: 22),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Your Bookings & Purchases',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
              ),
              // Quick preview of latest booking
              FutureBuilder<List<Booking>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.confirmation_number_outlined,
                              size: 32,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No bookings yet',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Show latest booking preview
                  final latest = snapshot.data!.first;
                  final count = snapshot.data!.length;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 50,
                                height: 70,
                                child: latest.movieImage.isNotEmpty
                                    ? Image.network(
                                        latest.movieImage,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.movie,
                                              size: 20),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.movie,
                                            size: 20),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    latest.movieTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Seats: ${latest.seats}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${latest.showTime}  â€¢  â‚¹${latest.totalPrice}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (count > 1)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[850]
                                : Colors.grey[50],
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.grey[200]!,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'View all $count bookings â†’',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Bottom Links â”€â”€
  Widget _buildBottomLinks(bool isDark) {
    final items = [
      {'icon': Icons.share_outlined, 'title': 'Share'},
      {'icon': Icons.thumb_up_outlined, 'title': 'Rate Us'},
      {'icon': Icons.description_outlined, 'title': 'Terms & Conditions'},
      {'icon': Icons.privacy_tip_outlined, 'title': 'Privacy Policy'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]!,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            final item = entry.value;
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['title']} coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData,
                            color: Colors.grey[600], size: 22),
                        const SizedBox(width: 14),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 52,
                    color:
                        isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
