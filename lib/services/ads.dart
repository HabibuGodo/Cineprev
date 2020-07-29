import 'package:firebase_admob/firebase_admob.dart';

class DisplayAds {
  static const String testDevice = "Test";

  static void initializeAdMob() {
    FirebaseAdMob.instance
        //"ca-app-pub-5430937479371157~9093356110"
        .initialize(appId: "ca-app-pub-5430937479371157~9093356110");
  }

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice == null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>[
      'Trailers',
      'Movies Trailers',
      'Recent Movies',
      'Movies',
      'popular movies',
      'cinema',
      'now playing movies',
      'top movies',
      'covid-19',
      'corona',
      'football',
      'new movie',
      'airtel',
      'tigo',
      'vodacom'
    ],
  );

  static BannerAd createBannerAd() {
    return BannerAd(
        //"ca-app-pub-5430937479371157/5438317600"
        adUnitId: "ca-app-pub-5430937479371157/5438317600",
        targetingInfo: targetingInfo,
        size: AdSize.banner,
        listener: (MobileAdEvent event) {
          print("BannerAd $event");
        });
  }

  static InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        //"ca-app-pub-5430937479371157/8391289168"
        adUnitId: "ca-app-pub-5430937479371157/8391289168",
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("InterstitialAd $event");
        });
  }
}
