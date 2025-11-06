import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../models/movie.dart';
import '../widgets/movie_list.dart';
import '../details/movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<MovieViewModel>();
      viewModel.loadTrendingMovies();
      viewModel.loadNowPlayingMovies();
    });
  }

  Future<void> _refreshMovies() async {
    await context.read<MovieViewModel>().refreshMovies();
  }

  void _navigateToDetails(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movieId: movie.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        elevation: 0,
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading &&
              viewModel.trendingMovies.isEmpty &&
              viewModel.nowPlayingMovies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _refreshMovies,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  MovieList(
                    title: 'Trending This Week',
                    movies: viewModel.trendingMovies,
                    onMovieTap: _navigateToDetails,
                  ),
                  const SizedBox(height: 24),
                  MovieList(
                    title: 'Now Playing',
                    movies: viewModel.nowPlayingMovies,
                    onMovieTap: _navigateToDetails,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}