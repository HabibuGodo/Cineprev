import 'package:rxdart/rxdart.dart';
import '../models/trailer_model.dart';
import '../resources/repository.dart';

class TrailerBlock{
  final repository = Repository();
  final movieFetcher = PublishSubject<TrailerModel>();
  Stream<TrailerModel> get allTrailers => movieFetcher.stream;

  fetchAllTrailers(int movieId) async {
    TrailerModel itemModel = await repository.fetchTrailers(movieId);
    movieFetcher.sink.add(itemModel);
  }

  dispose() {
    movieFetcher.close();
  }
}
final block_trailer = TrailerBlock();