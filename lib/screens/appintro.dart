import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

import './homescreen.dart';
import '../utility/fadetransation.dart';

class AppIntro extends StatefulWidget {
  @override
  _AppIntroState createState() => _AppIntroState();
}

class _AppIntroState extends State<AppIntro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroContent(),
    );
  }
}

class IntroContent extends StatefulWidget {
  @override
  _IntroContentState createState() => _IntroContentState();
}

int currentIndexPage = 0;
double currentPos = 0.0;
const titles = ['All Movies', 'Favorites', 'Search'];
const description = [
  'Get to know all the recent and popular movies,',
  'See your favorite movies trailers any time anywhere',
  'Find any movie trailers by typing its name.'
];
const baseImgUrl = 'assets/icons';
const _images = [
  '$baseImgUrl/movies.png',
  '$baseImgUrl/data.png',
  '$baseImgUrl/search.png'
];

class _IntroContentState extends State<IntroContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CarouselSlider(
          onPageChanged: (index) {
            setState(() {
              currentIndexPage = index;
              currentPos = currentIndexPage.toDouble();
            });
          },
          initialPage: 0,
          reverse: false,
          viewportFraction: 1.0,
          height: MediaQuery.of(context).size.height,
          items: [0, 1, 2].map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 250,
                          width: 250,
                          child: Center(
                            child: Image.asset(
                              _images[i],
                              width: 120,
                              color: Colors.white,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(150),
                              color: Colors.black),
                        ),
                        SizedBox(height: 30),
                        Text(
                          titles[i],
                          style: TextStyle(color: Colors.black54, fontSize: 30),
                        ),
                        SizedBox(height: 15),
                        Text(
                          description[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                        SizedBox(height: 30),
                        currentIndexPage == 2
                            ? InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MyCustomRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 100),
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.redAccent),
                                  child: Center(
                                    child: Text(
                                      'GET STARTED!',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 20,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: DotsIndicator(
                dotsCount: 3,
                position: currentPos,
                decorator: DotsDecorator(
                  color: Colors.black38,
                  activeColor: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 25,
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 20,
                  top: 1,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MyCustomRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'SKIP',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
