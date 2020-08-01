import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final String about =
      "We developed CinePrev for you, watch recent and popular movies' " +
          " trailers and list. CinePrev shows all movies trailers, rating, popularity and vote count," +
          "  so you won't spend your valuable time browsing around blog sites to decide if that is worth to watch!";

  final String url = 'https://www.instagram.com/cineprev';

  Future<void> _launchInApp(String url) async {
    if (await canLaunch(url)) {
      final bool onApp =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!onApp) {
        await launch(url, forceWebView: true, forceSafariVC: true);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 60, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CircleAvatar(
                      maxRadius: 60.0,
                      minRadius: 60.0,
                      backgroundImage: AssetImage("assets/logo.png"),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      'CinePrev',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 10),
              child: Text(
                about,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20, top: 200),
                  child: Text(
                    "Follow us on: ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left:10,top: 200),
                  child: InkWell(
                    onTap: () => _launchInApp(url),
                    child: Image.asset(
                      "assets/instagram.png",
                      width: 120,
                      height: 40,
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
