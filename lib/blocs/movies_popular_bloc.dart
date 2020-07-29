import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';

class MoviePopularBloc {
  final _repository = Repository();
  final _movieFetcher = PublishSubject<ItemModel>();
  Stream<ItemModel> get allPopularMovies => _movieFetcher.stream;

  fetchAllPopularMovies(int page) async {
    _repository.page = page;
    ItemModel itemModel = await _repository.fetchAllPopularMovies();
    _movieFetcher.sink.add(itemModel);
  }

  dispose() {
    _movieFetcher.close();
  }
}
final bloc_popular = MoviePopularBloc();
