import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cache_image/cache_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:achievement_view/achievement_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../resources/home_presenter.dart';
import '../services/ads.dart';
import '../blocs/trailer_bloc.dart';
import '../models/RequestedandFavorited.dart';
import '../models/RequestedandFavorited_trailers.dart';
import '../models/trailer_model.dart';
import '../models/item_model.dart';
import './trailer_page.dart';

class MovieDetails extends StatefulWidget {
  final Result data;
  final String genres;
  MovieDetails(this.data, this.genres);
  @override
  State<StatefulWidget> createState() {
    return _MovieDetailsState();
  }
}

IconData myIcon;
String backdrop_path = 'https://image.tmdb.org/t/p/w185//';

class _MovieDetailsState extends State<MovieDetails> implements HomeContract {
  HomePresenter homePresenter;

  void initState() {
    super.initState();
    homePresenter = HomePresenter(this);
    myIcon = Icons.favorite_border;
    backdrop_path =
        'https://image.tmdb.org/t/p/w185//${widget.data.backdrop_path}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MovieDetailPage(widget.data, widget.genres, homePresenter),
    );
  }

  @override
  void screenUpdate() {}
}

class MovieDetailPage extends StatefulWidget {
  final TargetPlatform platform;
  final Result data;
  final String genres;
  final HomePresenter homePresenter;
  MovieDetailPage(this.data, this.genres, this.homePresenter, {this.platform});

  @override
  State<StatefulWidget> createState() {
    return _MovieDetailPage();
  }
}

class _MovieDetailPage extends State<MovieDetailPage> {
  bool isLoad = false;
  TrailerModel trailerData;
  int coins = 0;

  /////**********variables for movies downloading *********/
  int downloadProgress = 0;
  DownloadTaskStatus downloadStatus;
  String movieUrl = '';
  String request = '';
  bool requestSent = false;
  bool isItFavorited = false;
  String downloadId;
  ReceivePort _port = ReceivePort();

  BannerAd _bannerAd;
  SharedPreferences prefs;
  void initState() {
    super.initState();
    coin(); //for coins
    checkForDownload(); // check if movies is on firebase to download
    _init(); //for downloading

///////////////////////ADS////////////////////////////////
    _bannerAd = DisplayAds.createBannerAd()
      ..load()
      ..show();

    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          coins += rewardAmount + 1;
          prefs.setInt("coins", coins);
        });
      }
    };
    RewardedVideoAd.instance.load(
        //"ca-app-pub-5430937479371157/4834594631" old
        //ca-app-pub-7400114702189070/3889396168  new
        adUnitId: "ca-app-pub-7400114702189070/3889396168",
        targetingInfo: DisplayAds.targetingInfo);
    /////////////////////////////////
  }

  coin() async {
    prefs = await SharedPreferences.getInstance();
    coins = (prefs.getInt('coins') ?? 1);
    setState(() {
      coins;
    });
  }

