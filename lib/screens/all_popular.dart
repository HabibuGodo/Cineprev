import 'package:cache_image/cache_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/ads.dart';
import '../blocs/movies_popular_bloc.dart';
import '../models/genre_model.dart';
import '../models/item_model.dart';
import './movie_details.dart';

int page = 1;

class AllPopular extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshotGenre;
  AllPopular(this.snapshotGenre);
  @override
  _AllPopularState createState() => _AllPopularState();
}

class _AllPopularState extends State<AllPopular> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AllPopularScreen(widget.snapshotGenre),
    );
  }
}

class AllPopularScreen extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshotGenre;
  AllPopularScreen(this.snapshotGenre);
  @override
  _AllPopularScreenState createState() => _AllPopularScreenState();
}

class _AllPopularScreenState extends State<AllPopularScreen> {
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
   
    _bannerAd = DisplayAds.showBannerAd();
      
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20, top: 20),
            width: MediaQuery.of(context).size.width - 20,
            height: 60,
            child: Stack(
              children: <Widget>[
                Positioned(
                    top: 14,
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'All Populars',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 0,
            height: MediaQuery.of(context).size.height - 100,
            child: LoadList(widget.snapshotGenre),
          )
        ],
      ),
    );
  }
}

class InfiniteListExample extends StatefulWidget {
  final AsyncSnapshot<ItemModel> snapshot;
  final AsyncSnapshot<GenreModel> snapshtGenre;
  InfiniteListExample(this.snapshot, this.snapshtGenre);
  @override
  _InfiniteListExampleState createState() => _InfiniteListExampleState();
}

class _InfiniteListExampleState extends State<InfiniteListExample> {
  List _data = [];
  ScrollController _controller;
  bool isLoad = false, isLoading = false;
  InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
    _interstitialAd = DisplayAds.createInterstitialAd()..load();
    page = 1;
    _data = widget.snapshot.data.results;
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !_controller.position.outOfRange) {
        page++;
        if (page < 501) bloc_popular.fetchAllPopularMovies(page);
        print("${_data.length} data now");
        setState(() {
          isLoad = true;
          isLoading = true;
        });
      }
    });
    _data = widget.snapshot.data.results;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc_popular.allPopularMovies,
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.active) {
            List item = _data
                .where((item) => item.id
                    .toString()
                    .contains(snapshot.data.results[0].id.toString()))
                .toList();
            if (isLoad && item.length == 0) {
              for (var i = 0; i < 20; i++) {
                _data.add(snapshot.data.results[i]);
              }

              isLoad = false;
              Future.delayed(Duration(milliseconds: 1000), () {
                setState(() {
                  isLoading = false;
                });
              });
            }
            return Stack(
              children: <Widget>[
                ListView.builder(
                  padding: EdgeInsets.only(left: 20, top: 0),
                  controller: _controller,
                  itemBuilder: (context, int index) {
                    String genres = widget.snapshtGenre.data
                        .getGenre(_data[index].genre_ids);
                    return InkWell(
                      onTap: () {
                        _interstitialAd.show();
                        _interstitialAd = DisplayAds.createInterstitialAd()
                          ..load();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetails(_data[index], genres)),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: FadeInImage(
                                    fit: BoxFit.cover,
                                    placeholder:
                                        AssetImage('assets/gif/loading.gif'),
                                    image: CacheImage(
                                      'https://image.tmdb.org/t/p/w185//${_data[index].poster_path}',
                                    ),
                                    width: 180,
                                  ),
                                  // Image.network(
                                  //   'https://image.tmdb.org/t/p/w185//${_data[index].poster_path}' ==
                                  //           null
                                  //       ? 'https://lightning.od-cdn.com/static/img/no-cover_en_US.a8920a302274ea37cfaecb7cf318890e.jpg'
                                  //       : 'https://image.tmdb.org/t/p/w185//${_data[index].poster_path}',
                                  //   width: 185,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width -
                                    20 -
                                    185,
                                height: 300,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 30, left: 10, right: 10, bottom: 30),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(
                                        _data[index].title,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        _data[index].release_date,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        genres,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.star,
                                              color: Colors.redAccent,
                                              size: 28),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: _data[index].vote_average,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: ' / 10',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                            // text: TextSpan(
                                            //   text: ' / 10',
                                            //   style: TextStyle(
                                            //       color: Colors.white,
                                            //       fontSize: 14),
                                            // ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: _data.length,
                ),
                (!isLoad && isLoading)
                    ? Center(
                        child: Material(
                          elevation: 16.0,
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 120,
                            height: 120,
                            child: Center(
                              child: Container(
                                width: 260,
                                height: 70,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    SpinKitCircle(
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Movies Loading...",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            );
          }
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitCircle(color: Colors.red, size: 50),
            ],
          ),
        );
      },
    );
  }
}

class LoadList extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshtGenre;
  LoadList(this.snapshtGenre);
  @override
  _LoadListState createState() => _LoadListState();
}

class _LoadListState extends State<LoadList> {
  @override
  Widget build(BuildContext context) {
    bloc_popular.fetchAllPopularMovies(page);
    return StreamBuilder(
      stream: bloc_popular.allPopularMovies,
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: MediaQuery.of(context).size.width - 20,
            child: InfiniteListExample(snapshot, widget.snapshtGenre),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitCircle(color: Colors.red, size: 50),
            ],
          ),
        );
      },
    );
  }
}
