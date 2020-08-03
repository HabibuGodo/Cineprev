import 'package:http/http.dart' show Client;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/item_model.dart';
import '../models/genre_model.dart';
import '../models/trailer_model.dart';

class MovieApi extends BaseCacheManager {
  var responseData;
  Client client = Client();

  final _apikey = '6c326e785878860f2982c80f0be1b3d5';
  final _baseurl = 'http://api.themoviedb.org/3/movie';

  static const key = "customCache";

  static MovieApi _instance;

  // singleton implementation
  // for the custom cache manager
  factory MovieApi() {
    if (_instance == null) {
      _instance = new MovieApi._();
    }
    return _instance;
  }

  // pass the default setting values to the base class
  // link the custom handler to handle HTTP calls
  // via the custom cache manager
  MovieApi._()
      : super(
          key,
          maxAgeCacheObject: Duration(days: 7),
          maxNrOfCacheObjects: 50,
        );

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return path.join(directory.path, key);
  }

//now playing
  Future<ItemModel> fetchMovieList(bool isRecent, int page) async {
    try {
      var file = await MovieApi()
          .getSingleFile("$_baseurl/now_playing?api_key=$_apikey&page=$page");
      if (file != null && await file.exists()) {
        var res = await file.readAsString();

        responseData = jsonDecode(res);
        //print(responseData);
        return ItemModel.fromJson(responseData, isRecent);
      }
    } on SocketException {
      print('No internet connection');
    } catch (e) {
      // print("error imetokea");
      throw Exception('Failed to load post');
    }
    return null;
  }

//now playing
  // Future<ItemModel> fetchMovieList(bool isRecent, int page) async {
  //   //print('entered');
  //   final response =
  //       await client.get("$_baseurl/now_playing?api_key=$_apikey&page=$page");

  //   if (response.statusCode == 200) {
  //     return ItemModel.fromJson(json.decode(response.body), isRecent);
  //   } else {
  //     throw Exception('Failed to load post');
  //   }
  // }

//popular movies
  Future<ItemModel> fetchMoviePopularList(bool isRecent, int page) async {
    try {
      var file = await MovieApi()
          .getSingleFile("$_baseurl/popular?api_key=$_apikey&page=$page");
      if (file != null && await file.exists()) {
        var res = await file.readAsString();

        responseData = jsonDecode(res);
        //print(responseData);
        return ItemModel.fromJson(responseData, isRecent);
      }
    } on SocketException {
      print('No internet connection');
    } catch (e) {
      // print("error imetokea");
      throw Exception('Failed to load post');
    }
    return null;
  }

// //popular movies
//   Future<ItemModel> fetchMoviePopularList(bool isRecent, int page) async {
//     //print('entered');
//     final response =
//         await client.get("$_baseurl/popular?api_key=$_apikey&page=$page");
//     //print(response.body.toString());
//     if (response.statusCode == 200) {
//       return ItemModel.fromJson(json.decode(response.body), isRecent);
//     } else {
//       throw Exception('Failed to load post');
//     }
//   }

//genre
  Future<GenreModel> fetchGenreList() async {
    try {
      var file = await MovieApi().getSingleFile(
          "http://api.themoviedb.org/3/genre/movie/list?api_key=$_apikey");
      if (file != null && await file.exists()) {
        var res = await file.readAsString();

        responseData = jsonDecode(res);
        //print(responseData);
        return GenreModel.fromJson(responseData);
      }
    } on SocketException {
      print('No internet connection');
    } catch (e) {
      // print("error imetokea");
      throw Exception('Failed to load post');
    }
    return null;
  }

// //genre
//   Future<GenreModel> fetchGenreList() async {
//     //print('entered Genre');
//     final response = await client
//         .get("http://api.themoviedb.org/3/genre/movie/list?api_key=$_apikey");
//     //print(response.body.toString());
//     if (response.statusCode == 200) {
//       return GenreModel.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load post');
//     }
//   }

//Trailers
  Future<TrailerModel> fetchTrailers(int movieId) async {
    try {
      var file = await MovieApi().getSingleFile(
          "$_baseurl/$movieId.toString()/videos?api_key=$_apikey");
      if (file != null && await file.exists()) {
        var res = await file.readAsString();

        responseData = jsonDecode(res);
        //print(responseData);
        return TrailerModel.fromJson(responseData);
      }
    } on SocketException {
      print('No internet connection');
    } catch (e) {
      // print("error imetokea");
      throw Exception('Failed to load post');
    }
    return null;
  }

  // //Trailers
  // Future<TrailerModel> fetchTrailers(int movieId) async {
  //   //print('entered Trailer');
  //   final response = await client
  //       .get("$_baseurl/$movieId.toString()/videos?api_key=$_apikey");
  //   //print(response.body.toString());
  //   if (response.statusCode == 200) {
  //     return TrailerModel.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to load post');
  //   }
  // }
}
