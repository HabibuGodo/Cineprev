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

  @override
  void initState() {
    super.initState();
    _typeAheadController.clear();
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
                    leading: 'https://image.tmdb.org/t/p/w185//${suggestion.poster_path}' !=
                            null
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w185//${suggestion.poster_path}')
                        : Image.network(
                            'https://www.google.com/imgres?imgurl=https%3A%2F%2Fcdn.domestika.org%2Fraw%2Fupload%2Fassets%2Fprojects%2Fproject-default-cover-1248c9d991d3ef88af5464656840f5534df2ae815032af0fdf39562fee08f0a6.svg&imgrefurl=https%3A%2F%2Fwww.domestika.org%2Fen%2Fschools%2F12923-alberta-university-of-the-arts&tbnid=iO_TkdnJSBLLpM&vet=12ahUKEwja-_SSxuroAhUC-4UKHQBQDX0QMygUegQIARAr..i&docid=ca4YMtCI22hjfM&w=211&h=211&itg=1&q=no%20cover&ved=2ahUKEwja-_SSxuroAhUC-4UKHQBQDX0QMygUegQIARAr'),
                    title: Text(suggestion.title),
                    subtitle:
                        Text('Released date : ${suggestion.release_date}'),
                  );
                },
                onSuggestionSelected: (suggestion) {
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
