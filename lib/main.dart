import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs.dart';
import 'backdrop.dart';
import 'package:scoped_model/scoped_model.dart';
import 'classes.dart';

enum FrontPanels {characterPage, shopPage, skillsPage}
Player player = Player(
  inventory: [], equipped: {
    "weapon": null,
    "shield": null,
    "helmet": null,
    "body": null
    }
  );
bool isMenu = false;
bool isScrolling = false;
bool isDead = false;
double TILE_LENGTH;
List<DungeonTile> dungeonTiles = [
  DungeonTile(event: DungeonEvent(eventType: "wall", length: null)),
  DungeonTile(event: DungeonEvent(eventType: "shrine", length: null)),
  DungeonTile(event: DungeonEvent(eventType: "empty", length: null))

];
ScrollController scrollController = ScrollController();
AnimationController progressAnimationController;
AnimationController deathAnimationController;
AnimationController goldAnimationController;
Map monsters = {};
Map items = {};

class MyBlocDelegate extends BlocDelegate {
  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    // print(error);
  }

  @override
  void onTransition(Transition transition) {
    super.onTransition(transition);
    // print(transition);
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

  Future readData(file) async {
    try {
      String data  = await rootBundle.loadString(file);
      return jsonDecode(data);
    } catch (e) {
      print(e);
      // If encountering an error, return 0
      return 0;
    }
  }

  @override
  void initState() {
    _goldBloc = GoldBloc();
    _dungeonBloc = DungeonBloc();
    _heroHpBloc = HeroHpBloc(
      dungeonBloc: _dungeonBloc
    );
    _heroExpBloc = HeroExpBloc(
      heroHpBloc: _heroHpBloc
    );
    _clickerBloc = ClickerBloc(
        goldBloc: _goldBloc,
        heroHpBloc: _heroHpBloc,
        heroExpBloc: _heroExpBloc,
        dungeonBloc: _dungeonBloc
    );
    _tapAnimationBloc = TapAnimationBloc();
    // get monsters, items from json files, add them to globals
    readData("assets/monsters.json").then((data) {
      data.forEach((key, value) {
        monsters[key] = Enemy(
          name: key,
          hp: value["hp"],
          expValue: value["expValue"],
          attack: value["attack"],
          loot: value["loot"]
        );
      });
      print(monsters.keys.toList().toString());
    });
    readData("assets/items.json").then((data) {
      Map _data = data["items"];
      _data.forEach((key, args) {
        items[key] = Item(name: key, equip: args["equip"], behaviours: args);
      });
    });
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
        frontPanelOpenHeight: 20.0,
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

  _onTapUp(TapUpDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    return <dynamic>[x, y];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        TILE_LENGTH = MediaQuery.of(context).size.width/2;
        return scrollController.jumpTo(MediaQuery.of(context).size.width/4);
    });
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
    goldAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    final goldAnimation = Tween(begin: 0.0, end: 1.0).animate(goldAnimationController);
    progressAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    final progressAnimation = Tween(begin: 1.0, end: 0.0).animate(progressAnimationController);
    deathAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    final deathAnimation = Tween(begin: 0.0, end: 1.0).animate(deathAnimationController);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (!isScrolling) {
            _clickerBloc.dispatch(dungeonTiles);
          }
        },
        onTapUp: (TapUpDetails details) {
          if (!isScrolling) {
            tapAnimationController.reset();
            List<dynamic> data = _onTapUp(details);
            dynamic event = dungeonTiles[1].event.eventType;
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
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                width: 300.0,
                                height: 16.0,
                                child: LinearProgressIndicator(
                                  value: value,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                  backgroundColor: Colors.deepOrangeAccent,
                                ),
                              ),
                              Text("${player.hp} / ${player.hpCap} HP")
                            ],
                          )
                        ],
                      );
                }),
                BlocBuilder(
                    bloc: _heroExpBloc,
                    builder: (BuildContext context, double value) {
                      return Column(
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                width: 300.0,
                                height: 16.0,
                                child: LinearProgressIndicator(
                                  value: value,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                  backgroundColor: Colors.lightGreenAccent,
                                ),
                              ),
                              Text("${player.exp} / ${player.expCap} EXP")
                            ],
                          )
                        ],
                      );
                    }),
                Expanded(
                  child: BlocBuilder(
                    bloc: _dungeonBloc,
                    builder: (BuildContext context, List<DungeonTile> l) {
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        controller: scrollController,
                        padding: EdgeInsets.all(0.0),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: l.length,
                        itemBuilder: (BuildContext context, int index) =>
                        l[index],
                      );
                    },
                  ),
                ),
                BlocBuilder(
                    bloc: _clickerBloc,
                    builder: (BuildContext context, double progress) {
                      // TODO: no need to yield -1 anymore
                      String eventText;
                       if (dungeonTiles[1].event.eventType == "shrine") {
                        eventText = "Enter The Dungeon";
                      } if (dungeonTiles[1].event.eventType == "empty") {
                        eventText = "placeholder";
                      } if (isDead) {
                        progress = 1.0;
                        eventText = "Enter The Dungeon";
                        isDead = false;
                      }
                      if (progress == 0.0) {
                         progress = 1.0;
                      }
                      return FadeTransition(
                        opacity: progressAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              height: 30.0,
                              child: LinearProgressIndicator(
                                value: progress,
                              ),
                            ),
                            dungeonTiles[1].event.eventType == "shrine" || dungeonTiles[1].event.eventType == "empty" ?
                            Text(eventText) : Text("${dungeonTiles[1].event.length - dungeonTiles[1].event.progress} / ${dungeonTiles[1].event.length}"),
                          ],
                        ),
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
            ),
            Positioned(
              left: 0,
              top: 0,
              child: FadeTransition(
                  opacity: deathAnimation,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black,
                  )
              ),
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

