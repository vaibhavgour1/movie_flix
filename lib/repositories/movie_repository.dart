import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import '../core/datatbase/database_helper.dart';
import '../models/movie.dart';
import '../services/tmdb_api.dart';

class MovieRepository {
  // Better: Load from .env or secure storage
  static const String apiKey = String.fromEnvironment('TMDB_API_KEY',
  defaultValue: '67af5e631dcbb4d0981b06996fcd47bc'
  );

  final TmdbApi _api;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Connectivity _connectivity = Connectivity();

  MovieRepository(this._api);

  Future<bool> _isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<Movie>> getTrendingMovies() async {
    try {
      if (await _isConnected()) {
        final response = await _api.getTrendingMovies(apiKey);
        await _db.clearCategory('trending');
        await _db.insertMovies(response.results, 'trending');
        return response.results;
      }
    } on DioException catch (e) {
      debugPrint('Network error fetching trending movies: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching trending movies: $e');
    }

    // Always fallback to local data
    return await _db.getMoviesByCategory('trending');
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      if (await _isConnected()) {
        final response = await _api.getNowPlayingMovies(apiKey);
        await _db.clearCategory('now_playing');
        await _db.insertMovies(response.results, 'now_playing');
        return response.results;
      }
    } catch (e) {
      debugPrint('Error fetching now playing movies: $e');
    }

    return await _db.getMoviesByCategory('now_playing');
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      if (await _isConnected()) {
        final response = await _api.searchMovies(apiKey, query);
        for (var movie in response.results) {
          await _db.insertMovie(movie, category: 'search');
        }
        return response.results;
      }
    } catch (e) {
      debugPrint('Error searching movies: $e');
    }

    return await _db.searchMovies(query);
  }

  Future<Movie?> getMovieDetails(int movieId) async {
    try {
      if (await _isConnected()) {
        final movie = await _api.getMovieDetails(movieId, apiKey);
        final existingMovie = await _db.getMovieById(movieId);
        movie.isBookmarked = existingMovie?.isBookmarked ?? false;
        await _db.insertMovie(movie, category: 'details');
        return movie;
      }
    } catch (e) {
      debugPrint('Error fetching movie details: $e');
    }

    return await _db.getMovieById(movieId);
  }

  // ADDED: Add bookmark method
  Future<void> addBookmark(Movie movie) async {
    movie.isBookmarked = true;
    await _db.updateMovieBookmark(movie.id, true);
    // Also insert the movie if it doesn't exist
    await _db.insertMovie(movie, category: 'bookmarked');
  }

  // ADDED: Remove bookmark method
  Future<void> removeBookmark(int movieId) async {
    await _db.updateMovieBookmark(movieId, false);
  }

  // Keep this for backwards compatibility
  Future<void> toggleBookmark(Movie movie) async {
    movie.isBookmarked = !movie.isBookmarked;
    await _db.updateMovieBookmark(movie.id, movie.isBookmarked);

    if (movie.isBookmarked) {
      await _db.insertMovie(movie, category: 'bookmarked');
    }
  }

  Future<List<Movie>> getBookmarkedMovies() async {
    return await _db.getBookmarkedMovies();
  }
}