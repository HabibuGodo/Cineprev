import 'package:CinePrev/screens/homescreen.dart';

import './about.dart';
import 'package:flutter/material.dart';
import './requested_list.dart';
import '../models/genre_model.dart';
import './favorite_list.dart';
import '../utility/fadetransation.dart';

class SideBar extends StatefulWidget {
  final AsyncSnapshot<GenreModel> snapshotGenre;
  SideBar({this.snapshotGenre});
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black12),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 75,
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      maxRadius: 30.0,
                      minRadius: 20.0,
                      backgroundImage: AssetImage("assets/logo.png"),
                    ),
                    title: Text(
                      'CinePrev',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Let's be entertained",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MyCustomRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                'Requested',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MyCustomRoute(
                    builder: (context) => RequestedScreen(widget.snapshotGenre),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                'Favorites',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MyCustomRoute(
                    builder: (context) => FavoritedScreen(widget.snapshotGenre),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                'About',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MyCustomRoute(
                    builder: (context) => About(),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20, top: 225),
                  child: Text(
                    'version 2.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
