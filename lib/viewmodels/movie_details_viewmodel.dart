import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

class MovieDetailsViewModel extends ChangeNotifier {
  final MovieRepository _repository;

  Movie? _movie;
  bool _isLoading = false;
  String? _errorMessage;

  MovieDetailsViewModel(this._repository);

  // Getters
  Movie? get movie => _movie;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Load movie details
  Future<void> loadMovieDetails(int movieId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _movie = await _repository.getMovieDetails(movieId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load movie details: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(' Error loading movie details: $e');
    }
  }

  // Toggle bookmark - FIXED
  Future<void> toggleBookmark() async {
    if (_movie == null) return;

    try {
      final currentMovie = _movie!;
      final newBookmarkState = !currentMovie.isBookmarked;

      // Optimistically update UI
      _movie = currentMovie.copyWith(isBookmarked: newBookmarkState);
      notifyListeners();

      // Perform the actual operation
      if (newBookmarkState) {
        await _repository.addBookmark(currentMovie);
      } else {
        await _repository.removeBookmark(currentMovie.id);
      }

      // Reload to ensure consistency
      await loadMovieDetails(currentMovie.id);
    } catch (e) {
      // Revert on error
      if (_movie != null) {
        _movie = _movie!.copyWith(isBookmarked: !_movie!.isBookmarked);
        notifyListeners();
      }
      _errorMessage = 'Failed to update bookmark';
      notifyListeners();
      debugPrint('Error toggling bookmark: $e');
    }
  }

  // Get share text
  String getShareText() {
    if (_movie == null) return '';

    final deepLink = 'moviesapp://movie/${_movie!.id}';
    return 'Check out ${_movie!.title}!\n\n$deepLink';
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _movie = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}