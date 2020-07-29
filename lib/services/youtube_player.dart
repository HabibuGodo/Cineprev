import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/ads.dart';

class PlayVideo extends StatefulWidget {
  final String videoId;
  PlayVideo(this.videoId);
  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  YoutubePlayerController _controller;
  BannerAd _bannerAd;
  @override
  void initState() {
    
    _bannerAd = DisplayAds.createBannerAd()
      ..load()
      ..show();
    String videoURL = "https://www.youtube.com/watch?v=${widget.videoId}";
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoURL),
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 20,
            top: 50,
            child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios, color: Colors.white)),
          ),
          Container(
            child: Center(
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
                topActions: <Widget>[
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? Icon(Icons.arrow_back_ios, color: Colors.white)
                        : Container(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
