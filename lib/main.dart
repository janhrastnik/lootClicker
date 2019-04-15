import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs.dart';
import 'backdrop.dart';
import 'package:scoped_model/scoped_model.dart';
import 'classes.dart';

enum FrontPanels {characterPage, shopPage, skillsPage}
Player player = Player();
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
    _heroHpBloc = HeroHpBloc();
    _heroExpBloc = HeroExpBloc();
    _dungeonBloc = DungeonBloc();
    _clickerBloc = ClickerBloc(goldBloc: _goldBloc, heroHpBloc: _heroHpBloc, heroExpBloc: _heroExpBloc);
    _tapAnimationBloc = TapAnimationBloc();
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
        child: ClickerApp(),
      ),
    );
  }
}

class ClickerApp extends StatelessWidget {
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

class DungeonList extends StatefulWidget {
  @override
  DungeonListState createState() => DungeonListState();
}

class DungeonListState extends State<DungeonList> with TickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();

  // TODO: generate random beggining dungeon tiles
  List<DungeonTile> _dungeonTiles = [
    DungeonTile(event: DungeonEvent(eventType: "fight", length: 10, enemy: rat)),
    DungeonTile(event: DungeonEvent(eventType: "fight", length: 10, enemy: rat)),
    DungeonTile(event: DungeonEvent(eventType: "fight", length: 10, enemy: rat))
  ];

  // TODO: move to a new bloc maybe
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

  _onTapUp(TapUpDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    return <dynamic>[x, y];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMiddle());
  }

  @override
  Widget build(BuildContext context) {
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
      body: GestureDetector(
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
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                BlocBuilder(
                    bloc: _goldBloc,
                    builder: (BuildContext context, int newGold) {
                      goldAnimationController.reset();
                      goldAnimationController.forward();
                      player.gold = player.gold + newGold;
                      return Column(
                        children: <Widget>[
                          Text("Gold: " + player.gold.toString()),
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
                              backgroundColor: Colors.deepOrangeAccent,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
                      // TODO: move to blocs.dart
                      if (isMenu == false) {
                        if (progress == -1) {
                          isScrolling = true;
                          _scrollDungeon(_dungeonBloc);
                        }
                      }
                      if (progress == 0.0 && _dungeonTiles[1].event.eventType == "fight") {
                        progress = 1.0;
                      }
                      if (progress == -1 &&
                          _dungeonTiles[1].event.eventType == "fight" &&
                          _dungeonTiles[2].event.eventType == "fight") {
                        progress = 1.0;
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
                              _dungeonTiles[1].event.eventType == "fight" ?
                              Text((_dungeonTiles[1].event.length - _dungeonTiles[1].event.progress).toString())
                              : Text(_dungeonTiles[1].event.progress.toString()),
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
            BlocBuilder(
                bloc: _tapAnimationBloc,
                builder: (BuildContext context, List tapData) {
                  if (tapData.length == 3) {
                    tapAnimationController.forward();
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