//Check if movies is in firebase
  Future checkForDownload() async {
    StorageReference reference =
        FirebaseStorage.instance.ref().child("movies/${widget.data.id}.mp4");
    String downloadURL = await reference.getDownloadURL();
    setState(() {
      movieUrl = downloadURL;
      isLoad = true;
    });
  }

  _init() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      print('UI Isolate Callback: $data');
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      setState(() {
        downloadId = id;
        downloadProgress = progress;
        downloadStatus = status;
      });
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print('task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<PermissionStatus> _checkPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permisionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      return permisionStatus[PermissionGroup.storage] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  Future _requestDownload() async {
    PermissionStatus permissionStatus = await _checkPermission();
    if (permissionStatus == PermissionStatus.granted) {
      String dir = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);

      final taskId = await FlutterDownloader.enqueue(
        url: movieUrl,
        fileName: "${widget.data.title}.mp4",
        savedDir: dir,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      downloadId = taskId;
    }
  }

  _showDialog(title, text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () {
                  RewardedVideoAd.instance.show();
                  Navigator.of(context).pop();
                },
                child: Text("Watch"),
              )
            ],
          );
        });
  }

  void _stopDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
  }

  Future<bool> _openDownloadedFile(String taskId) {
    return FlutterDownloader.open(taskId: taskId);
  }

  void _retryDownload(String taskId) async {
    String newTaskId = await FlutterDownloader.retry(taskId: taskId);
    taskId = newTaskId;
  }

  Widget _buildActionForTask(String taskId) {
    if (downloadId == null || downloadStatus == DownloadTaskStatus.undefined) {
      return new FloatingActionButton.extended(
        onPressed: () {
          if (coins == 0) {
            _showDialog('Download Error!',
                "You have 0 coins please watch this video to earn coins to download movies.");
          } else {
            _requestDownload();
            checkDownloaded('start');
            setState(() {
              coins -= 1;
              prefs.setInt("coins", coins);
            });
          }
        },
        label: Column(
          children: <Widget>[
            Icon(Icons.file_download),
            Text(
              'Download',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: Colors.black,
      );
    } else if (downloadStatus == DownloadTaskStatus.running) {
      return new FloatingActionButton.extended(
        onPressed: () {
          _stopDownload(taskId);
          checkDownloaded('stop');
        },
        label: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(
                    value: downloadProgress / 100,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(Colors.lightBlueAccent, Colors.blue,
                          downloadProgress / 100),
                    ),
                  ),
                  height: 24.0,
                  width: 24.0,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.stop,
                    color: Colors.red,
                    size: 15,
                  ),
                ),
              ],
            ),
            Text(
              'Stop',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: Colors.black,
      );
    } else if (downloadStatus == DownloadTaskStatus.complete) {
      checkDownloaded('comp');
      return new FloatingActionButton.extended(
        onPressed: () {
          _openDownloadedFile(taskId);
        },
        label: Column(
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            Text(
              'Completed',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: Colors.black,
      );
    } else if (downloadStatus == DownloadTaskStatus.failed) {
      return new FloatingActionButton.extended(
        onPressed: () async {
          _retryDownload(taskId);
          checkDownloaded('retry');
        },
        label: Column(
          children: <Widget>[
            Icon(
              Icons.refresh,
              color: Colors.redAccent,
            ),
            Text(
              'Retry',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: Colors.black,
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () async {
          if (coins == 0) {
            _showDialog('Download Error!',
                "You have 0 coins please watch this video to earn coins to download movies.");
          } else {
            _requestDownload();
            checkDownloaded('start');
            setState(() {
              coins -= 1;
              prefs.setInt("coins", coins);
            });
          }
        },
        label: Column(
          children: <Widget>[
            Icon(Icons.file_download),
            Text(
              'Download',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: Colors.black,
      );
    }
  }

//converting assets data into file
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

//requesting movies
  Future requestMovie() async {
    File _imageFile = await getImageFileFromAssets(
        'nocover.jpg'); //used on requesting movie as file
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("requests/${widget.data.id} : ${widget.data.title}");
    StorageUploadTask uploadTask = ref.putFile(_imageFile);
    //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      AchievementView(context,
          title: 'Thank you',
          subTitle: 'Your request Received.',
          icon: Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          color: Colors.green,
          duration: Duration(seconds: 2),
          isCircle: true, listener: (status) {
        print("${status}");
      })
        ..show();
    });
    setState(() {
      requestSent = true;
    });
  }

//check which movies are download
  Future checkDownloaded(String status) async {
    String folder;
    File _imageFile = await getImageFileFromAssets(
        'nocover.jpg'); //used on requesting movie as file
    if (status == 'start') {
      folder = 'Started';
    } else if (status == 'stop') {
      folder = 'Stoped';
    } else if (status == 'retry') {
      folder = 'Retryed';
    } else if (status == 'comp') {
      folder = 'Completed';
    } else {}
    StorageReference ref = FirebaseStorage.instance.ref().child(
        "${folder}/${DateTime.now()}-->${widget.data.id} : ${widget.data.title}");
    StorageUploadTask uploadTask = ref.putFile(_imageFile);
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  doSomething(TrailerModel model) {
    setState(() {
      trailerData = model;
      isLoad = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: InkWell(
                    onTap: () {
                      _showDialog(
                          'EARN COINS', "Watch this video to earn coins.");
                    },
                    child: CircleAvatar(
                      maxRadius: 13.0,
                      minRadius: 13.0,
                      backgroundImage: AssetImage("assets/icons/coin.jpg"),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  child: Text(
                    coins.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 150,
                ),
                FutureBuilder<bool>(
                  future: widget.homePresenter.isItFavorited(widget.data.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);
                    var data = snapshot.data;
                    if (isItFavorited != true) isItFavorited = data;
                    return isItFavorited == false
                        //Favorite Icon
                        ? Container(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  insertFavorited(context, widget.homePresenter,
                                      widget.data, widget.genres, trailerData);
                                  isItFavorited = true;
                                  AchievementView(context,
                                      title: 'Information',
                                      subTitle: 'The Movie added to favorite',
                                      icon: Icon(
                                        Icons.movie,
                                        color: Colors.white,
                                      ),
                                      color: Colors.greenAccent,
                                      duration: Duration(seconds: 1),
                                      isCircle: true, listener: (status) {
                                    print(status);
                                  })
                                    ..show();
                                });
                              },
                              child: Icon(Icons.favorite_border,
                                  color: Colors.white),
                            ),
                          )
                        : Container(
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    // deleteNotification(widget.data.id);
                                    widget.homePresenter
                                        .deleteFavorited(widget.data.id);
                                    isItFavorited = false;
                                    AchievementView(context,
                                        title: 'Information',
                                        subTitle:
                                            'The movie removed to favorite',
                                        icon: Icon(
                                          Icons.movie,
                                          color: Colors.white,
                                        ),
                                        color: Colors.red[700],
                                        duration: Duration(seconds: 1),
                                        isCircle: true, listener: (status) {
                                      print(status);
                                    })
                                      ..show();
                                  });
                                },
                                child:
                                    Icon(Icons.favorite, color: Colors.white)),
                          );
                  },
                )
              ],
            ),
            backgroundColor: Colors.black,
            expandedHeight: 300,
            pinned: true,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                width: 228,
                margin: EdgeInsets.only(right: 15),
                child: Text(
                  widget.data.title,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              background: Stack(
                children: <Widget>[
                  Hero(
                    tag: widget.data.id,
                    child: Container(
                      height: 360,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          alignment: FractionalOffset.topCenter,
                          image: CacheImage(
                              'https://image.tmdb.org/t/p/w185//${widget.data.poster_path.replaceAll('w185', 'w400')}' ==
                                      null
                                  ? Image.asset('assets/nocover.jpg')
                                  : 'https://image.tmdb.org/t/p/w185//${widget.data.poster_path.replaceAll('w185', 'w400')}'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding: EdgeInsets.only(left: 20, top: 5, bottom: 8),
                  width: MediaQuery.of(context).size.width,
                  // height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.95),
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.95),
                        Colors.black
                      ],
                    ),
                  ),
                  child: GenresItems(widget.genres),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        width: MediaQuery.of(context).size.width,
                        height: 0.5,
                        color: Colors.grey,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 5, top: 5),
                        width: MediaQuery.of(context).size.width,
                        //height: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  width:
                                      (MediaQuery.of(context).size.width - 60) /
                                          4,
                                  height: 50,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          widget.data.popularity.toString(),
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "Popularity",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 60) /
                                          4,
                                  height: 50,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.star,
                                            color: Colors.redAccent, size: 24),
                                        RichText(
                                          text: TextSpan(
                                            text: widget.data.vote_average,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: ' / 10',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 60) /
                                          4,
                                  height: 50,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          widget.data.vote_count.toString(),
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "Vote",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                movieUrl != ''
                                    ? //it is in firebase so here to download
                                    Container(
                                        margin: EdgeInsets.only(left: 20),
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    60) /
                                                4,
                                        height: 50,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              //to download
                                              _buildActionForTask(downloadId)
                                            ],
                                          ),
                                        ),
                                      )
                                    : //not in firebase so here to request

                                    Container(
                                        margin: EdgeInsets.only(left: 20),
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    60) /
                                                4,
                                        height: 50,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              FloatingActionButton.extended(
                                                  backgroundColor: Colors.black,
                                                  onPressed: () async {
                                                    if (coins == 0) {
                                                      _showDialog(
                                                          'Request Error!',
                                                          "You have 0 coins please watch this video to earn coins to request movies.");
                                                    } else {
                                                      //saved on requested list
                                                      insertRequested(
                                                          context,
                                                          widget.homePresenter,
                                                          widget.data,
                                                          widget.genres,
                                                          trailerData);

                                                      //requesting
                                                      requestMovie();
                                                      setState(() {
                                                        coins -= 1;
                                                        prefs.setInt(
                                                            "coins", coins);
                                                      });
                                                    }
                                                  },
                                                  label: Column(
                                                    children: <Widget>[
                                                      FutureBuilder(
                                                          future: widget
                                                              .homePresenter
                                                              .requestSent(
                                                                  widget
                                                                      .data.id),
                                                          builder: (context,
                                                              snapshot) {
                                                            var data =
                                                                snapshot.data;
                                                            if (requestSent !=
                                                                true)
                                                              requestSent =
                                                                  data;
                                                            return requestSent ==
                                                                    false
                                                                ? Icon(Icons
                                                                    .add_circle)
                                                                : Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: Colors
                                                                        .green);
                                                          }),
                                                      FutureBuilder(
                                                          future: widget
                                                              .homePresenter
                                                              .requestSent(
                                                                  widget
                                                                      .data.id),
                                                          builder: (context,
                                                              snapshot) {
                                                            var data =
                                                                snapshot.data;
                                                            if (requestSent !=
                                                                true)
                                                              requestSent =
                                                                  data;
                                                            return requestSent ==
                                                                    false
                                                                ? Text(
                                                                    "Request",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                : Text(
                                                                    "Requested",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  );
                                                          }),
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      )
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              width: MediaQuery.of(context).size.width,
                              height: 0.5,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              width: MediaQuery.of(context).size.width - 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    widget.data.overview,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              width: MediaQuery.of(context).size.width - 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    'Trailers',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(bottom: 20, left: 20),
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    child: PreloadTrailer(
                                        widget.data.id, doSomething),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 13),
                                    height: 20,
                                    child: Text(
                                      'Provide space for banner ad',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GenresItems extends StatefulWidget {
  final String genres;
  GenresItems(this.genres);
  @override
  State<StatefulWidget> createState() {
    return _GenreItemsState();
  }
}

class _GenreItemsState extends State<GenresItems> {
  Widget GenreItem(String genre) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
        child: Text(
          genre,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<List<Widget>> _getGenres(String genre) async {
    var values = List<Widget>();
    var items = genre.split(',');
    for (int i = 0; i < items.length - 1; i++) {
      values.add(GenreItem(items[i]));
    }
    await Future.delayed(Duration(seconds: 0));
    return values;
  }

  Widget _buildGenres(AsyncSnapshot snapshot) {
    List<Widget> values = snapshot.data;
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      child: Wrap(
        direction: Axis.horizontal,
        runSpacing: 8,
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: values,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getGenres(widget.genres),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container();
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return _buildGenres(snapshot);
            }
        }
      },
    );
  }
}

