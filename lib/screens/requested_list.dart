import 'dart:convert';
import 'dart:ui';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import '../models/RequestedandFavorited.dart';
import '../models/genre_model.dart';
import '../resources/home_presenter.dart';
import '../services/ads.dart';
import '../utility/fadetransation.dart';
import './requested_details.dart';

class RequestedScreen extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshotGenre;
  RequestedScreen(this.snapshotGenre);
  @override
  State<StatefulWidget> createState() {
    return _RequestedScreenState();
  }
}

class _RequestedScreenState extends State<RequestedScreen>
    implements HomeContract {
  HomePresenter homePresenter;

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  @override
  void initState() {
    super.initState();
    homePresenter = HomePresenter(this);
    
    _bannerAd = DisplayAds.createBannerAd()
      ..load()
      ..show();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder<List<RequestedandFavorited>>(
              future: homePresenter.getRequested(),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                var data = snapshot.data;
                return Container(
                  margin: EdgeInsets.only(left: 10, top: 30),
                  child: snapshot.hasData
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 20, bottom: 5),
                                width: MediaQuery.of(context).size.width - 20,
                                height: 40,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.80,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Text(
                                            "Requested Movies",
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            snapshot.data.length > 0
                                ? Container(
                                    padding: EdgeInsets.only(top: 10),
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    height: MediaQuery.of(context).size.height -
                                        110,
                                    child: RequestedList(data, homePresenter),
                                  )
                                : Container(
                                    height: MediaQuery.of(context).size.height -
                                        152,
                                    child: Center(
                                      child: Text(
                                        "You didn't request any movie",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ))
                          ],
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void screenUpdate() {
    setState(() {});
  }
}

class RequestedList extends StatelessWidget {
  final List<RequestedandFavorited> requested;
  final HomePresenter homePresenter;

  RequestedList(
    List<RequestedandFavorited> this.requested,
    HomePresenter this.homePresenter, {
    Key key,
  }) : super(key: key);

  InterstitialAd _interstitialAd;
  

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: requested == null ? 0 : requested.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () async {
            _interstitialAd = DisplayAds.createInterstitialAd()
              ..load()
              ..show();
            await Future.delayed(Duration(seconds: 2));
            Navigator.push(
              context,
              MyCustomRoute(
                builder: (context) => RequestedDetails(requested[index]),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Container(
                    height: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              base64Decode(requested[index].poster_path),
                              width: 185,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Padding(
                            padding: EdgeInsets.only(left: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  requested[index].name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  requested[index].release_date,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  requested[index].genres,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.star,
                                        color: Colors.redAccent, size: 24),
                                    RichText(
                                      text: TextSpan(
                                        text: requested[index].vote_average,
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
                  ))
            ],
          ),
        );
      },
    );
  }
}
