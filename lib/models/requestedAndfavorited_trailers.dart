import './trailer_model.dart';

class RequestedandFavoritedTrailer {
  List<Trailer> results = [];

  RequestedandFavoritedTrailer.fromJson(TrailerModel json) {
    List<Trailer> temp = [];
    for (var i = 0; i < json.results.length; i++) {
      Trailer d = Trailer(json.results[i].name, json.results[i].key);
      temp.add(d);
    }

    results = temp;
  }
}

class Trailer {
  int movie_id;
  String title;
  String link;

  Trailer(this.title, this.link);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['movie_id'] = movie_id;
    map['title'] = title;
    map['link'] = link == null ? 'No link' : link ;

    return map;
  }
}
