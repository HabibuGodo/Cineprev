import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import '../models/RequestedandFavorited.dart';
import '../models/RequestedandFavorited_trailers.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "movieDb.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE Requested(id INTEGER PRIMARY KEY,name TEXT, movie_id INT,poster_path BLOB,backdrop_path BLOB,release_date TEXT,vote_count TEXT,vote_average TEXT,genres TEXT,description TEXT,popularity TEXT)");

    await db.execute(
        "CREATE TABLE RequestedTrailer(id INTEGER PRIMARY KEY, movie_id INT,title TEXT,link TEXT)");

    await db.execute(
        "CREATE TABLE Favorited(id INTEGER PRIMARY KEY,name TEXT, movie_id INT,poster_path BLOB,backdrop_path BLOB,release_date TEXT,vote_count TEXT,vote_average TEXT,genres TEXT,description TEXT,popularity TEXT)");

    await db.execute(
        "CREATE TABLE FavoritedTrailer(id INTEGER PRIMARY KEY, movie_id INT,title TEXT,link TEXT)");
  }

//requested movie
  Future<int> insertMovieRequested(RequestedandFavorited requested) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM Requested WHERE movie_id = ?", [requested.movie_id]);

    int res;
    list.length == 0
        ? {res = await dbClient.insert("Requested", requested.toMap())}
        : {};
    return res;
  }

//Insert requested movie trailer
  Future<int> insertMovieRequestedTrailer(Trailer requestedtrailer) async {
    var dbClient = await db;

    int res =
        await dbClient.insert("RequestedTrailer", requestedtrailer.toMap());

    return res;
  }

//get requested movies list
  Future<List<RequestedandFavorited>> getRequested() async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery("SELECT * FROM Requested ORDER BY id DESC");
    List<RequestedandFavorited> requests = List();
    for (var i = 0; i < list.length; i++) {
      var requested = RequestedandFavorited(
        list[i]["name"],
        list[i]["movie_id"],
        list[i]["poster_path"],
        list[i]["backdrop_path"],
        list[i]["release_date"],
        list[i]["vote_count"],
        list[i]["vote_average"],
        list[i]["genres"],
        list[i]["description"],
        list[i]["popularity"],
      );
      requested.setRequestedId(list[i]["id"]);
      requests.add(requested);
    }
    return requests;
  }

//get requested movies trailers
  Future<List<Trailer>> getMovieRequestedTrailers(int movie_id) async {
    var dbClient = await db;
    List<Map<String, dynamic>> list = [];
    list = await dbClient.rawQuery(
        "SELECT * FROM RequestedTrailer WHERE movie_id = ?", [movie_id]);
    List<Trailer> requests = List();
    for (var i = 0; i < list.length; i++) {
      Trailer d = Trailer(list[i]['title'], list[i]['link']);
      d.movie_id = movie_id;
      requests.add(d);
    }
    return requests;
  }

//delete requested movie
  Future<int> deleteRequested(int movie_id) async {
    var dbClient = await db;
    int res = await dbClient
        .rawDelete("DELETE FROM Requested WHERE movie_id = ?", [movie_id]);
    return res;
  }

//delete requested movie's trailers
  Future<int> deleteRequestedTrailer(int movie_id) async {
    var dbClient = await db;
    int res = await dbClient.rawDelete(
        "DELETE FROM RequestedTrailer WHERE movie_id = ?", [movie_id]);
    return res;
  }

//update requested movies list
  Future<bool> update(RequestedandFavorited requested) async {
    var dbClient = await db;
    int res = await dbClient.update("Requested", requested.toMap(),
        where: 'id = ?', whereArgs: <int>[requested.id]);

    return res > 0 ? true : false;
  }

//get individual requested movie
  Future<bool> requestSent(int movie_id) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery("SELECT * FROM Requested WHERE movie_id = ?", [movie_id]);

    return list.length > 0 ? true : false;
  }

///////////////////////////////FAVORITED BELOW//////////////////////////////////////

  Future<int> insertMovieFavorited(RequestedandFavorited favorited) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM Favorited WHERE movie_id = ?", [favorited.movie_id]);

    int res;
    list.length == 0
        ? {res = await dbClient.insert("Favorited", favorited.toMap())}
        : {};
    return res;
  }

  Future<int> insertMovieFavoritedTrailer(Trailer favoritedtrailer) async {
    var dbClient = await db;

    int res =
        await dbClient.insert("FavoritedTrailer", favoritedtrailer.toMap());

    return res;
  }

  Future<List<RequestedandFavorited>> getFavorited() async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery("SELECT * FROM Favorited ORDER BY id DESC");
    List<RequestedandFavorited> favorites = List();
    for (var i = 0; i < list.length; i++) {
      var favorited = RequestedandFavorited(
        list[i]["name"],
        list[i]["movie_id"],
        list[i]["poster_path"],
        list[i]["backdrop_path"],
        list[i]["release_date"],
        list[i]["vote_count"],
        list[i]["vote_average"],
        list[i]["genres"],
        list[i]["description"],
        list[i]["popularity"],
      );
      favorited.setRequestedId(list[i]["id"]);
      favorites.add(favorited);
    }
    return favorites;
  }

  Future<List<Trailer>> getMovieFavoritedTrailers(int movie_id) async {
    var dbClient = await db;
    List<Map<String, dynamic>> list = [];
    list = await dbClient.rawQuery(
        "SELECT * FROM FavoritedTrailer WHERE movie_id = ?", [movie_id]);
    List<Trailer> favorites = List();
    for (var i = 0; i < list.length; i++) {
      Trailer d = Trailer(list[i]['title'], list[i]['link']);
      d.movie_id = movie_id;
      favorites.add(d);
    }
    return favorites;
  }

  Future<int> deleteFavorited(int movie_id) async {
    var dbClient = await db;
    int res = await dbClient
        .rawDelete("DELETE FROM Favorited WHERE movie_id = ?", [movie_id]);
    return res;
  }

  Future<int> deleteFavoritedTrailer(int movie_id) async {
    var dbClient = await db;
    int res = await dbClient.rawDelete(
        "DELETE FROM FavoritedTrailer WHERE movie_id = ?", [movie_id]);
    return res;
  }

  Future<bool> updateFavorited(RequestedandFavorited favorited) async {
    var dbClient = await db;
    int res = await dbClient.update("Favorited", favorited.toMap(),
        where: 'id = ?', whereArgs: <int>[favorited.id]);

    return res > 0 ? true : false;
  }

  Future<bool> isItFavorited(int movie_id) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery("SELECT * FROM Favorited WHERE movie_id = ?", [movie_id]);

    return list.length > 0 ? true : false;
  }
}
