import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs.dart';
import 'backdrop.dart';
import 'package:scoped_model/scoped_model.dart';
import 'classes.dart';
import 'dart:async';

enum FrontPanels { characterPage, shopPage, skillsPage }
Player player = Player(
    inventory: [],
    equipped: {"weapon": null, "shield": null, "helmet": null, "body": null});
bool isMenu = false;
bool isScrolling = false;
bool isDead = false;
double TILE_LENGTH;
int id = 0;
List<DungeonTile> dungeonTiles = [
  DungeonTile(event: DungeonEvent(eventType: "wall", length: null)),
  DungeonTile(event: DungeonEvent(eventType: "shrine", length: null)),
  DungeonTile(event: DungeonEvent(eventType: "merchant", length: null))
];
ScrollController scrollController = ScrollController();
AnimationController progressAnimationController;
AnimationController deathAnimationController;
AnimationController goldAnimationController;
Map monsters = {};
Map items = {};
Map skills = {"strength" : [], "endurance": [], "wisdom": []};
List assetNames = [];
Map<int, Effect> effects = {};
final StreamController _effectsStream = StreamController<dynamic>();

class MyBlocDelegate extends BlocDelegate {
  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    // print(error);
  }

  @override
  void onTransition(Transition transition) {
    super.onTransition(transition);
    print(dungeonTiles[1].event.eventType);
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
  ActionBloc _actionBloc;

  Future readData(file) async {
    try {
      String data = await rootBundle.loadString(file);
      return jsonDecode(data);
    } catch (e) {
      print(e);
      // If encountering an error, return 0
      return 0;
    }
  }

  @override
  void initState() {
    _actionBloc = ActionBloc();
    _goldBloc = GoldBloc();
    _dungeonBloc = DungeonBloc(actionBloc: _actionBloc);
    _heroHpBloc = HeroHpBloc(dungeonBloc: _dungeonBloc);
    _heroExpBloc = HeroExpBloc(heroHpBloc: _heroHpBloc);
    _clickerBloc = ClickerBloc(
        goldBloc: _goldBloc,
        heroHpBloc: _heroHpBloc,
        heroExpBloc: _heroExpBloc,
        dungeonBloc: _dungeonBloc);
    _tapAnimationBloc = TapAnimationBloc();
    // get monsters, items from json files, add them to globals
    readData("assets/monsters.json").then((data) {
      data.forEach((key, value) {
        monsters[key] = Enemy(
            name: key,
            hp: value["hp"],
            expValue: value["expValue"],
            attack: value["attack"],
            loot: value["loot"]);
      });
      print(monsters.keys.toList().toString());
    });
    readData("assets/items.json").then((data) {
      Map _data = data["items"];
      _data.forEach((key, args) {
        items[key] = Item(
            name: args["name"],
            id: key,
            equip: args["equip"],
            behaviours: args,
            description: args["description"],
            cost: args["cost"],
            time: args["time"]);
      });
    });
    readData("assets/skills.json").then((data) {
      data.forEach((tree, _skills) {
        print(tree);
        _skills.forEach((skillName, skillDetail) {
          print(skillName);
          print(skillDetail);
          List temp = skills[tree];
          temp.add(Skill(
              name: skillDetail["name"],
              id: skillName,
              description: skillDetail["description"],
              behaviours: skillDetail
          ));
          skills[tree] = temp;
        });
      });
      print(skills);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: "VT323"),
      home: BlocProviderTree(
        blocProviders: <BlocProvider>[
          BlocProvider<ActionBloc>(bloc: _actionBloc),
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

class DungeonListState extends State<DungeonList>
    with TickerProviderStateMixin {
  _onTapUp(TapUpDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    return <dynamic>[x, y];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TILE_LENGTH = MediaQuery.of(context).size.width / 2;
      return scrollController.jumpTo(MediaQuery.of(context).size.width / 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ActionBloc _actionBloc = BlocProvider.of<ActionBloc>(context);
    final DungeonBloc _dungeonBloc = BlocProvider.of<DungeonBloc>(context);
    final ClickerBloc _clickerBloc = BlocProvider.of<ClickerBloc>(context);
    final GoldBloc _goldBloc = BlocProvider.of<GoldBloc>(context);
    final HeroHpBloc _heroHpBloc = BlocProvider.of<HeroHpBloc>(context);
    final HeroExpBloc _heroExpBloc = BlocProvider.of<HeroExpBloc>(context);
    final TapAnimationBloc _tapAnimationBloc =
        BlocProvider.of<TapAnimationBloc>(context);
    final tapAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    final tapAnimation =
        Tween(begin: 1.0, end: 0.0).animate(tapAnimationController);
    goldAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    final goldAnimation =
        Tween(begin: 0.0, end: 1.0).animate(goldAnimationController);
    progressAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    final progressAnimation =
        Tween(begin: 1.0, end: 0.0).animate(progressAnimationController);
    deathAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    final deathAnimation =
        Tween(begin: 0.0, end: 1.0).animate(deathAnimationController);
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (!isScrolling && dungeonTiles[1].event.eventType != "fight") {
            _clickerBloc.dispatch(dungeonTiles);
          }
        },
        onTapUp: (TapUpDetails details) {
          if (!isScrolling && dungeonTiles[1].event.eventType != "fight") {
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
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("${player.gold}"),
                                Image(
                                  image: AssetImage("assets/coin.gif"),
                                )
                              ]),
                          FadeTransition(
                            opacity: goldAnimation,
                            child: Text(
                              "+ " + newGold.toString(),
                              style: TextStyle(color: Colors.amber),
                            ),
                          )
                        ],
                      );
                    }),
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
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.red),
                                  backgroundColor:
                                      Color.fromRGBO(230, 230, 230, 1.0),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
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
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            Flexible(
                              flex: 3,
                              child: BlocBuilder(
                                bloc: _dungeonBloc,
                                builder: (BuildContext context,
                                    List<DungeonTile> l) {
                                  return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    controller: scrollController,
                                    padding: EdgeInsets.all(0.0),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: l.length,
                                    itemBuilder:
                                        (BuildContext context, int index) =>
                                            l[index],
                                  );
                                },
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: BlocBuilder(
                                  bloc: _clickerBloc,
                                  builder:
                                      (BuildContext context, double progress) {
                                    String eventText;
                                    if (dungeonTiles[1].event.eventType ==
                                        "shrine") {
                                      eventText = "Enter The Dungeon";
                                    }
                                    if (dungeonTiles[1].event.eventType ==
                                        "merchant") {
                                      eventText = "placeholder";
                                    }
                                    if (isDead) {
                                      progress = 1.0;
                                      eventText = "Enter The Dungeon";
                                      isDead = false;
                                    }
                                    if (progress == 0.0) {
                                      progress = 1.0;
                                    }
                                    return Container(
                                      child: FadeTransition(
                                        opacity: progressAnimation,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black54)),
                                              width: 250.0,
                                              height: 30.0,
                                              child: LinearProgressIndicator(
                                                value: progress,
                                              ),
                                            ),
                                            dungeonTiles[1].event.eventType ==
                                                        "shrine" ||
                                                    dungeonTiles[1]
                                                            .event
                                                            .eventType ==
                                                        "merchant"
                                                ? Text(eventText)
                                                : Text(
                                                    "${dungeonTiles[1].event.length - dungeonTiles[1].event.progress} / ${dungeonTiles[1].event.length}"),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                      StreamBuilder(
                          initialData: 0,
                          stream: _effectsStream.stream,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            print("EFFECTS: " + effects.toString());
                            if (!snapshot.hasData) {
                              return Container();
                            } else if (snapshot.data == 0) {
                              return Container();
                            } else {
                              return EffectsList(
                                  effectsList: effects.values.toList());
                            }
                      }),
                      Flexible(
                        flex: 1,
                        child: BlocBuilder(
                            bloc: _actionBloc,
                            builder: (BuildContext context, String event) {
                              if (event == "fight") {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      width: 80.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.redAccent,
                                                blurRadius: 10.0,
                                                spreadRadius: 1.0)
                                          ]),
                                      child: MaterialButton(
                                        child: Text("Attack"),
                                        onPressed: () {
                                          if (!isScrolling) {
                                            _clickerBloc.dispatch(dungeonTiles);
                                          }
                                        },
                                      ),
                                    ),
                                    MaterialButton(
                                      child: Text("Flee"),
                                      onPressed: () {
                                        scrollDungeon(_dungeonBloc,
                                            _clickerBloc); // updates text
                                      },
                                    )
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            }),
                      )
                    ],
                  ),
                ),
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
                }),
            BlocBuilder(
                bloc: _heroHpBloc,
                builder: (BuildContext context, double health) {
                  if (health != 0.0) {
                    return Container();
                  } else {
                    return Positioned(
                      left: 0,
                      top: 0,
                      child: FadeTransition(
                          opacity: deathAnimation,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: Colors.black,
                          )),
                    );
                  }
                }),
            Positioned(
              top: MediaQuery.of(context).size.height / 4.5,
              left: MediaQuery.of(context).size.width / 3.5,
              child: Image(
                image: AssetImage("assets/idle.gif"),
                width: 128.0,
                height: 128.0,
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
                          widget.frontPanelOpen.value
                      ? Colors.lightGreenAccent
                      : Colors.white,
                  child: Text("Character"),
                  onPressed: () {
                    if (widget.frontPanelOpen.value == true &&
                        model._activePanel == FrontPanels.characterPage) {
                      toggleBackdropPanelVisibility(
                          widget.frontPanelOpen.value);
                      isMenu = false;
                    } else {
                      isMenu = true;
                      model.activate(FrontPanels.characterPage);
                      widget.frontPanelOpen.value = true;
                    }
                  },
                )),
        ScopedModelDescendant<FrontPanelModel>(
            rebuildOnChange: false,
            builder: (context, _, model) => MaterialButton(
                  color: model._activePanel == FrontPanels.shopPage &&
                          widget.frontPanelOpen.value
                      ? Colors.lightGreenAccent
                      : Colors.white,
                  child: Text("Shop"),
                  onPressed: () {
                    if (widget.frontPanelOpen.value == true &&
                        model._activePanel == FrontPanels.shopPage) {
                      toggleBackdropPanelVisibility(
                          widget.frontPanelOpen.value);
                      isMenu = false;
                    } else {
                      isMenu = true;
                      model.activate(FrontPanels.shopPage);
                      widget.frontPanelOpen.value = true;
                    }
                  },
                )),
        ScopedModelDescendant<FrontPanelModel>(
            rebuildOnChange: false,
            builder: (context, _, model) => MaterialButton(
                  color: model._activePanel == FrontPanels.skillsPage &&
                          widget.frontPanelOpen.value
                      ? Colors.lightGreenAccent
                      : Colors.white,
                  child: Text("Skills"),
                  onPressed: () {
                    if (widget.frontPanelOpen.value == true &&
                        model._activePanel == FrontPanels.skillsPage) {
                      toggleBackdropPanelVisibility(
                          widget.frontPanelOpen.value);
                      isMenu = false;
                    } else {
                      isMenu = true;
                      model.activate(FrontPanels.skillsPage);
                      widget.frontPanelOpen.value = true;
                    }
                  },
                ))
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

  dynamic useItem(Item item, int index, bool equipped) {
    setState(() {
      if (equipped == null || equipped == false) {
        // if the item is unequipped then we remove it
        player.inventory.removeAt(index);
        if (player.equipped[item.equip] != null) {
          // we 'unequip' the current item by using it with an opposite value
          player.inventory.add(player.equipped[item.equip].id);
          player.equipped[item.equip].use(
            BlocProvider.of<HeroHpBloc>(context),
            BlocProvider.of<HeroExpBloc>(context),
            BlocProvider.of<GoldBloc>(context),
            BlocProvider.of<ClickerBloc>(context),
            true,
            player.equipped[item.equip].equip,
            player.equipped[item.equip].behaviours
          );
        }
      } else {
        player.inventory.add(item.id);
      }
      item.use(
        BlocProvider.of<HeroHpBloc>(context),
        BlocProvider.of<HeroExpBloc>(context),
        BlocProvider.of<GoldBloc>(context),
        BlocProvider.of<ClickerBloc>(context),
        equipped,
        item.equip,
        item.behaviours
      );
      if (item.time != 0) {
        effects[id] = Effect(
          desc: item.name,
          time: item.time,
          id: id,
        );
        id++;
        _effectsStream.sink.add(1);
        wait(item.time).then((data) {
          // we wait for the effect to run out
          setState(() {
            print("Item effect has ran out.");
            item.use(
              // we use the item as if it were equipped, this reverts the item effects
              BlocProvider.of<HeroHpBloc>(context),
              BlocProvider.of<HeroExpBloc>(context),
              BlocProvider.of<GoldBloc>(context),
              BlocProvider.of<ClickerBloc>(context),
              true,
              item.equip,
              item.behaviours
            );
          });
        });
      }
    });
  }

  void showDescription(Item item, int index, bool equipped) {
    AlertDialog description = AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text(item.name)],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/${item.id}.png"),
                )
              ],
            ),
            Text(item.description),
            MaterialButton(
              color: Colors.blueAccent,
              child: ButtonDescriptionText(equipped: equipped),
              onPressed: () {
                useItem(item, index, equipped);
                Navigator.pop(context);
              },
            )
          ],
        ));
    showDialog(
        context: context, builder: (BuildContext context) => description);
  }

  @override
  Widget build(BuildContext context) => Container(
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
                  ItemSlot(
                    item: player.equipped["weapon"],
                    equipped: true,
                    showDescription: showDescription,
                  ),
                  ItemSlot(
                    item: player.equipped["shield"],
                    equipped: true,
                    showDescription: showDescription,
                  ),
                  ItemSlot(
                    item: player.equipped["helmet"],
                    equipped: true,
                    showDescription: showDescription,
                  ),
                  ItemSlot(
                    item: player.equipped["body"],
                    equipped: true,
                    showDescription: showDescription,
                  )
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6),
                  itemCount: player.inventory.length,
                  itemBuilder: (BuildContext context, int index) => ItemSlot(
                        index: index,
                        item: items[player.inventory[index]],
                        showDescription: showDescription,
                      )),
            ],
          )
        ],
      ));
}

