// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:achievement_view/achievement_view.dart';
// import 'package:firebase_admob/firebase_admob.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import '../blocs/trailer_bloc.dart';
// import '../models/favorites.dart';
// import '../models/favoritetrailers.dart';
// import '../models/genre_model.dart';
// import '../models/trailer_model.dart';
// import '../resources/home_presenter.dart';
// import '../services/ads.dart';
// import './trailer_page.dart';

// class SearchDetail extends StatefulWidget {
//   final dynamic product;
//   final GenreModel genreModel;
//   SearchDetail({this.product, this.genreModel});
//   @override
//   _SearchDetailState createState() => _SearchDetailState();
// }

// String backdrop_path = '';
// String genres = '';

// class _SearchDetailState extends State<SearchDetail> implements HomeContract {
//   HomePresenter homePresenter;

//   @override
//   void initState() {
//     super.initState();
//     homePresenter = HomePresenter(this);
//     backdrop_path = widget.product.backdrop_path;
//     genres = widget.genreModel.getGenre(widget.product.genre_ids);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SearchContent(widget.product, genres, homePresenter),
//     );
//   }

//   @override
//   void screenUpdate() {}
// }

// class SearchContent extends StatefulWidget {
//   final dynamic data;
//   final String genres;
//   final HomePresenter homePresenter;
//   SearchContent(this.data, this.genres, this.homePresenter);
//   @override
//   _SearchContentState createState() => _SearchContentState();
// }

// const Base64Codec base64 = Base64Codec();

// class _SearchContentState extends State<SearchContent> {
//   bool isItRecord = false;
//   bool isLoad = false;
//   TrailerModel trailerModel;

