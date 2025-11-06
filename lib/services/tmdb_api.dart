import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/movie.dart';

part 'tmdb_api.g.dart';

@RestApi(baseUrl: "https://api.themoviedb.org/3")
abstract class TmdbApi {
  factory TmdbApi(Dio dio, {String baseUrl}) = _TmdbApi;

  @GET("/trending/movie/week")
  Future<MoviesResponse> getTrendingMovies(
      @Query("api_key") String apiKey,
      [@Query("page") int page = 1]
      );

  @GET("/movie/now_playing")
  Future<MoviesResponse> getNowPlayingMovies(
      @Query("api_key") String apiKey,
      );

  @GET("/search/movie")
  Future<MoviesResponse> searchMovies(
      @Query("api_key") String apiKey,
      @Query("query") String query,
      );

  @GET("/movie/{movie_id}")
  Future<Movie> getMovieDetails(
      @Path("movie_id") int movieId,
      @Query("api_key") String apiKey,
      );
}

