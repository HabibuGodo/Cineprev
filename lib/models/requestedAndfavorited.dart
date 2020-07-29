
class RequestedandFavorited {
  int id;
  String name;
  int movie_id;
  String poster_path;
  String backdrop_path;
  String release_date;
  String vote_count;
  String vote_average;
  String genres;
  String description;
  String popularity;

  RequestedandFavorited(
      this.name,
      this.movie_id,
      this.poster_path,
      this.backdrop_path,
      this.release_date,
      this.vote_count,
      this.vote_average,
      this.genres,
      this.description,
      this.popularity);

  RequestedandFavorited.map(dynamic obj) {
    this.name = obj["name"];
    this.movie_id = obj["movie_id"];
    this.poster_path = obj["poster_path"];
    this.backdrop_path = obj["backdrop_path"];
    this.release_date = obj["release_date"];
    this.vote_count = obj["vote_count"];
    this.vote_average = obj["vote_average"];
    this.genres = obj["genres"];
    this.description = obj["description"];
    this.popularity = obj["popularity"];
  }

  String get getname => name;
  int get getmovie_id => movie_id;
  String get getposter_path => poster_path;
  String get getbackdrop_path => backdrop_path;
  String get getrelease_datee => release_date;
  String get getvote_count => vote_count;
  String get getvote_average => vote_average;
  String get getgenres => genres;
  String get getdescription => description;
  String get getpopularity => popularity;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['name'] = name;
    map['movie_id'] = movie_id;
    map['poster_path'] = poster_path;
    map['backdrop_path'] = backdrop_path;
    map['release_date'] = release_date;
    map['vote_count'] = vote_count;
    map['vote_average'] = vote_average;
    map['genres'] = genres;
    map['description'] = description;
    map['popularity'] = popularity;

    return map;
  }

  void setRequestedId(int id) {
    this.id = id;
  }
}