//   BannerAd _bannerAd;
//   @override
//   void initState() {
//     super.initState();
//     DisplayAds.initializeAdMob();
//     _bannerAd = DisplayAds.createBannerAd()
//       ..load()
//       ..show();
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   void setState(fn) {
//     super.setState(fn);
//   }

//   doSomething(TrailerModel model) {
//     setState(() {
//       trailerModel = model;
//       isLoad = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     //double _width = MediaQuery.of(context).size.width;

//     return Container(
//       color: Colors.black,
//       child: CustomScrollView(
//         slivers: <Widget>[
//           SliverAppBar(
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: <Widget>[
//                 isLoad
//                     ? FutureBuilder<bool>(
//                         future: widget.homePresenter.isItRecord(widget.data.id),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasError) print(snapshot.error);
//                           var data = snapshot.data;
//                           if (isItRecord != true) isItRecord = data;

//                           return isItRecord == false
//                               //Favorite Icon
//                               ? Container(
//                                   //right: 20,
//                                   //top: 65,
//                                   child: InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         insertFavorite(
//                                             context,
//                                             widget.homePresenter,
//                                             widget.data,
//                                             widget.genres,
//                                             trailerModel);
//                                         isItRecord = true;
//                                         AchievementView(context,
//                                             title: 'Information',
//                                             subTitle:
//                                                 'The Movie added to favorite',
//                                             icon: Icon(
//                                               Icons.movie,
//                                               color: Colors.white,
//                                             ),
//                                             color: Colors.greenAccent,
//                                             duration: Duration(seconds: 1),
//                                             isCircle: true, listener: (status) {
//                                           print(status);
//                                         })
//                                           ..show();
//                                       });
//                                     },
//                                     child: Icon(Icons.favorite_border,
//                                         color: Colors.white),
//                                   ),
//                                 )
//                               : Container(
//                                   child: InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           // deleteNotification(widget.data.id);
//                                           widget.homePresenter
//                                               .delete(widget.data.id);
//                                           isItRecord = false;
//                                           AchievementView(context,
//                                               title: 'Information',
//                                               subTitle:
//                                                   'The movie removed to favorite',
//                                               icon: Icon(
//                                                 Icons.movie,
//                                                 color: Colors.white,
//                                               ),
//                                               color: Colors.red[700],
//                                               duration: Duration(seconds: 1),
//                                               isCircle: true,
//                                               listener: (status) {
//                                             print(status);
//                                           })
//                                             ..show();
//                                         });
//                                       },
//                                       child: Icon(Icons.favorite,
//                                           color: Colors.white)),
//                                 );
//                         },
//                       )
//                     : Container(),
//               ],
//             ),
//             backgroundColor: Colors.black,
//             expandedHeight: 300,
//             pinned: true,
//             centerTitle: true,
//             flexibleSpace: FlexibleSpaceBar(
//               title: Container(
//                 width: 228,
//                 margin: EdgeInsets.only(right: 15),
//                 child: Text(
//                   widget.data.title,
//                   style: TextStyle(color: Colors.white, fontSize: 20),
//                   textAlign: TextAlign.start,
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 2,
//                 ),
//               ),
//               background: Stack(
//                 children: <Widget>[
//                   Hero(
//                     tag: widget.data.id,
//                     child: Container(
//                       height: 360,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           fit: BoxFit.fitWidth,
//                           alignment: FractionalOffset.topCenter,
//                           image: NetworkImage(
//                             'https://image.tmdb.org/t/p/w185//${widget.data.poster_path.replaceAll('w185', 'w400')}',
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 Container(
//                   padding: EdgeInsets.only(left: 20, top: 5, bottom: 8),
//                   width: MediaQuery.of(context).size.width,
//                   // height: 80,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.black.withOpacity(0.95),
//                         Colors.black.withOpacity(0.9),
//                         Colors.black.withOpacity(0.7),
//                         Colors.black.withOpacity(0.8),
//                         Colors.black.withOpacity(0.9),
//                         Colors.black.withOpacity(0.95),
//                         Colors.black
//                       ],
//                     ),
//                   ),
//                   child: GenresItems(widget.genres),
//                 ),
//                 Container(
//                   child: Column(
//                     children: <Widget>[
//                       Container(
//                         margin: EdgeInsets.only(left: 20, right: 20),
//                         width: MediaQuery.of(context).size.width,
//                         height: 0.5,
//                         color: Colors.grey,
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(bottom: 5, top: 5),
//                         width: MediaQuery.of(context).size.width,
//                         //height: 70,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.max,
//                           children: <Widget>[
//                             Row(
//                               children: <Widget>[
//                                 Container(
//                                   margin: EdgeInsets.only(left: 20),
//                                   width:
//                                       (MediaQuery.of(context).size.width - 40) /
//                                           3,
//                                   height: 50,
//                                   child: Center(
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: <Widget>[
//                                         Text(
//                                           widget.data.popularity.toString(),
//                                           style: TextStyle(
//                                               color: Colors.green,
//                                               fontSize: 24,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                         Text(
//                                           "Popularity",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   width:
//                                       (MediaQuery.of(context).size.width - 40) /
//                                           3,
//                                   height: 50,
//                                   child: Center(
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: <Widget>[
//                                         Icon(Icons.star,
//                                             color: Colors.redAccent, size: 24),
//                                         RichText(
//                                           text: TextSpan(
//                                             text: widget.data.vote_average,
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 18),
//                                             children: <TextSpan>[
//                                               TextSpan(
//                                                 text: ' / 10',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.white,
//                                                     fontSize: 12),
//                                               ),
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   width:
//                                       (MediaQuery.of(context).size.width - 40) /
//                                           3,
//                                   height: 50,
//                                   child: Center(
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: <Widget>[
//                                         Text(
//                                           widget.data.vote_count.toString(),
//                                           style: TextStyle(
//                                               color: Colors.blue,
//                                               fontSize: 24,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                         Text(
//                                           "Vote Count",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 8),
//                             Container(
//                               margin: EdgeInsets.only(left: 20, right: 20),
//                               width: MediaQuery.of(context).size.width,
//                               height: 0.5,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 8),
//                             Container(
//                               margin: EdgeInsets.only(left: 20),
//                               width: MediaQuery.of(context).size.width - 40,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: <Widget>[
//                                   Text(
//                                     'Description',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     widget.data.overview,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Container(
//                               margin: EdgeInsets.only(left: 20),
//                               width: MediaQuery.of(context).size.width - 40,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: <Widget>[
//                                   Text(
//                                     'Trailers',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   Container(
//                                     margin:
//                                         EdgeInsets.only(bottom: 20, left: 20),
//                                     width:
//                                         MediaQuery.of(context).size.width - 40,
//                                     child: PreloadTrailer(
//                                         widget.data.id, doSomething),
//                                   ),
//                                   Container(
//                                     margin: EdgeInsets.only(top: 13),
//                                     height: 20,
//                                     child: Text(
//                                       'Provide space for banner ad',
//                                       style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class GenresItems extends StatefulWidget {
//   final String genres;
//   GenresItems(this.genres);
//   @override
//   State<StatefulWidget> createState() {
//     return _GenreItemsState();
//   }
// }

// class _GenreItemsState extends State<GenresItems> {
//   Widget GenreItem(String genre) {
//     return Container(
//       decoration: BoxDecoration(
//           border: Border.all(color: Colors.white),
//           borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
//         child: Text(
//           genre,
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Future<List<Widget>> _getGenres(String genre) async {
//     var values = List<Widget>();
//     var items = genre.split(',');
//     for (int i = 0; i < items.length - 1; i++) {
//       values.add(GenreItem(items[i]));
//     }
//     await Future.delayed(Duration(seconds: 0));
//     return values;
//   }

//   Widget _buildGenres(AsyncSnapshot snapshot) {
//     List<Widget> values = snapshot.data;
//     return Container(
//       width: MediaQuery.of(context).size.width - 20,
//       child: Wrap(
//         direction: Axis.horizontal,
//         runSpacing: 8,
//         spacing: 8,
//         crossAxisAlignment: WrapCrossAlignment.start,
//         children: values,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _getGenres(widget.genres),
//       builder: (BuildContext context, AsyncSnapshot snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.none:
//           case ConnectionState.waiting:
//             return Container();
//           default:
//             if (snapshot.hasError) {
//               return Text('Something went wrong');
//             } else {
//               return _buildGenres(snapshot);
//             }
//         }
//       },
//     );
//   }
// }

// class PreloadTrailer extends StatefulWidget {
//   final int movieId;
//   final MyCallback callback;
//   PreloadTrailer(this.movieId, this.callback);
//   @override
//   State<StatefulWidget> createState() {
//     return _PreloadTrailerState();
//   }
// }

// class _PreloadTrailerState extends State<PreloadTrailer> {
//   @override
//   Widget build(BuildContext context) {
//     block_trailer.fetchAllTrailers(widget.movieId);
//     return StreamBuilder(
//       stream: block_trailer.allTrailers,
//       builder: (context, AsyncSnapshot<TrailerModel> snapshot) {
//         if (snapshot.hasData) {
//           if (snapshot.data.results.length > 0) {
//             int itemCount = (snapshot.data.results.length / 2).round();
//             double _heigth = itemCount * 155.0;
//             return Container(
//               width: MediaQuery.of(context).size.width - 40,
//               height: _heigth,
//               child: TrailerPage(snapshot, widget.callback),
//             );
//           } else {
//             return Text(
//               'Trailer is not available for now',
//               style: TextStyle(color: Colors.white),
//             );
//           }
//         } else if (snapshot.hasError) {
//           return Text(snapshot.error.toString(),
//               style: TextStyle(color: Colors.white));
//         }
//         return Center(child: CircularProgressIndicator());
//       },
//     );
//   }
// }

// Future insertFavorite(BuildContext context, HomePresenter homePresenter,
//     dynamic data, String genres, TrailerModel trailerModel) async {
//   Client client = Client();
//   Uint8List _image = await client.readBytes(
//       'https://image.tmdb.org/t/p/w185//${data.poster_path.replaceAll('w185', 'w400')}');
//   Uint8List _image_back = await client.readBytes(
//               'https://image.tmdb.org/t/p/w185//${data.backdrop_path}') ==
//           null
//       ? 'https://lightning.od-cdn.com/static/img/no-cover_en_US.a8920a302274ea37cfaecb7cf318890e.jpg'
//       : await client
//           .readBytes('https://image.tmdb.org/t/p/w185//${data.backdrop_path}');
//   Favorites favorite = Favorites(
//     data.title,
//     data.id,
//     _image,
//     _image_back,
//     data.release_date,
//     data.vote_count,
//     data.vote_average,
//     genres,
//     data.overview,
//     data.popularity.toString(),
//   );
//   await homePresenter.db.insertMovie(favorite);
//   FavoriteTrailer mytrailer = FavoriteTrailer.fromJson(trailerModel);
//   for (var i = 0; i < mytrailer.results.length; i++) {
//     mytrailer.results[i].movie_id = data.id;
//     await homePresenter.db.insertMovieTrailer(mytrailer.results[i]);
//   }
//   homePresenter.updateScreen();
// }

// typedef void MyCallback(TrailerModel model);
