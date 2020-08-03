import 'package:CinePrev/services/ads.dart';
import 'package:cache_image/cache_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../blocs/movies_bloc.dart';
import '../models/item_model.dart';
import '../models/genre_model.dart';
import './movie_details.dart';

class RecentMovies extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshotGenre;
  RecentMovies(this.snapshotGenre);

  @override
  State<StatefulWidget> createState() {
    return _RecentMoviesState();
  }
}

class _RecentMoviesState extends State<RecentMovies> {
  InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
    _interstitialAd = DisplayAds.createInterstitialAd()..load();
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  //method which build the displayed movies declared
  Widget buildList(AsyncSnapshot<ItemModel> snapshot) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 6, //snapshot.data.results.length,
      itemBuilder: (BuildContext context, int index) {
        String genres = widget.snapshotGenre.data
            .getGenre(snapshot.data.results[index].genre_ids);
        return InkWell(
          onTap: () {
            _interstitialAd.show();
            _interstitialAd = DisplayAds.createInterstitialAd()..load();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MovieDetails(snapshot.data.results[index], genres)));
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: 278,
                minWidth: MediaQuery.of(context).size.width * 0.40,
                maxHeight: 278,
                maxWidth: MediaQuery.of(context).size.width * 0.40),
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Hero(
                    tag: snapshot.data.results[index],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        placeholder: AssetImage('assets/gif/loading.gif'),
                        image: CacheImage(
                          'https://image.tmdb.org/t/p/w185//${snapshot.data.results[index].poster_path}',
                        ),
                        // height: 192.0,
                      ),
                      //   Image.network(
                      //     snapshot.data.results[index].poster_path == null
                      //         ? "https://www.danishdemodungeon.dk/atobic_files/no-cover-copy.png"
                      //         : 'https://image.tmdb.org/t/p/w185//${snapshot.data.results[index].poster_path}',
                      //   ),
                    ),
                  ),
                  Text(
                    snapshot.data.results[index].title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // bloc.fetchAllMovies();
    return StreamBuilder(
      stream: bloc.allMovies,
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            //buildList(snapshot);
            return Container(
              width: MediaQuery.of(context).size.width - 40,
              height: 270,
              child: buildList(snapshot),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.hasError.toString());
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SpinKitCircle(color: Colors.red, size: 50),
                ],
              ),
            );
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitCircle(color: Colors.red, size: 50),
              ],
            ),
          );
        } else {
          return Container(
            child: Center(
              child: Text('Something went wrong!'),
            ),
          );
        }
      },
    );
  }
}