class PreloadTrailer extends StatefulWidget {
  final int movieId;

  final MyCallback callback;
  PreloadTrailer(this.movieId, this.callback);
  @override
  State<StatefulWidget> createState() {
    return _PreloadTrailerState();
  }
}

class _PreloadTrailerState extends State<PreloadTrailer> {
  @override
  Widget build(BuildContext context) {
    block_trailer.fetchAllTrailers(widget.movieId);
    return StreamBuilder(
      stream: block_trailer.allTrailers,
      builder: (context, AsyncSnapshot<TrailerModel> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.results.length > 0) {
            int itemCount = (snapshot.data.results.length / 2).round();
            double _heigth = itemCount * 172.0;
            return Container(
              width: MediaQuery.of(context).size.width - 40,
              height: _heigth,
              child: TrailerPage(snapshot, widget.callback),
            );
          } else {
            return Text(
              'Trailer is not available for now',
              style: TextStyle(color: Colors.white),
            );
          }
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString(),
              style: TextStyle(color: Colors.white));
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitCircle(color: Colors.red, size: 50),
            ],
          ),
        );
      },
    );
  }
}

//requested
Future insertRequested(BuildContext context, HomePresenter homePresenter,
    Result data, String genres, TrailerModel trailerData) async {
  Client client = Client();
  Uint8List _image = await client
      .readBytes('https://image.tmdb.org/t/p/w185//${data.poster_path}');
  Uint8List _image_back = await client
      .readBytes('https://image.tmdb.org/t/p/w185//${data.backdrop_path}');
  String posterd = base64Encode(_image);
  String backd = base64Encode(_image_back);
  RequestedandFavorited requested = RequestedandFavorited(
    data.title,
    data.id,
    posterd,
    backd,
    data.release_date,
    data.vote_count,
    data.vote_average,
    genres,
    data.overview,
    data.popularity.toString(),
  );
  await homePresenter.db.insertMovieRequested(requested);
  RequestedandFavoritedTrailer mytrailer =
      RequestedandFavoritedTrailer.fromJson(trailerData);
  for (var i = 0; i < mytrailer.results.length; i++) {
    mytrailer.results[i].movie_id = data.id;
    await homePresenter.db.insertMovieRequestedTrailer(mytrailer.results[i]);
  }
  homePresenter.updateScreen();
}

