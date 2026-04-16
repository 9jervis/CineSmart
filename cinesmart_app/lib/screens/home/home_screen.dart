import 'package:flutter/material.dart';

// 👇 IMPORT YOUR FILES
import '../../services/api_service.dart';
import '../../models/movie_model.dart';
import '../movie/movie_details_screen.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> movies = [];
  List<String> genres = [];
  String? selectedGenre;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedChip = 'Now Showing';

  @override
  void initState() {
    super.initState();
    fetchMovies();
    fetchGenres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchMovies() async {
    try {
      final data = await ApiService.getMovies(genre: selectedGenre);
      setState(() {
        movies = data.map((e) => Movie.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void fetchGenres() async {
    try {
      final data = await ApiService.getGenres();
      setState(() {
        genres = List<String>.from(data);
      });
    } catch (e) {
      print("Error fetching genres: $e");
    }
  }

  void onGenreChanged(String? genre) {
    setState(() {
      selectedGenre = genre;
      isLoading = true;
    });
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _query.trim().isEmpty
        ? movies
        : movies
            .where((m) => m.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => fetchMovies(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    titleSpacing: 16,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Now Showing",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Mumbai • 33 Movies",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'Chat',
                        icon: const Icon(Icons.chat_bubble_outline,
                            color: Colors.black87),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChatScreen(),
                            ),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.notifications_none,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search for movies, cinemas...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _Chip(
                              label: 'Now Showing',
                              selected: _selectedChip == 'Now Showing',
                              onTap: () => setState(
                                  () => _selectedChip = 'Now Showing'),
                            ),
                            const SizedBox(width: 10),
                            _Chip(
                              label: 'Coming Soon',
                              selected: _selectedChip == 'Coming Soon',
                              onTap: () => setState(
                                  () => _selectedChip = 'Coming Soon'),
                            ),
                            const SizedBox(width: 10),
                            _Chip(
                              label: 'Hindi',
                              selected: _selectedChip == 'Hindi',
                              onTap: () =>
                                  setState(() => _selectedChip = 'Hindi'),
                            ),
                            const SizedBox(width: 10),
                            _Chip(
                              label: 'English',
                              selected: _selectedChip == 'English',
                              onTap: () =>
                                  setState(() => _selectedChip = 'English'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (genres.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _Chip(
                                label: 'All',
                                selected: selectedGenre == null,
                                onTap: () => onGenreChanged(null),
                              ),
                              const SizedBox(width: 10),
                              ...genres.map(
                                (g) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _Chip(
                                    label: g,
                                    selected: selectedGenre == g,
                                    onTap: () => onGenreChanged(g),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                      child: Card(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.local_offer_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Top offers for you",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Recommended Movies",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "See All ›",
                            style: TextStyle(
                              color: Color(0xFFE11D48),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 240,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredMovies.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final movie = filteredMovies[index];
                          return _PosterCard(
                            movie: movie,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailsScreen(movie: movie),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    sliver: SliverGrid.builder(
                      itemCount: filteredMovies.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.74,
                      ),
                      itemBuilder: (context, index) {
                        final movie = filteredMovies[index];
                        return _GridMovieCard(
                          movie: movie,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailsScreen(movie: movie),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? cs.primary : const Color(0xFFEAEAF0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _PosterCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 168,
                width: double.infinity,
                child: Image.network(
                  movie.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFEAEAF0),
                      child: const Icon(Icons.movie_outlined),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text(
                  movie.rating.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    movie.genre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GridMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _GridMovieCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFEAEAF0),
                        child: const Icon(Icons.movie_outlined),
                      );
                    },
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              movie.genre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
