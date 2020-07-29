import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/trailer_model.dart';
import './movie_details.dart';
import '../services/youtube_player.dart';

class TrailerPage extends StatefulWidget {
  final AsyncSnapshot<TrailerModel> snapshot;
  final MyCallback callback;
  TrailerPage(this.snapshot, this.callback);
  @override
  State<StatefulWidget> createState() {
    return _TrailerPageState();
  }
}

class _TrailerPageState extends State<TrailerPage> {
  @override
  void initState() {
    super.initState();
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => widget.callback(widget.snapshot.data));
    }
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth = (MediaQuery.of(context).size.width - 16) / 2;
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: (itemWidth / 155),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: NeverScrollableScrollPhysics(),
      children:
          List<Widget>.generate(widget.snapshot.data.results.length, (index) {
        return GridTile(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PlayVideo(widget.snapshot.data.results[index].key),
                ),
              );
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlayVideo(widget.snapshot.data.results[index].key),
                      ),
                    );
                  },
                  child: Wrap(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 2),
                        child: Stack(
                          children: <Widget>[
                            Image.network(backdrop_path),
                            Container(
                              width: itemWidth,
                              height: 100,
                              color: Colors.black38,
                            ),
                            Positioned(
                              top: 36,
                              left: (itemWidth - 36 - 16) / 2,
                              child: Icon(
                                Icons.play_circle_filled,
                                size: 36,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      Text(
                        widget.snapshot.data.results[index].name,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )),
          ),
        );
      }),
    );
  }
}
