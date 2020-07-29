import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './homescreen.dart';
import '../utility/fadetransation.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  void navigationPage() {
    Navigator.pushReplacement(
      context,
      MyCustomRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  @override
  void initState() {
    super.initState();

    startTime();
    //_showNots();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light
          .copyWith(statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(180),
            color: Colors.red,
          ),
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
