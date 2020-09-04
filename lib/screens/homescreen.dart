import 'package:CinePrev/services/ads.dart';
import 'package:cache_image/cache_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/genre_model.dart';
import '../services/backendServices.dart';
import './sidebar.dart';
import './movie_details.dart';
import './preload.dart';

class HomeScreen extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshotGenre;

  HomeScreen({this.snapshotGenre});
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime currentBackPressTime;
//typeAhead Controller
  TextEditingController _typeAheadController = TextEditingController();
  InterstitialAd _interstitialAd;
  @override
  void initState() {
    super.initState();
    
    _interstitialAd = DisplayAds.createInterstitialAd()..load();
    _typeAheadController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _typeAheadController.clear();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: SideBar(),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: // SizedBox(height: 3),
                  TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _typeAheadController,
                  autofocus: false,
                  style: TextStyle(color: Colors.grey, fontSize: 24),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enter movie name',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  try {
                    return await BackendServices.getSuggestions(pattern);
                  } catch (e) {
                    throw "Something went wrong.";
                  }
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder: AssetImage('assets/gif/loading.gif'),
                      image: CacheImage(
                          'https://image.tmdb.org/t/p/w185//${suggestion.poster_path}'),
                      width:40,
                    ),
                    title: Text(suggestion.title),
                    subtitle:
                        Text('Released date : ${suggestion.release_date}'),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  _interstitialAd.show();
                  _interstitialAd = DisplayAds.createInterstitialAd()..load();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MovieDetails(
                      suggestion,
                      "Searched",
                    ),
                  ));
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      // drawer: SideBar(),
      body: WillPopScope(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: PreloadContent(),
          ),
          onWillPop: onWillPop),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Tap back again to exit');
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);
  }
}
