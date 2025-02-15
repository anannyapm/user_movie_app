import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import '../repository/movie_repository.dart';
import '../core/models/movie_model.dart';

class MovieProvider with ChangeNotifier {
  final MovieRepository repository;
  MovieProvider(this.repository);
  final List<MovieModel> _movies = [];
  List<MovieModel> get movies => _movies;

  int _currentPage = 1;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  resetCurrPage() {
    _currentPage = 1;
  }

  Future<void> fetchTrendingMovies() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching movies $_currentPage');
      final newMovies = await repository.getMovies(_currentPage);
      _movies.addAll(newMovies);
      _currentPage++;
    } catch (e) {
      developer.log('Error fetching movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<MovieModel?> fetchMovieDetails(int movieId) async {
    try {
      return await repository.fetchMovieDetails(movieId);
    } catch (e) {
      developer.log('Error fetching movie details: $e');
      return null;
    }
  }
}
