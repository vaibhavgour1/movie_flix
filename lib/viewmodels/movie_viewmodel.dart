import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _repository;

  MovieViewModel(this._repository);

  List<Movie> _trendingMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;
  List<Movie> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTrendingMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trendingMovies = await _repository.getTrendingMovies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNowPlayingMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _nowPlayingMovies = await _repository.getNowPlayingMovies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchMovies(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMovies() async {
    await Future.wait([
      loadTrendingMovies(),
      loadNowPlayingMovies(),
    ]);
  }
}