import 'dart:async';
import '../database/database_helper.dart';
import '../models/RequestedandFavorited_trailers.dart';
import '../models/RequestedandFavorited.dart';

abstract class HomeContract {
  void screenUpdate();
}

class HomePresenter {
  HomeContract _view;
  var db = DatabaseHelper();
  HomePresenter(this._view);

//requested deletion
  deleteRequested(int movie_id) {
    var db = DatabaseHelper();
    db.deleteRequested(movie_id);
    db.deleteRequestedTrailer(movie_id);
    updateScreen();
  }

//Favorite deletion
  deleteFavorited(int movie_id) {
    var db = DatabaseHelper();
    db.deleteFavorited(movie_id);
    db.deleteFavoritedTrailer(movie_id);
    updateScreen();
  }


////////////////for requested///////////////////////////
  Future<List<RequestedandFavorited>> getRequested() {
    return db.getRequested();
  }

  Future<List<Trailer>> getRequestedTrailers(int movie_id) {
    return db.getMovieRequestedTrailers(movie_id);
  }

  Future<bool> requestSent(movie_id) {
    return db.requestSent(movie_id);
  }

//////////////////////////////////////////////////////////////

/////////////////////for favorites////////////////////////////

  Future<List<RequestedandFavorited>> getFavorite() {
    return db.getFavorited();
  }

  Future<List<Trailer>> getFavoriteTrailers(int movie_id) {
    return db.getMovieFavoritedTrailers(movie_id);
  }

  Future<bool> isItFavorited(movie_id) {
    return db.isItFavorited(movie_id);
  }

  updateScreen() {
    _view.screenUpdate();
  }
}
