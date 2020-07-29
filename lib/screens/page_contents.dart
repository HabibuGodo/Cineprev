import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import './all_Recents.dart';
import './all_popular.dart';
import './Recent_movies.dart';
import './popular_movies.dart';
import '../services/ads.dart';
import '../utility/fadetransation.dart';
import '../models/genre_model.dart';
import '../blocs/movies_bloc.dart';

class ContentPage extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshotGenre;
  ContentPage(this.snapshotGenre);
  @override
  State<StatefulWidget> createState() {
    return _ContentPageState();
  }
}

class _ContentPageState extends State<ContentPage> {
  int coins = 0;

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  void initState() {
    super.initState();

    //AdMob Ads
    
    _bannerAd = DisplayAds.createBannerAd()
      ..load()
      ..show();
    _interstitialAd = DisplayAds.createInterstitialAd()..load();
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          coins += rewardAmount;
        });
      }
    };
    RewardedVideoAd.instance.load(
        //"ca-app-pub-5430937479371157/4834594631"
        adUnitId: "ca-app-pub-5430937479371157/4834594631",
        targetingInfo: DisplayAds.targetingInfo);
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  //build movie category section (Recent or Popular)
  Widget _moviesCategory(String text) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 18,
      child: Stack(
        children: <Widget>[
          Positioned(
            child: InkWell(
              child: Text(
                '$text',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              onTap: () async {
                if (text == 'Recent') {
                  RewardedVideoAd.instance.show();
                  await Future.delayed(Duration(seconds: 3));
                  Navigator.push(
                    context,
                    MyCustomRoute(
                      builder: (context) => AllRecents(widget.snapshotGenre),
                    ),
                  );
                } else if (text == 'Popular') {
                  RewardedVideoAd.instance.show();
                  await Future.delayed(Duration(seconds: 3));
                  Navigator.push(
                    context,
                    MyCustomRoute(
                      builder: (context) => AllPopular(widget.snapshotGenre),
                    ),
                  );
                } else {
                  return null;
                }
              },
            ),
          ),
          Positioned(
            right: 20,
            child: InkWell(
              onTap: () async {
                if (text == 'Recent') {
                  _interstitialAd.show();
                  Navigator.push(
                    context,
                    MyCustomRoute(
                      builder: (context) => AllRecents(widget.snapshotGenre),
                    ),
                  );
                } else if (text == 'Popular') {
                  _interstitialAd.show();
                  Navigator.push(
                    context,
                    MyCustomRoute(
                      builder: (context) => AllPopular(widget.snapshotGenre),
                    ),
                  );
                } else {
                  return null;
                }
              },
              child: Text(
                'See all',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bloc.fetchAllMovies(1);
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, top: 0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                height: 0.5,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 152,
                child: SingleChildScrollView(
                  //physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      _moviesCategory('Recent'),
                      RecentMovies(widget.snapshotGenre),
                      _moviesCategory('Popular'),
                      PopularMovies(widget.snapshotGenre),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
