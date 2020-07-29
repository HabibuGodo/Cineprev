import 'package:http/http.dart' show Client;
import 'dart:async';
import 'dart:convert';

import '../models/item_model.dart';
import '../models/genre_model.dart';
import '../models/trailer_model.dart';

class MovieApi {
  Client client = Client();

  final _apikey = '6c326e785878860f2982c80f0be1b3d5';
  final _baseurl = 'http://api.themoviedb.org/3/movie';

//now playing
  Future<ItemModel> fetchMovieList(bool isRecent, int page) async {
    //print('entered');
    final response =
        await client.get("$_baseurl/now_playing?api_key=$_apikey&page=$page");

    if (response.statusCode == 200) {
      return ItemModel.fromJson(json.decode(response.body), isRecent);
    } else {
      throw Exception('Failed to load post');
    }
  }

//popular movies
  Future<ItemModel> fetchMoviePopularList(bool isRecent, int page) async {
    //print('entered');
    final response =
        await client.get("$_baseurl/popular?api_key=$_apikey&page=$page");
    //print(response.body.toString());
    if (response.statusCode == 200) {
      return ItemModel.fromJson(json.decode(response.body), isRecent);
    } else {
      throw Exception('Failed to load post');
    }
  }

//genre
  Future<GenreModel> fetchGenreList() async {
    //print('entered Genre');
    final response = await client
        .get("http://api.themoviedb.org/3/genre/movie/list?api_key=$_apikey");
    //print(response.body.toString());
    if (response.statusCode == 200) {
      return GenreModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  //Trailers
  Future<TrailerModel> fetchTrailers(int movieId) async {
    //print('entered Trailer');
    final response = await client
        .get("$_baseurl/$movieId.toString()/videos?api_key=$_apikey");
    //print(response.body.toString());
    if (response.statusCode == 200) {
      return TrailerModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }
}
