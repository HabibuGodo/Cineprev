import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../blocs/genre_bloc.dart';
import '../models/genre_model.dart';
import './page_contents.dart';

class PreloadContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PreloadContentState();
  }
}

//ConnectivityResult result;

class _PreloadContentState extends State<PreloadContent> {
  @override
  void initState() {
    super.initState();
    //_checkInternetConnectivity(result);
  }

  // _showDialog(title, text) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text(title),
  //           content: Text(text),
  //           actions: <Widget>[
  //             FlatButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text("Ok"),
  //             )
  //           ],
  //         );
  //       });
  // }

  // void _checkInternetConnectivity(result) async {
  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //     } else {
  //       _showDialog('Error!', "No internet connection.");
  //     }
  //   } on SocketException catch (_) {
  //     _showDialog('Error!', "No internet connection.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    bloc_genre.fetchAllGenre();
    return StreamBuilder(
      stream: bloc_genre.allGenre,
      builder: (context, AsyncSnapshot<GenreModel> snapshot) {
        if (snapshot.hasData) {
          //buildList(snapshot);
          return ContentPage(snapshot);
        } else if (snapshot.hasError) {
          return Center(child: Text("Something went wrong!"));
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
      },
    );
  }
}