class ButtonDescriptionText extends StatelessWidget {
  bool equipped;
  String text;
  ButtonDescriptionText({this.equipped});

  @override
  Widget build(BuildContext context) {
    if (equipped == null) {
      text = "Use Item";
    } else if (equipped == false) {
      text = "Equip Item";
    } else {
      text = "Unequip Item";
    }
    return Text(text);
  }
}

class ItemSlot extends StatelessWidget {
  final Item item;
  final int index;
  dynamic showDescription;
  bool equipped;
  ItemSlot({this.item, this.index, this.showDescription, this.equipped});

  @override
  Widget build(BuildContext context) {
    if (item != null) {
      if (item.equip != null && equipped == null) {
        equipped = false;
      }
    }
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: () {
          if (item != null) {
            showDescription(item, index, equipped);
          }
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
            ),
            width: 60.0,
            height: 60.0,
            child: item != null
                ? Center(
                    child: Image(
                      image: AssetImage("assets/${item.id}.png"),
                    ),
                  )
                : null),
      ),
    );
  }
}

class ShopScreen extends StatelessWidget {
  final List shopItems = [
    items["redPotion"],
    items["woodSword"],
    items["atkPotion"],
    items["woodShield"],
    items["luckyCharm"],
    items["atkGem"],
    items["leatherHelmet"],
    items["commonShirt"]
  ];

