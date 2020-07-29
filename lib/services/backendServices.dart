import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

class BackendServices {
  static Future<List> getSuggestions(String query) async {
    //List<ItemModel> myList = List<ItemModel>();
    if (query.length == 0) {
      return null;
    }

    final response = await http.get(
        'https://api.themoviedb.org/3/search/movie?api_key=6c326e785878860f2982c80f0be1b3d5&language=en-US&query=$query&page=1&include_adult=false');

    if (response.statusCode == 200) {
      //print(response.body);
      ItemModel mymodel = ItemModel.fromJson(json.decode(response.body), false);
      return mymodel.results;
    }
    return null;
  }
}
