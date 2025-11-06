import 'package:flutter/material.dart';

class SearchEmptyState extends StatefulWidget {
  const SearchEmptyState({Key? key}) : super(key: key);

  @override
  State<SearchEmptyState> createState() => _SearchEmptyStateState();
}

class _SearchEmptyStateState extends State<SearchEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated movie reel icon
                  _AnimatedMovieReel(),
                  const SizedBox(height: 32),

                  // Main heading
                  Text(
                    'Discover Your Next\nFavorite Movie',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                        ).createShader(
                          const Rect.fromLTWH(0, 0, 200, 70),
                        ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Search through thousands of movies\nand find exactly what you\'re looking for',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Search suggestions
                  _SearchSuggestions(),
                  const SizedBox(height: 40),

                  // Feature highlights
                  _FeatureHighlights(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedMovieReel extends StatefulWidget {
  @override
  State<_AnimatedMovieReel> createState() => _AnimatedMovieReelState();
}

class _AnimatedMovieReelState extends State<_AnimatedMovieReel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700.withOpacity(0.3),
                  Colors.purple.shade700.withOpacity(0.3),
                ],
              ),
            ),
            child: Icon(
              Icons.local_movies_rounded,
              size: 60,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        );
      },
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions = [
    {'icon': Icons.trending_up, 'text': 'Trending', 'color': Colors.orange},
    {'icon': Icons.star, 'text': 'Top Rated', 'color': Colors.amber},
    {'icon': Icons.new_releases, 'text': 'New Releases', 'color': Colors.green},
    {'icon': Icons.favorite, 'text': 'Romance', 'color': Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Try searching for:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: suggestions.map((suggestion) {
            return _SuggestionChip(
              icon: suggestion['icon'],
              text: suggestion['text'],
              color: suggestion['color'],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SuggestionChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureHighlights extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.search,
      'title': 'Smart Search',
      'description': 'Find movies by title, actor, or genre',
    },
    {
      'icon': Icons.offline_bolt,
      'title': 'Offline Access',
      'description': 'Search works even without internet',
    },
    {
      'icon': Icons.bookmark,
      'title': 'Save Favorites',
      'description': 'Bookmark movies to watch later',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'],
                  color: Colors.blue.shade400,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature['description'],
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
        );
      }).toList(),
    );
  }
}