  @override
  Widget build(BuildContext context) {
    final GoldBloc _goldBloc = BlocProvider.of<GoldBloc>(context);
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text("Shop")],
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: shopItems.length,
            itemBuilder: (BuildContext context, int index) => ListTile(
              leading: Image(image: AssetImage("assets/${shopItems[index].id}.png"),),
              title: Text(shopItems[index].name),
              trailing: MaterialButton(
                color: Colors.yellowAccent,
                onPressed: () {
                  if (player.gold >= shopItems[index].cost) {
                    player.gold -= shopItems[index].cost;
                    player.inventory.add(shopItems[index].id);
                    print("PLAYER INVENTORY IS" +
                        player.inventory.toString());
                    _goldBloc.dispatch(0);
                  }
                },
                child: Text("${shopItems[index].cost} Gold"),
              ),
            ))
      ],
    );
  }
}

class SkillsScreen extends StatefulWidget {
  @override
  SkillsScreenState createState() => SkillsScreenState();
}

class SkillsScreenState extends State<SkillsScreen> {

  void useSkill(Skill skill) {
    setState(() {
      skill.use(
          BlocProvider.of<HeroHpBloc>(context),
          BlocProvider.of<HeroExpBloc>(context),
          BlocProvider.of<GoldBloc>(context),
          BlocProvider.of<ClickerBloc>(context),
          false,
          null,
          skill.behaviours
      );
    });
  }

