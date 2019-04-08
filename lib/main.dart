import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'clickerbloc.dart';

List eventTypes = ["loot", "fight", "puzzle"];
double TILE_LENGTH;
int heroGold = 0;

class MyBlocDelegate extends BlocDelegate {
  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    print(error);
  }

  @override
  void onTransition(Transition transition) {
    super.onTransition(transition);
    print(transition);
  }
}

void main() {
  BlocSupervisor().delegate = MyBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  DungeonBloc _dungeonBloc;
  ClickerBloc _clickerBloc;
  GoldBloc _goldBloc;

  @override
  void initState() {
    _goldBloc = GoldBloc();
    _dungeonBloc = DungeonBloc();
    _clickerBloc = ClickerBloc(goldBloc: _goldBloc);
    super.initState();
  }

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
          BlocProvider<DungeonBloc>(bloc: _dungeonBloc),
          BlocProvider<ClickerBloc>(bloc: _clickerBloc),
          BlocProvider<GoldBloc>(bloc: _goldBloc)
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

  void _scrollToMiddle() {
    _scrollController.jumpTo(MediaQuery.of(context).size.width/4);
  }

  void _scrollDungeon(DungeonBloc bloc) {
    _scrollToMiddle();
    bloc.dispatch(_dungeonTiles);
    _scrollController.animateTo(
        _scrollController.offset + MediaQuery.of(context).size.width/2,
        duration: Duration(seconds: 1),
        curve: Curves.ease
    ).then((data) {
      bloc.dispatch(_dungeonTiles);
      _scrollToMiddle();
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
    final DungeonBloc _dungeonBloc = BlocProvider.of<DungeonBloc>(context);
    final ClickerBloc _clickerBloc = BlocProvider.of<ClickerBloc>(context);
    final GoldBloc _goldBloc = BlocProvider.of<GoldBloc>(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _clickerBloc.dispatch(_dungeonTiles[1].event);
        },
        child: Column(
          children: <Widget>[
            BlocBuilder(
            bloc: _goldBloc,
            builder: (BuildContext context, int gold) {
              heroGold = gold;
              return Text("Gold: " + gold.toString());
            }
            ),
            Expanded(
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
                    itemBuilder: (BuildContext context, int index) =>
                    _dungeonTiles[index],
                  );
                },
              ),
            ),
            BlocBuilder(
                bloc: _clickerBloc,
                builder: (BuildContext context, double progress) {
                  print(progress);
                  if (progress == -1) {
                    _scrollDungeon(_dungeonBloc);
                  }
                  return LinearProgressIndicator(
                    value: progress,
                  );
                }
            )
          ],
        ),
      ),
    );
  }
}

class DungeonTile extends StatelessWidget {
  DungeonTile({Key key, @required this.event}) : super(key: key);

  final DungeonEvent event;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: TILE_LENGTH,
        height: 100.0,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/mayclover_meadow_example.png"), fit: BoxFit.cover),
            border: new Border.all(color: Colors.blueAccent)
        ),
        alignment: Alignment(0.7, 0.0),
        child: Text(event.eventType),
      )
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return 'DungeonTile { event: $event }';
  }
}

class DungeonEvent {
  String eventType;
  int length;
  int progress;
  DungeonEvent({
    @required this.eventType,
    @required this.length,
    this.progress = 0,
  });

  @override
  String toString() =>
      'DungeonEvent { evenType: $eventType, length: $length, progress: $progress }';
}