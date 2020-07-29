class ItemModel {
  int page;
  int total_page;
  int total_results;
  List<Result> results = [];

  ItemModel.fromJson(Map<String, dynamic> parseJson, bool isRecent) {
    page = parseJson['page'];
    total_results = parseJson['total_results'];
    total_page = parseJson['total_page'];

    //hold results temporary
    List<Result> temp = [];
    for (var i = 0; i < parseJson['results'].length; i++) {
      Result result = Result(parseJson['results'][i]);
      temp.add(result);
    }

    if (!isRecent) {
      temp.sort((a, b) {
        return b.popularity.compareTo(a.popularity);
      });
    } else {
      temp.sort((a, b) {
        return DateTime.parse(b.release_date)
            .compareTo(DateTime.parse(a.release_date));
      });
    }
    results = temp;
  }

  List<Result> get result => results;

  int get totalPages => totalPages;

  int get totalResults => totalResults;

  int get pages => page;
}

class Result {
  String vote_count;
  int id;
  bool video;
  String vote_average;
  String title;
  var popularity;
  String poster_path;
  List<int> genre_ids = [];
  String backdrop_path;
  bool adult;
  String overview;
  String release_date;

  Result(result) {
    vote_count = result['vote_count'].toString();
    id = result['id'];
    video = result['video'];
    vote_average = result['vote_average'].toString();
    title = result['title'].toString();
    popularity = result['popularity'];
    poster_path = result['poster_path'].toString();
    for (var i = 0; i < result['genre_ids'].length; i++) {
      genre_ids.add(result['genre_ids'][i]);
    }
    backdrop_path = result['backdrop_path'].toString();
    adult = result['adult'];
    overview = result['overview'];
    release_date = result['release_date'].toString();
  }

  String get get_release_date => release_date;
  String get get_overview => overview;
  bool get get_adult => adult;
  String get get_backdrop_path => backdrop_path;
  List<int> get get_genre_ids => genre_ids;
  String get get_poster_path => poster_path;
  double get get_popularity => popularity;
  String get get_title => title;
  String get get_vote_average => vote_average;
  bool get is_vide0 => video;
  int get get_id => id;
  String get get_vote_count => vote_count;
}