class CharacterScreen extends StatefulWidget {
  CharacterScreenState createState() => CharacterScreenState();
}

class CharacterScreenState extends State<CharacterScreen> {

  @override
  void initState() {
    super.initState();
  }

  dynamic useItem(Item item, index) {
    setState(() {
        print("mate");
        item.use(
          BlocProvider.of<HeroHpBloc>(context),
          BlocProvider.of<HeroExpBloc>(context),
          BlocProvider.of<GoldBloc>(context),
          BlocProvider.of<ClickerBloc>(context)
        );
        player.inventory.removeAt(index);
        player.inventory.insert(index, null);
        player.numberOfItems--;
    });
  }

  @override
  Widget build(BuildContext context) =>
      Container(
          color: Colors.teal,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text("Stats"),
                      Text("HP: ${player.hp}/${player.hpCap}"),
                      Text("EXP: ${player.exp}/${player.expCap}"),
                      Text("Attack: ${player.attack}"),
                      Text("Intelligence: ${player.intelligence}"),
                      Text("Looting: ${player.looting}")
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text("Equipment"),
                      ItemSlot(item: player.equipped["weapon"],),
                      ItemSlot(item: player.equipped["shield"]),
                      ItemSlot(item: player.equipped["helmet"]),
                      ItemSlot(item: player.equipped["body"])
                    ],
                  )
                ],
              ),
              Text("Inventory"),
              Stack(
                children: <Widget>[
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 6,
                    children: List.generate(30, (int index) => ItemSlot()),
                  ),
                  GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
                      itemCount: player.inventory.length,
                      itemBuilder: (BuildContext context, int index) => ItemSlot(
                        index: index,
                        item: items[player.inventory[index]],
                        useItem: useItem
                      )
                  ),
                ],
              )
            ],
          )
      );
}

class ItemSlot extends StatelessWidget {
  final Item item;
  final int index;
  dynamic useItem;
  ItemSlot({this.item, this.index, this.useItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: () {
          if (item != null) {
            useItem(item, index);
          }
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black54
              ),
            ),
            width: 60.0,
            height: 60.0,
            child: item != null ? Center(child: Text(item.name),) : null
        ),
      ),
    );
  }
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