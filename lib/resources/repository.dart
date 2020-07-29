import '../models/genre_model.dart';
import '../models/item_model.dart';
import '../models/trailer_model.dart';
import './movie_api.dart';

class Repository {

  int page;
  final movieApi = MovieApi();

  Future<ItemModel> fetchAllMovies() => movieApi.fetchMovieList(true,this.page);

  Future<ItemModel> fetchAllPopularMovies() => movieApi.fetchMoviePopularList(false,this.page);
  Future<GenreModel> fetchAllGenres() => movieApi.fetchGenreList();
  Future<TrailerModel> fetchTrailers(int movieId) => movieApi.fetchTrailers(movieId);
}
