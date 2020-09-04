import 'dart:ui';
import 'package:CinePrev/services/ads.dart';
import 'package:cache_image/cache_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../blocs/movies_popular_bloc.dart';
import '../models/item_model.dart';
import '../models/genre_model.dart';
import './movie_details.dart';

class PopularMovies extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshotGenre;
  PopularMovies(this.snapshotGenre);
  @override
  State<StatefulWidget> createState() {
    return _PopularMoviesState();
  }
}

class _PopularMoviesState extends State<PopularMovies> {
  @override
  Widget build(BuildContext context) {
    bloc_popular.fetchAllPopularMovies(1);
    return StreamBuilder(
      stream: bloc_popular.allPopularMovies,
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            //buildList(snapshot);
            return Container(
              margin: EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width - 20,
              //height: 300,
              child: ItemPopularLoad(snapshot, widget.snapshotGenre),
            );
          } else if (snapshot.hasError) {
            return Text(
              snapshot.error.toString(),
            );
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

class ItemPopularLoad extends StatefulWidget {
  final AsyncSnapshot<ItemModel> snapshot;
  final AsyncSnapshot<GenreModel> snapshotGenre;
  ItemPopularLoad(this.snapshot, this.snapshotGenre);

  @override
  State<StatefulWidget> createState() {
    return _ItemPopularLoadState();
  }
}

class _ItemPopularLoadState extends State<ItemPopularLoad> {
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 6, //widget.snapshot.data.results.length
      padding: EdgeInsets.only(top: 16),
      itemBuilder: (context, int index) {
        String genres = widget.snapshotGenre.data
            .getGenre(widget.snapshot.data.results[index].genre_ids);

        return InkWell(
          onTap: () {
            _interstitialAd.show();
            _interstitialAd = DisplayAds.createInterstitialAd()..load();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MovieDetails(
                        widget.snapshot.data.results[index], genres)));
          },
          child: Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Container(
              height: 195,
              child: Row(
                children: <Widget>[
                  Hero(
                    tag: widget.snapshot.data.results[index].id,
                    child: Container(
                      width: 140,
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FadeInImage(
                          //fit: BoxFit.cover,
                          placeholder: AssetImage('assets/gif/loading.gif'),
                          image: CacheImage(
                            'https://image.tmdb.org/t/p/w185//${widget.snapshot.data.results[index].poster_path}',
                          ),
                          height: 192.0,
                        ),
                        // Image.network(
                        //   'https://image.tmdb.org/t/p/w185//${widget.snapshot.data.results[index].poster_path}',
                        // ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 20 - 150,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            widget.snapshot.data.results[index].title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.snapshot.data.results[index].release_date,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            genres,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: <Widget>[
                              Icon(Icons.star,
                                  color: Colors.redAccent, size: 24),
                              RichText(
                                text: TextSpan(
                                  text: widget.snapshot.data.results[index]
                                      .vote_average,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: ' / 10',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12)),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
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
}
