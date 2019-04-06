import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

double TILE_LENGTH;
List tileTypes = ["loot", "fight", "puzzle"];
var r = Random();
int randnum;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DungeonList(),
      );
  }
}

class DungeonList extends StatefulWidget {
  @override
  DungeonListState createState() => DungeonListState();
}

class DungeonListState extends State<DungeonList> {
  ScrollController _scrollController = ScrollController();
  List<DungeonTile> _dungeonTiles = [
    DungeonTile(event: DungeonEvent(eventType: "loot", length: 100)),
    DungeonTile(event: DungeonEvent(eventType: "fight", length: 100)),
    DungeonTile(event: DungeonEvent(eventType: "puzzle", length: 100))
  ];

  _scrollToMiddle() {
    _scrollController.jumpTo(MediaQuery.of(context).size.width/4);
    print("BEGGINING OFFSET IS ${_scrollController.offset}");
  }

  _scrollToNextRoom() {
    randnum = r.nextInt(tileTypes.length);
    setState(() {
      _scrollToMiddle();
      _dungeonTiles.add(DungeonTile(event: DungeonEvent(eventType: tileTypes[randnum], length: 100)));
      _scrollController.animateTo(
          _scrollController.offset + MediaQuery.of(context).size.width/2,
          duration: Duration(seconds: 1),
          curve: Curves.ease
      ).then((data) {
        _dungeonTiles.removeAt(0);
        print(_dungeonTiles);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMiddle());
  }

  @override
  Widget build(BuildContext context) {
    TILE_LENGTH = MediaQuery.of(context).size.width/2;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                _scrollToNextRoom();
              },
              child: Center(
                child: Stack(
                  alignment: Alignment(-0.1, 0.0),
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 200.0
                      ),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _scrollController,
                        padding: EdgeInsets.all(0.0),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: _dungeonTiles.length,
                        itemBuilder: (BuildContext, int index) => _dungeonTiles[index],
                      ),
                    ),
                    Text("Hero")
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Text("Hero"),
              Text("Inventory"),
              Text("Skills")
            ],
          )
        ],
      ),
    );
  }
}

class DungeonTile extends StatelessWidget {
  DungeonTile({Key key, @required this.event}) : super(key: key);

  final DungeonEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TILE_LENGTH,
      height: 100.0,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/mayclover_meadow_example.png"), fit: BoxFit.cover),
        border: new Border.all(color: Colors.blueAccent)
      ),
      alignment: Alignment(0.7, 0.0),
      child: Text(event.eventType),
    );
  }
}

class DungeonEvent {
  String eventType;
  int length;
  DungeonEvent({@required this.eventType, @required this.length});
}