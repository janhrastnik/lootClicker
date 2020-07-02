import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs.dart';
import '../classes.dart';
import '../globals.dart';
import 'effect.dart';
import 'merchant.dart';

class DungeonScreen extends StatefulWidget {
  @override
  DungeonScreenState createState() => DungeonScreenState();
}

class DungeonScreenState extends State<DungeonScreen>
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
      tileLength = MediaQuery.of(context).size.width / 2;
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!isScrolling &&
            dungeonTiles[1].event.eventType != "fight" &&
            dungeonTiles[1].event.eventType != "merchant") {
          _clickerBloc.dispatch(dungeonTiles);
        }
      },
      onTapUp: (TapUpDetails details) {
        if (!isScrolling &&
            dungeonTiles[1].event.eventType != "fight"&&
            dungeonTiles[1].event.eventType != "merchant") {
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
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: Image(
                    width: double.infinity,
                    height: double.infinity,
                    repeat: ImageRepeat.repeat, image: AssetImage("assets/backgroundbrick.png"),
                  )
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Column(children: <Widget>[
                    BlocBuilder(
                        bloc: _goldBloc,
                        builder: (BuildContext context, int newGold) {
                          if (newGold != 0) {
                            _goldBloc.dispatch(0);
                          }
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
                              newGold != 0 ? FadeTransition(
                                opacity: goldAnimation,
                                child: Text(
                                  "${newGold > -1 ? "+" : ""} " + newGold.toString(),
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ) : Container()
                            ],
                          );
                        }),
                    BlocBuilder(
                        bloc: _heroHpBloc,
                        builder: (BuildContext context, double value) {
                          print("VALUE IS " + value.toString());
                          return Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width / 1.10,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)
                                  ),
                                  height: 20.0,
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
                            ),
                          );
                        }),
                    BlocBuilder(
                        bloc: _heroExpBloc,
                        builder: (BuildContext context, double value) {
                          return Padding(
                            padding: EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0, bottom: 4.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width / 1.10,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)
                                  ),
                                  height: 20.0,
                                  child: LinearProgressIndicator(
                                    value: value,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green),
                                    backgroundColor: Colors.lightGreenAccent,
                                  ),
                                ),
                                Text("${player.exp} / ${player.expCap} EXP")
                              ],
                            ),
                          );
                        }),
                  ],)
                ],
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: Column(
                        children: <Widget>[
                          Flexible( // dungeon tile listview
                            flex: 2,
                            child: BlocBuilder(
                              bloc: _dungeonBloc,
                              builder: (BuildContext context,
                                  List<DungeonTile> l) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      controller: scrollController,
                                      padding: EdgeInsets.all(0.0),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: l.length,
                                      itemBuilder:
                                          (BuildContext context, int index) =>
                                      l[index],
                                    ),
                                    Container(
                                      alignment: Alignment(-0.2, 0.0),
                                      child: Image(image: AssetImage("assets/idle.gif"),
                                        width: 128.0,
                                        height: 128.0,
                                      ),
                                    ),
                                    BlocBuilder(
                                        bloc: _actionBloc,
                                        builder: (BuildContext context, String event) => Container(
                                          child: Text(
                                            "Dungeon Level ${player.dungeonLevel}",
                                            style: TextStyle(wordSpacing: 2.0, letterSpacing: 2.0),
                                          ),
                                          alignment: Alignment(0.0, -0.7),
                                        )
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                          Flexible(
                            flex: 0,
                            child: BlocBuilder(
                                bloc: _clickerBloc,
                                builder:
                                    (BuildContext context, double progress) {
                                  String eventText = "";
                                  if (dungeonTiles[1].event.eventType ==
                                      "shrine") {
                                    eventText = "Enter The Dungeon";
                                  }
                                  else if (dungeonTiles[1].event.eventType ==
                                      "merchant") {
                                    eventText = "The merchant offers you a trade.";
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
                                            width: MediaQuery.of(context).size.width / 1.10,
                                            height: 30.0,
                                            child: LinearProgressIndicator(
                                              value: progress,
                                            ),
                                          ),
                                          eventText != ""
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
                    Flexible(
                      flex: 2,
                      child: BlocBuilder(
                          bloc: _actionBloc,
                          builder: (BuildContext context, String event) {
                            if (event == "fight") { // show fight prompt
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                        width: 95.0,
                                        height: 95.0,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12.0),
                                            color: Colors.white
                                        ),
                                        child: MaterialButton(
                                          child: Center(child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: 64.0,
                                                height: 64.0,
                                                child: FittedBox(
                                                  fit: BoxFit.fill,
                                                  child: Image(image: AssetImage("assets/attack.png")),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Text("Attack"),
                                              )
                                            ],
                                          )),
                                          onPressed: () {
                                            if (!isScrolling) {
                                              _clickerBloc.dispatch(dungeonTiles);
                                            }
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 95.0,
                                        height: 95.0,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12.0),
                                            color: Colors.white
                                        ),
                                        child: MaterialButton(
                                          child: Center(child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: 64.0,
                                                height: 64.0,
                                                child: FittedBox(
                                                  fit: BoxFit.fill,
                                                  child: Image(image: AssetImage("assets/flee.png")),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Text("Flee"),
                                              )
                                            ],
                                          )),
                                          onPressed: () {
                                            scrollDungeon(_dungeonBloc,
                                                _clickerBloc); // updates text
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else if (event == "merchant") {
                              return Merchant();
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
          BlocBuilder( // show tap animation
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
          BlocBuilder( // death animation
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
          StreamBuilder(
              initialData: 0,
              stream: effectsStream.stream,
              builder:
                  (BuildContext context, AsyncSnapshot snapshot) {
                print("EFFECTS: " + effects.toString());
                print(snapshot.data);
                if (!snapshot.hasData) {
                  return Container();
                } else if (snapshot.data == 0) {
                  return Container();
                } else {
                  return EffectsList(
                      effectsList: effects.values.toList());
                }
              })
        ],
      ),
    );
  }
}