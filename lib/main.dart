import 'dart:async';
import 'package:CinePrev/services/ads.dart';
import 'package:applovin/applovin.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/appintro.dart';
import './screens/splashscreen.dart';
import './utility/fadetransation.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String debugLabelString = "";

  @override
  void initState() {
    super.initState();
    generalInit();
    initOneSignal();
  }

  generalInit() async {
    DisplayAds.initializeAdMob();
    AppLovin.init();
    FacebookAudienceNetwork.init();
    await FlutterDownloader.initialize(debug: true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void initOneSignal() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        debugLabelString =
            "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print("OPENED NOTIFICATION");
      print(result.notification.jsonRepresentation().replaceAll("\\n", "\n"));
      this.setState(() {
        debugLabelString =
            "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);

    OneSignal.shared.init("bb44698b-c6ac-4bc2-8942-e73409511f76", iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: true
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CinePrev',
      theme: ThemeData(
        fontFamily: 'Raleway-SemiBold',
      ),
      home: CheckPage(),
    );
  }
}

bool firstRun;

class CheckPage extends StatefulWidget {
  @override
  _CheckPageState createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  //check if the app runs for the first time after the installation
  //and save the instance for future runs
  Future checkFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstRun = (prefs.getBool('firstRun') ?? true);
    if (!firstRun) {
      Navigator.pushReplacement(
        context,
        MyCustomRoute(
          builder: (context) => SplashScreen(),
        ),
      );
    } else {
      await prefs.setBool('firstRun', false);
      Navigator.push(
        context,
        MyCustomRoute(
          builder: (context) => AppIntro(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirst();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


// void main() async {

//   WidgetsFlutterBinding.ensureInitialized();
//   DisplayAds.initializeAdMob();
//   AppLovin.init();
//   FacebookAudienceNetwork.init();
//   await FlutterDownloader.initialize(debug: true);

//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     title: 'CinePrev',
//     theme: ThemeData(
//       fontFamily: 'Raleway-SemiBold',
//     ),
//     home: CheckPage(),
//   ));

//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
// }