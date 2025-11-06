import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

class BookmarkViewModel extends ChangeNotifier {
  final MovieRepository _repository;

  BookmarkViewModel(this._repository);

  List<Movie> _bookmarkedMovies = [];
  bool _isLoading = false;

  List<Movie> get bookmarkedMovies => _bookmarkedMovies;
  bool get isLoading => _isLoading;

  Future<void> loadBookmarkedMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookmarkedMovies = await _repository.getBookmarkedMovies();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(Movie movie) async {
    await _repository.toggleBookmark(movie);
    await loadBookmarkedMovies();
  }

  bool isBookmarked(int movieId) {
    return _bookmarkedMovies.any((movie) => movie.id == movieId);
  }
}