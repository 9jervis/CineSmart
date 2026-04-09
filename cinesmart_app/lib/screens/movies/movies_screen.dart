import 'package:flutter/material.dart';

import '../../models/movie_model.dart';
import '../../services/api_service.dart';
import '../movie/movie_details_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  bool _loading = true;
  List<Movie> _movies = [];

  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getMovies();
      setState(() {
        _movies = data.map((e) => Movie.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movies = _query.trim().isEmpty
        ? _movies
        : _movies
            .where((m) => m.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    titleSpacing: 16,
                    title: const Text(
                      'Movies',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    actions: const [
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.tune, color: Colors.black87),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: TextField(
                        controller: _search,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search movies',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _search.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (movies.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No movies found.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      sliver: SliverGrid.builder(
                        itemCount: movies.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.74,
                        ),
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return _MovieTile(
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

class _MovieTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  const _MovieTile({required this.movie, required this.onTap});

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

