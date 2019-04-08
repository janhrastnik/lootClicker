import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'clickerbloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

double TILE_LENGTH;
List eventTypes = ["loot", "fight", "puzzle"];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final ClickerBloc _clickerBloc = ClickerBloc();
  final DungeonBloc _dungeonBloc = DungeonBloc();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProviderTree(
        blocProviders: <BlocProvider>[
          BlocProvider<ClickerBloc>(bloc: _clickerBloc),
          BlocProvider<DungeonBloc>(bloc: _dungeonBloc),
        ],
        child: DungeonList(),
      ),
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
    DungeonTile(event: DungeonEvent(eventType: "loot", length: 10)),
    DungeonTile(event: DungeonEvent(eventType: "fight", length: 10)),
    DungeonTile(event: DungeonEvent(eventType: "puzzle", length: 10))
  ];

  _scrollToMiddle() {
    _scrollController.jumpTo(MediaQuery.of(context).size.width/4);
    print("OFFSET IS ${_scrollController.offset}");
  }

  _scrollToNextRoom(bloc) {
    _scrollToMiddle();
    print(_scrollController.offset);
    bloc.dispatch(_dungeonTiles);
    _scrollController.animateTo(
      90.0 + MediaQuery.of(context).size.width/2,
      duration: Duration(seconds: 1),
      curve: Curves.ease
    ).then((data) {
      bloc.dispatch(_dungeonTiles);
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
    final ClickerBloc _clickerBloc = BlocProvider.of<ClickerBloc>(context);
    final DungeonBloc _dungeonBloc = BlocProvider.of<DungeonBloc>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                _clickerBloc.dispatch(_dungeonTiles[1].event);
              },
              child: Center(
                child: Stack(
                  alignment: Alignment(-0.1, 0.0),
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 200.0
                      ),
                      child: BlocBuilder(
                          bloc: _dungeonBloc,
                          builder: (BuildContext context, List<DungeonTile> l) {
                            print("BLOCBUILDER GETS CALLED");
                            _dungeonTiles = l;
                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              controller: _scrollController,
                              padding: EdgeInsets.all(0.0),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: _dungeonTiles.length,
                              itemBuilder: (BuildContext, int index) => _dungeonTiles[index],
                            );
                          }
                      ),
                    ),
                    Text("Hero")
                  ],
                ),
              ),
            ),
          ),
          BlocBuilder(
              bloc: _clickerBloc,
              builder: (BuildContext context, double progress) {
                print(progress);
                if (progress == -1) {
                  _scrollToNextRoom(_dungeonBloc);
                }
                return LinearProgressIndicator(
                  value: progress,
                );
              }
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
  int progress;
  DungeonEvent({@required this.eventType, @required this.length, this.progress=0});
}