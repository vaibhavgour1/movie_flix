

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../repositories/movie_repository.dart';
import '../../viewmodels/movie_details_viewmodel.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MovieDetailsViewModel(
        context.read<MovieRepository>(),
      )..loadMovieDetails(movieId),
      child: const _MovieDetailsContent(),
    );
  }
}

class _MovieDetailsContent extends StatelessWidget {
  const _MovieDetailsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieDetailsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.clearError();
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.movie == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Movie not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _AppBarSection(movie: viewModel.movie!),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderSection(movie: viewModel.movie!),
                    _OverviewSection(movie: viewModel.movie!),
                    _DetailsSection(movie: viewModel.movie!),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AppBarSection extends StatelessWidget {
  final dynamic movie;

  const _AppBarSection({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MovieDetailsViewModel>();

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (movie.backdropUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: movie.backdropUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.movie, size: 80),
                ),
              )
            else
              Container(
                color: Colors.grey[900],
                child: const Icon(Icons.movie, size: 80),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Consumer<MovieDetailsViewModel>(
          builder: (context, vm, child) {
            return IconButton(
              icon: Icon(
                vm.movie?.isBookmarked ?? false
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
              onPressed: () => viewModel.toggleBookmark(),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            final shareText = viewModel.getShareText();
            if (shareText.isNotEmpty) {
              Share.share(
                shareText,
                subject: movie.title,
              );
            }
          },
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final dynamic movie;

  const _HeaderSection({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: movie.posterUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: movie.posterUrl,
              width: 120,
              height: 180,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 120,
                height: 180,
                color: Colors.grey[800],
              ),
              errorWidget: (context, url, error) => Container(
                width: 120,
                height: 180,
                color: Colors.grey[800],
                child: const Icon(Icons.movie, size: 50),
              ),
            )
                : Container(
              width: 120,
              height: 180,
              color: Colors.grey[800],
              child: const Icon(Icons.movie, size: 50),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (movie.tagline != null && movie.tagline!.isNotEmpty)
                  Text(
                    movie.tagline!,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[400],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage?.toStringAsFixed(1) ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${movie.voteCount ?? 0} votes)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (movie.genres != null && movie.genres!.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genres!.map<Widget>((genre) {
                      return Chip(
                        label: Text(
                          genre.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey[800],
                        padding: EdgeInsets.zero,
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

class _OverviewSection extends StatelessWidget {
  final dynamic movie;

  const _OverviewSection({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (movie.overview == null || movie.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final dynamic movie;

  const _DetailsSection({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty)
            _DetailRow(label: 'Release Date', value: movie.releaseDate!),
          if (movie.runtime != null)
            _DetailRow(label: 'Runtime', value: '${movie.runtime} minutes'),
          if (movie.status != null && movie.status!.isNotEmpty)
            _DetailRow(label: 'Status', value: movie.status!),
          if (movie.originalLanguage != null)
            _DetailRow(
              label: 'Language',
              value: movie.originalLanguage!.toUpperCase(),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}