//favorited
Future insertFavorited(BuildContext context, HomePresenter homePresenter,
    Result data, String genres, TrailerModel trailerData) async {
  Client client = Client();
  Uint8List _image = await client
      .readBytes('https://image.tmdb.org/t/p/w185//${data.poster_path}');
  Uint8List _image_back = await client
      .readBytes('https://image.tmdb.org/t/p/w185//${data.backdrop_path}');
  String posterd = base64Encode(_image);
  String backd = base64Encode(_image_back);
  RequestedandFavorited favorited = RequestedandFavorited(
    data.title,
    data.id,
    posterd,
    backd,
    data.release_date,
    data.vote_count,
    data.vote_average,
    genres,
    data.overview,
    data.popularity.toString(),
  );
  await homePresenter.db.insertMovieFavorited(favorited);
  RequestedandFavoritedTrailer mytrailer =
      RequestedandFavoritedTrailer.fromJson(trailerData);
  for (var i = 0; i < mytrailer.results.length; i++) {
    mytrailer.results[i].movie_id = data.id;
    await homePresenter.db.insertMovieFavoritedTrailer(mytrailer.results[i]);
  }
  homePresenter.updateScreen();
}

//favorited
// Future insertRequestStatus(
//   bool itStatus,
//   HomePresenter homePresenter,
//   Result data,
// ) async {
//   RequestStatus status = RequestStatus(
//     data.id,
//     itStatus,
//   );
//   await homePresenter.db.insertMovieRequestStatus(status);

//   homePresenter.updateScreen();
// }

typedef void MyCallback(TrailerModel model);
