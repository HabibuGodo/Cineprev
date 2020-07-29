import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';

class MovieBloc {
  
  final _repository = Repository();
  final _movieFetcher = PublishSubject<ItemModel>();
  Stream<ItemModel> get allMovies => _movieFetcher.stream;

  fetchAllMovies(int page) async {
    _repository.page = page;
    ItemModel itemModel = await _repository.fetchAllMovies();
    _movieFetcher.sink.add(itemModel);
  }

  dispose() {
    _movieFetcher.close();
  }
}
final bloc = MovieBloc();
