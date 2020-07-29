import 'package:rxdart/rxdart.dart';
import '../models/genre_model.dart';
import '../resources/repository.dart';

class GenreBloc {
  final _repository = Repository();
  final _movieFetcher = PublishSubject<GenreModel>();

  Stream<GenreModel> get allGenre => _movieFetcher.stream;

  fetchAllGenre() async {
    GenreModel itemModel = await _repository.fetchAllGenres();
    _movieFetcher.sink.add(itemModel);
  }

  dispose() {
    _movieFetcher.close();
  }
}
final bloc_genre = GenreBloc();