  void showDescription(Skill skill) {
    AlertDialog description = AlertDialog(
      title: Text(skill.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image(image: AssetImage("assets/skills/${skill.id}.png"),),
          Text(skill.description),
          MaterialButton(
            color: Colors.redAccent,
            child: Text("Unlock Skill"),
            onPressed: () {
              useSkill(skill);
            },
          )
        ],
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => description
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SkillTree(treeName: "strength", showDescription: showDescription),
        SkillTree(treeName: "endurance", showDescription: showDescription),
        SkillTree(treeName: "wisdom", showDescription: showDescription)
      ],
    );
  }
}

class SkillTree extends StatelessWidget {
  String treeName;
  dynamic showDescription;

  SkillTree({this.treeName, this.showDescription});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(treeName),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: skills[treeName].length,
              separatorBuilder: (BuildContext context, int index) =>
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width / 2, 20.0),
                    painter: Line(width: MediaQuery.of(context).size.width / 2),
                  ),
              itemBuilder: (BuildContext context, int index) {
                Skill currSkill = skills[treeName][index];
                return Center(
                    child: GestureDetector(
                      onTap: () {
                        showDescription(currSkill);
                      },
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                        ),
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image(image: AssetImage("assets/skills/${currSkill.id}.png")),
                        ),
                      ),
                    )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Line extends CustomPainter {
  double width;

  Line({this.width});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(width, 0.0), Offset(width, 20.0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class Effect extends StatefulWidget {
  int time;
  int id;
  String desc;

  Effect({Key key, @required this.desc, @required this.time, @required this.id})
      : super(key: key);

  @override
  EffectState createState() => EffectState();
}

class EffectState extends State<Effect> {
  @override
  Widget build(BuildContext context) {
    wait(1).then((_) {
      setState(() {
        widget.time -= 1;
        if (widget.time == 0) {
          effects.remove(widget.id);
          _effectsStream.sink.add(1);
        }
      });
    });
    return Text("${widget.desc} : ${widget.time}");
  }
}

class EffectsList extends StatefulWidget {
  List<Widget> effectsList;

  EffectsList({Key key, this.effectsList}) : super(key: key);

  @override
  EffectsListState createState() => EffectsListState();
}

class EffectsListState extends State<EffectsList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: widget.effectsList,
    );
  }
}
