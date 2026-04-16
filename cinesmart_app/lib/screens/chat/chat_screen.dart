import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../models/chat_message.dart';
import '../../models/movie_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final List<ChatMessage> _messages;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _sending = false;
  bool _ttsEnabled = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;

  final FlutterTts _tts = FlutterTts();
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeTts();
    final name = ApiService.currentUserName;
    final greeting = (name == null || name.trim().isEmpty)
        ? "Hi! Ask me about movies, show timings, or bookings."
        : "Hi $name! Ask me about movies, show timings, or bookings.";
    _messages = [
      ChatMessage(text: greeting, sender: ChatSender.bot),
    ];
  }

  /// Initialize text-to-speech engine
  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.8);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  /// Handle action responses from chatbot
  Future<void> _handleAction(String? action, Map<String, dynamic> data) async {
    if (action == null) return;

    switch (action) {
      case 'open_seat_page':
        _openSeatBookingPage(data);
        break;
      case 'open_movie_details':
        _openMovieDetails(data);
        break;
      case 'show_available_shows':
        _showAvailableShows(data);
        break;
      case 'show_movies':
        final movies = data['movies'];
        if (movies != null) {
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                text: '',
                sender: ChatSender.bot,
                messageType: MessageType.movieList,
                richData: data,
              ),
            );
          });
          _scrollToBottom();
        }
        break;
      case 'movie_details_card':
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              text: '',
              sender: ChatSender.bot,
              messageType: MessageType.movieDetail,
              richData: data,
            ),
          );
        });
        _scrollToBottom();
        break;
      default:
        debugPrint('Unknown action: $action');
    }
  }

  /// Navigate to seat booking with chatbot parameters
  void _openSeatBookingPage(Map<String, dynamic> data) {
    try {
      final movieId = data['movie_id'] as int? ?? 0;
      final movieTitle = data['movie'] as String? ?? 'Movie';
      final subtitle = data['subtitle'] as String? ?? 'AI Assistant booking';
      final showTime = data['show_time'] as String? ?? '07:15 PM';
      final seats = data['seats'] as int? ?? 2;

      Get.toNamed(
        AppRoutes.seatBooking,
        arguments: {
          'itemId': movieId,
          'itemTitle': movieTitle,
          'itemSubtitle': subtitle,
          'initialShowTime': showTime,
          'requestedSeats': seats,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening seat page: $e')),
      );
    }
  }

  /// Open movie details screen
  void _openMovieDetails(Map<String, dynamic> data) {
    try {
      final movie = Movie(
        id: data['movie_id'] as int? ?? 0,
        title: data['movie'] as String? ?? '',
        description: data['description'] as String? ?? '',
        genre: data['genre'] as String? ?? '',
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        duration: data['duration'] as int? ?? 0,
        imageUrl: data['image_url'] as String? ?? '',
      );
      Get.toNamed(AppRoutes.movieDetails, arguments: movie);
    } catch (e) {
      debugPrint('Error opening movie details: $e');
    }
  }

  /// Show available shows
  void _showAvailableShows(Map<String, dynamic> data) {
    final showTimes = List<String>.from(data['show_times'] as List? ?? []);
    if (showTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No show times available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Available Show Times',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: showTimes
                  .map((time) => Chip(
                        label: Text(time),
                        backgroundColor: const Color(0xFFE11D48),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messages.insert(0, ChatMessage(text: text, sender: ChatSender.user));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      // Call API with session ID if available
      final response = await ApiService.chat(
        message: text,
        sessionId: _sessionId,
      );

      // Update session ID
      _sessionId = response.sessionId;

      setState(() {
        _messages.insert(
          0,
          ChatMessage(text: response.reply, sender: ChatSender.bot),
        );
      });
      _scrollToBottom();

      // Speak the response if TTS is enabled
      if (_ttsEnabled) {
        await _tts.stop();
        await _tts.speak(response.reply);
      }

      // Handle action if provided
      if (response.action != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _handleAction(response.action, response.data);
        }
      }
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: "Sorry, I couldn't reach the server. ($e)",
            sender: ChatSender.bot,
          ),
        );
      });
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleMic() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    // Request mic permission explicitly before initializing
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Microphone permission denied. Enable it in Settings."),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Re-initialize on every tap so permission change takes effect
    _speech = stt.SpeechToText();

    final available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('STT status: $status');
        if ((status == 'notListening' || status == 'done') && mounted) {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        debugPrint('STT error: ${error.errorMsg} permanent=${error.permanent}');
        if (!mounted) return;
        setState(() => _isListening = false);
        // timeout and no-match are normal "no speech detected" cases — don't alarm the user
        if (error.errorMsg == 'error_speech_timeout' ||
            error.errorMsg == 'error_no_match') {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Voice error: ${error.errorMsg}")),
        );
      },
      debugLogging: true,
    );

    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Speech recognition not available. Make sure Google app is installed.",
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _controller.clear();
    });

    await _speech.listen(
      onResult: (res) {
        if (!mounted) return;
        setState(() {
          _controller.text = res.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
        // finalResult is the correct flag for the last recognised result
        if (res.finalResult && res.recognizedWords.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _controller.text.isNotEmpty) {
              _send();
            }
          });
        }
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🎬 CineSmart Voice Assistant",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Tooltip(
            message: 'Enable voice replies',
            child: Row(
              children: [
                const Text("🔊", style: TextStyle(fontWeight: FontWeight.w700)),
                Switch(
                  value: _ttsEnabled,
                  onChanged: (v) => setState(() => _ttsEnabled = v),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text("Start by speaking or typing..."),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final m = _messages[index];
                        return _Bubble(
                          message: m,
                          onBookMovie: _openSeatBookingPage,
                          onViewDetails: (data) {
                            setState(() {
                              _messages.insert(
                                0,
                                ChatMessage(
                                  text: '',
                                  sender: ChatSender.bot,
                                  messageType: MessageType.movieDetail,
                                  richData: data,
                                ),
                              );
                            });
                            _scrollToBottom();
                          },
                        );
                      },
                    ),
            ),
            if (_sending)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: SizedBox(
                  height: 18,
                  child: Text(
                    "🤖 Assistant is typing…",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            _Composer(
              controller: _controller,
              isListening: _isListening,
              onMic: _toggleMic,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(Map<String, dynamic>)? onBookMovie;
  final void Function(Map<String, dynamic>)? onViewDetails;

  const _Bubble({
    required this.message,
    this.onBookMovie,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (message.messageType == MessageType.movieList) {
      return _MovieListBubble(
        data: message.richData ?? {},
        onBookMovie: onBookMovie,
        onViewDetails: onViewDetails,
      );
    }
    if (message.messageType == MessageType.movieDetail) {
      return _MovieDetailBubble(
        data: message.richData ?? {},
        onBookMovie: onBookMovie,
        onViewFullDetails: onViewDetails != null
            ? (_) => onViewDetails!(message.richData ?? {})
            : null,
      );
    }

    final isUser = message.sender == ChatSender.user;
    final bg = isUser ? const Color(0xFFE11D48) : Colors.white;
    final fg = isUser ? Colors.white : Colors.black87;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 16),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            boxShadow: !isUser
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
            border: isUser ? null : Border.all(color: const Color(0xFFEAEAF0)),
          ),
          child: SelectableText(
            message.text,
            style: TextStyle(
              color: fg,
              fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Movie list horizontal scroll ────────────────────────────────────────────

class _MovieListBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic>)? onBookMovie;
  final void Function(Map<String, dynamic>)? onViewDetails;

  const _MovieListBubble({required this.data, this.onBookMovie, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final movies = data['movies'] as List<dynamic>? ?? [];
    final heading = data['heading'] as String? ?? 'Now Showing';

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              heading,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 8),
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final m = movies[i] as Map<String, dynamic>;
                return _MovieCard(
                  movieData: m,
                  onBook: onBookMovie != null ? () => onBookMovie!(m) : null,
                  onDetails: onViewDetails != null ? () => onViewDetails!(m) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Map<String, dynamic> movieData;
  final VoidCallback? onBook;
  final VoidCallback? onDetails;

  const _MovieCard({required this.movieData, this.onBook, this.onDetails});

  @override
  Widget build(BuildContext context) {
    final title = movieData['movie'] as String? ?? '';
    final genre = movieData['genre'] as String? ?? '';
    final rating = (movieData['rating'] as num?)?.toStringAsFixed(1) ?? '';
    final imageUrl = movieData['image_url'] as String? ?? '';

    return Container(
      width: 135,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 95,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _posterPlaceholder(),
                  )
                : _posterPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFBBF24)),
                const SizedBox(width: 2),
                Text(rating,
                    style: const TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(genre,
                      style: const TextStyle(fontSize: 10, color: Colors.black38),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onDetails,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE11D48)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Info',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFE11D48),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: GestureDetector(
                    onTap: onBook,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Book',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  Widget _posterPlaceholder() {
    return Container(
      height: 95,
      color: const Color(0xFFE11D48).withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.movie_rounded, color: Color(0xFFE11D48), size: 36),
      ),
    );
  }
}

// ─── Movie detail card ────────────────────────────────────────────────────────

class _MovieDetailBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic>)? onBookMovie;
  final void Function(Map<String, dynamic>)? onViewFullDetails;

  const _MovieDetailBubble({
    required this.data,
    this.onBookMovie,
    this.onViewFullDetails,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['movie'] as String? ?? '';
    final description = data['description'] as String? ?? '';
    final genre = data['genre'] as String? ?? '';
    final rating = (data['rating'] as num?)?.toStringAsFixed(1) ?? '';
    final duration = data['duration'] as int? ?? 0;
    final imageUrl = data['image_url'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: const Color(0xFFE11D48).withOpacity(0.1),
                  child: const Center(
                    child: Icon(Icons.movie_rounded,
                        color: Color(0xFFE11D48), size: 48),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text(
              title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 15, color: Color(0xFFFBBF24)),
                const SizedBox(width: 4),
                Text(rating,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(width: 12),
                const Icon(Icons.category_outlined,
                    size: 13, color: Colors.black38),
                const SizedBox(width: 4),
                Text(genre,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 12),
                const Icon(Icons.schedule, size: 13, color: Colors.black38),
                const SizedBox(width: 4),
                Text('${duration}m',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Text(
                description,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54, height: 1.4),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE11D48),
                      side: const BorderSide(color: Color(0xFFE11D48)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onViewFullDetails != null
                        ? () => onViewFullDetails!(data)
                        : null,
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed:
                        onBookMovie != null ? () => onBookMovie!(data) : null,
                    icon: const Icon(Icons.confirmation_number_outlined,
                        size: 16),
                    label: const Text('Book Tickets',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onMic;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.isListening,
    required this.onMic,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAF0), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: isListening ? "🎤 Listening…" : "Type or speak...",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE11D48),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening
                    ? const Color(0xFFE11D48)
                    : Colors.grey.withOpacity(0.1),
              ),
              child: IconButton(
                onPressed: onMic,
                icon: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: isListening ? Colors.white : const Color(0xFFE11D48),
                  size: 20,
                ),
                tooltip: 'Voice input',
              ),
            ),
            const SizedBox(width: 6),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onSend,
              child: const Text(
                "Send",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

