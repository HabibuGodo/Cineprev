class TrailerModel{
  List<TResult> results = [];

  TrailerModel.fromJson(Map<String,dynamic> parseJson) {
    List<TResult> temp = [];
    for(var i = 0; i< parseJson['results'].length; i++){
      TResult result = TResult(parseJson['results'][i]);
      temp.add(result);
    }
    results = temp;
  }
  List<TResult> get getTrailers => results;
}

class TResult {
  String key;
  String name;
  TResult(result) {
    key = result['key'].toString();
    name = result['name'].toString();
  }

  String get get_key => key;
  String get get_name => name;
}