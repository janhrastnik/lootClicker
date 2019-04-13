import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'clickerbloc.dart';
import 'backdrop.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:math';

enum FrontPanels {characterPage, shopPage, skillsPage}
List eventTypes = ["loot", "fight", "puzzle"];
double TILE_LENGTH;
Hero hero = Hero();
bool isScrolling = false;
bool isMenu = false;

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
  TapAnimationBloc _tapAnimationBloc;
  HeroHpBloc _heroHpBloc;
  HeroExpBloc _heroExpBloc;

  @override
  void initState() {
    _goldBloc = GoldBloc();
    _dungeonBloc = DungeonBloc();
    _clickerBloc = ClickerBloc(goldBloc: _goldBloc);
    _tapAnimationBloc = TapAnimationBloc();
    _heroHpBloc = HeroHpBloc();
    _heroExpBloc = HeroExpBloc();
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
          BlocProvider<GoldBloc>(bloc: _goldBloc),
          BlocProvider<TapAnimationBloc>(bloc: _tapAnimationBloc),
          BlocProvider<HeroHpBloc>(bloc: _heroHpBloc),
          BlocProvider<HeroExpBloc>(bloc: _heroExpBloc),
        ],
        child: ComplexExample(),
      ),
    );
  }
}

class DungeonList extends StatefulWidget {
  @override
  DungeonListState createState() => DungeonListState();
}

class DungeonListState extends State<DungeonList> with TickerProviderStateMixin {
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
      isScrolling = false;
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
    final HeroHpBloc _heroHpBloc = BlocProvider.of<HeroHpBloc>(context);
    final HeroExpBloc _heroExpBloc = BlocProvider.of<HeroExpBloc>(context);
    final TapAnimationBloc _tapAnimationBloc = BlocProvider.of<TapAnimationBloc>(context);
    final tapAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    final tapAnimation = Tween(begin: 1.0, end: 0.0).animate(tapAnimationController);
    final goldAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    final goldAnimation = Tween(begin: 1.0, end: 0.0).animate(goldAnimationController);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (!isScrolling) {
                _clickerBloc.dispatch(_dungeonTiles);
              }
            },
            onTapUp: (TapUpDetails details) {
              if (!isScrolling) {
                tapAnimationController.reset();
                List<dynamic> data = _onTapUp(details);
                dynamic event = _dungeonTiles[1].event.eventType;
                data.add(event);
                _tapAnimationBloc.dispatch(data);
              }
            },
            child: Column(
              children: <Widget>[
                BlocBuilder(
                    bloc: _goldBloc,
                    builder: (BuildContext context, int newGold) {
                      goldAnimationController.reset();
                      goldAnimationController.forward();
                      hero.gold = hero.gold + newGold;
                      return Column(
                        children: <Widget>[
                          Text("Gold: " + hero.gold.toString()),
                          FadeTransition(
                            opacity: goldAnimation,
                            child: Text("+ " + newGold.toString(), style: TextStyle(color: Colors.amber),),
                          )
                        ],
                      );
                    }
                ),
                BlocBuilder(
                    bloc: _heroHpBloc,
                    builder: (BuildContext context, double value) {
                      return Column(
                        children: <Widget>[
                          Text("Health Points"),
                          Container(
                            width: 300.0,
                            height: 13.0,
                            child: LinearProgressIndicator(
                              value: value,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              backgroundColor: Colors.redAccent,
                            ),
                          )
                        ],
                      );
                }),
                BlocBuilder(
                    bloc: _heroExpBloc,
                    builder: (BuildContext context, double value) {
                      return Column(
                        children: <Widget>[
                          Text("Experience Points"),
                          Container(
                            width: 300.0,
                            height: 13.0,
                            child: LinearProgressIndicator(
                              value: value,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                              backgroundColor: Colors.lightGreenAccent,
                            ),
                          )
                        ],
                      );
                    }),
                Expanded(
                  child: BlocBuilder(
                    bloc: _dungeonBloc,
                    builder: (BuildContext context, List<DungeonTile> l) {
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
                      if (isMenu == false) {
                        if (progress == -1) {
                          isScrolling = true;
                          _scrollDungeon(_dungeonBloc);
                        }
                      }
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            height: 30.0,
                            child: LinearProgressIndicator(
                              value: progress,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_dungeonTiles[1].event.progress.toString()),
                              Text(" / "),
                              Text(_dungeonTiles[1].event.length.toString()),

                            ],
                          ),
                        ],
                      );
                    }
                )
              ],
            ),
          ),
          BlocBuilder(
              bloc: _tapAnimationBloc,
              builder: (BuildContext context, List tapData) {
                if (tapData.length == 3) {
                  tapAnimationController.forward();
                  print(tapData[2]);
                  return Positioned(
                      left: tapData[0],
                      top: tapData[1],
                      child: FadeTransition(
                        opacity: tapAnimation,
                        child: Text("+ " + tapData[2].toString()),
                      ),
                  );
                } else {
                  return Container(child: null);
                }
              }
          )
        ],
      ),
    );
  }
}

class FrontPanelModel extends Model {
  FrontPanelModel(this._activePanel);
  FrontPanels _activePanel;

  FrontPanels get activePanelType => _activePanel;

  Widget get activePanel {
    if (_activePanel == FrontPanels.characterPage) {
      return CharacterScreen();
    } else if (_activePanel == FrontPanels.shopPage) {
      return ShopScreen();
    } else if (_activePanel == FrontPanels.skillsPage) {
      return SkillsScreen();
    }
  }

  void activate(FrontPanels panel) {
    _activePanel = panel;
    notifyListeners();
  }
}

class ComplexExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ScopedModel(
        model: FrontPanelModel(FrontPanels.characterPage),
        child: Scaffold(body: SafeArea(child: Panels())));
}

class Panels extends StatelessWidget {
  final frontPanelVisible = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<FrontPanelModel>(
      builder: (context, _, model) => Backdrop(
        menuRow: MenuRow(
          frontPanelOpen: frontPanelVisible,
        ),
        frontLayer: model.activePanel,
        backLayer: DungeonList(),
        panelVisible: frontPanelVisible,
        frontPanelOpenHeight: 40.0,
        frontHeaderHeight: 0.0,
      ),
    );
  }
}

class MenuRow extends StatefulWidget {
  MenuRow({@required this.frontPanelOpen});
  final ValueNotifier<bool> frontPanelOpen;

  MenuRowState createState() => MenuRowState();
}

class MenuRowState extends State<MenuRow> {
  bool panelOpen;

  @override
  initState() {
    super.initState();
    panelOpen = widget.frontPanelOpen.value;
    widget.frontPanelOpen.addListener(_subscribeToValueNotifier);
  }

  void _subscribeToValueNotifier() =>
      setState(() => panelOpen = widget.frontPanelOpen.value);

  /// Required for resubscribing when hot reload occurs
  @override
  void didUpdateWidget(MenuRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.frontPanelOpen.removeListener(_subscribeToValueNotifier);
    widget.frontPanelOpen.addListener(_subscribeToValueNotifier);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        ScopedModelDescendant<FrontPanelModel>(
        rebuildOnChange: false,
          builder: (context, _, model) => MaterialButton(
            color: model._activePanel == FrontPanels.characterPage &&
                widget.frontPanelOpen.value ?
            Colors.lightGreenAccent :
            Colors.white,
            child: Text("Character"),
            onPressed: () {
              if (widget.frontPanelOpen.value == true && model._activePanel == FrontPanels.characterPage) {
                toggleBackdropPanelVisibility(widget.frontPanelOpen.value);
                isMenu = false;
              } else {
                isMenu = true;
                model.activate(FrontPanels.characterPage);
                widget.frontPanelOpen.value = true;
              }
            },
          )
        ),
        ScopedModelDescendant<FrontPanelModel>(
          rebuildOnChange: false,
          builder: (context, _, model) => MaterialButton(
            color: model._activePanel == FrontPanels.shopPage &&
                widget.frontPanelOpen.value ?
            Colors.lightGreenAccent :
            Colors.white,
            child: Text("Shop"),
            onPressed: () {
              if (widget.frontPanelOpen.value == true && model._activePanel == FrontPanels.shopPage) {
                toggleBackdropPanelVisibility(widget.frontPanelOpen.value);
                isMenu = false;
              }  else {
                isMenu = true;
                model.activate(FrontPanels.shopPage);
                widget.frontPanelOpen.value = true;
              }
            },
            )
        ),
        ScopedModelDescendant<FrontPanelModel>(
            rebuildOnChange: false,
            builder: (context, _, model) => MaterialButton(
              color: model._activePanel == FrontPanels.skillsPage &&
                  widget.frontPanelOpen.value ?
              Colors.lightGreenAccent :
              Colors.white,
              child: Text("Skills"),
              onPressed: () {
                if (widget.frontPanelOpen.value == true && model._activePanel == FrontPanels.skillsPage) {
                  toggleBackdropPanelVisibility(widget.frontPanelOpen.value);
                  isMenu = false;
                }  else {
                  isMenu = true;
                  model.activate(FrontPanels.skillsPage);
                  widget.frontPanelOpen.value = true;
                }
              },
            )
        )
      ],
    );
  }
}

class CharacterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(color: Colors.teal, child: Center(child: Text('CharacterScreen')));
}

class ShopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(color: Colors.lime, child: Center(child: Text('ShopScreen')));
}

class SkillsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(color: Colors.cyan, child: Center(child: Text('SkillsScreen')));
}

class DungeonTile extends StatelessWidget {
  DungeonTile({Key key, @required this.event}) : super(key: key);

  final DungeonEvent event;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: TILE_LENGTH,
        height: 200.0,
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
  int loot;
  DungeonEvent({
    @required this.eventType,
    @required this.length,
    this.progress = 0,
    this.loot = 1
  });

  @override
  String toString() =>
      'DungeonEvent { evenType: $eventType, length: $length, progress: $progress }';
}

class Hero {
  int gold;
  int hp;
  int hpCap;
  int attack;
  int looting;
  int intelligence;
  int exp;
  int expCap;
  List skills;
  List inventory;
  Enemy enemy;

  Hero({this.gold = 0,
    this.hp = 100,
    this.hpCap = 100,
    this.attack = 1,
    this.intelligence = 1,
    this.looting = 1,
    this.exp = 0,
    this.expCap = 100,
    this.skills,
    this.inventory,
    this.enemy
  });
}

DungeonTile generateDungeon() {
  int randomRange(int min, int max) => min + Random().nextInt(max - min);
  int dungeonType = Random().nextInt(eventTypes.length);
  int lootAmount = randomRange(1, 10);
  int length = randomRange(10, 20);
  
  return DungeonTile(event: DungeonEvent(eventType: eventTypes[dungeonType], length: length, loot: lootAmount));
}

void levelUp() {
  // TODO
}

_onTapUp(TapUpDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    return <dynamic>[x, y];
}

class Enemy {
  int hp;
  int expValue;
  int attack;

  Enemy({
    this.hp,
    this.expValue,
    this.attack
  });
}

Enemy rat = Enemy(hp: 10, expValue: 5, attack: 1);