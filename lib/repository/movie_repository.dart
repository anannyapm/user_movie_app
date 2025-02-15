import 'package:dio/dio.dart';
import 'package:sample_project/core/di/locator.dart';
import 'package:sample_project/core/utils/const.dart';

import '../core/models/movie_model.dart';

class MovieRepository {
  final Dio dio = getIt<Dio>();

  //Get Movies
  Future<List<MovieModel>> getMovies(int page) async {
    final response = await dio.get(
        "https://api.themoviedb.org/3/trending/movie/day",
        queryParameters: {
          "language": "en-US",
          "page": page,
          "api_key": apiKey
        });
    return (response.data['results'] as List)
        .map((json) => MovieModel.fromJson(json))
        .toList();
  }

  //Get Movie Details
  Future<MovieModel> fetchMovieDetails(int movieId) async {
    final url = 'https://api.themoviedb.org/3/movie/$movieId';

    final response = await dio
        .get(url, queryParameters: {"language": "en-US", "api_key": apiKey});

    if (response.statusCode == 200) {
      return MovieModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}
