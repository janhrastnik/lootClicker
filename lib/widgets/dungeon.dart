import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs.dart';
import '../classes.dart';
import '../globals.dart';
import 'effect.dart';
import 'prompt.dart';

class DungeonScreen extends StatefulWidget {
  @override
  DungeonScreenState createState() => DungeonScreenState();
}

class DungeonScreenState extends State<DungeonScreen>
    with TickerProviderStateMixin {

  List getTapCoords(TapUpDetails details) {
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
    final PromptBloc _promptBloc = BlocProvider.of<PromptBloc>(context);
    final DungeonBloc _dungeonBloc = BlocProvider.of<DungeonBloc>(context);
    final ClickerBloc _clickerBloc = BlocProvider.of<ClickerBloc>(context);
    final GoldBloc _goldBloc = BlocProvider.of<GoldBloc>(context);
    final HeroHpBloc _heroHpBloc = BlocProvider.of<HeroHpBloc>(context);
    final HeroExpBloc _heroExpBloc = BlocProvider.of<HeroExpBloc>(context);
    final TapAnimationBloc _tapAnimationBloc =
    BlocProvider.of<TapAnimationBloc>(context);
    tapAnimationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    final tapAnimation =
    Tween(begin: 0.0, end: 1.0).animate(tapAnimationController);
    goldAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    final goldAnimation =
    Tween(begin: 0.0, end: 1.0).animate(goldAnimationController);
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
          _tapAnimationBloc.dispatch(getTapCoords(details)+[dungeonTiles[1].event.eventType]);
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
                          return Column(
                            children: <Widget>[
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("${player.gold}"), // TODO: fix bug where gold count doesn't update on same consecutive gold gains
                                    Image(
                                      image: AssetImage("assets/coin.gif"),
                                    )
                                  ]),
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
                          Expanded(
                            child: BlocBuilder(
                              bloc: _dungeonBloc,
                              builder: (BuildContext context,
                                  List<DungeonTile> l) {
                                return Stack( // dungeon
                                  alignment: Alignment.center,
                                  children: <Widget>[ // the dungeon list
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
                                    StreamBuilder(
                                      initialData: CharacterStates.idle,
                                      stream: characterStream.stream,
                                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                                        String characterImage;
                                        if (snapshot.data == CharacterStates.idle) {
                                          characterImage = "assets/idle.gif";
                                        } else if (snapshot.data == CharacterStates.attack) {
                                          characterImage = "assets/attack.gif";
                                        } else if (snapshot.data == CharacterStates.run) {
                                          characterImage = "assets/run.gif";
                                        }
                                        return Container( // player
                                          alignment: Alignment(-0.2, 0.0),
                                          child: Image(image: AssetImage(characterImage),
                                            width: 128.0,
                                            height: 128.0,
                                          ),
                                        );
                                      },
                                    ),
                                    BlocBuilder( // dungeon level display
                                        bloc: _promptBloc,
                                        builder: (BuildContext context, String event) => Container(
                                          child: Text(
                                            "Dungeon Level ${player.dungeonLevel}",
                                            style: TextStyle(wordSpacing: 2.0, letterSpacing: 2.0),
                                          ),
                                          alignment: Alignment(0.0, -0.7),
                                        )
                                    ),
                                    StreamBuilder( // damage animations
                                      stream: damageStream.stream,
                                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                                        AnimationController damageAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
                                        Animation<double> damageAnimation = Tween(begin: 0.0, end: 1.0).animate(deathAnimationController);
                                        return Container(
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text("test1"),
                                                Text("test2")
                                          ]),
                                        );
                                      },
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Prompt(
                        promptBloc: _promptBloc,
                        dungeonBloc: _dungeonBloc,
                        clickerBloc: _clickerBloc,
                      ),
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
          Positioned( // show current effects
            left: 0,
            top: 0,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 80.0,
                child: EffectsList()
            )
          ),
          BlocBuilder(
            bloc: _goldBloc,
            builder: (BuildContext context, int newGold) {
              return Positioned(
                  left: MediaQuery.of(context).size.width/2.2,
                  top: MediaQuery.of(context).size.height/3,
                  child: AnimatedBuilder(
                    animation: goldAnimation,
                    builder: (BuildContext context, _) {
                      return Transform(
                        transform: Matrix4.identity()..translate(0.0, -  100.0 / (1+goldAnimation.value)),
                        child: FadeTransition(
                          opacity: goldAnimation,
                          child: Text("+ $newGold", style: TextStyle(color: Colors.orangeAccent),),
                        ),
                      );
                    },
                  )
              );
            },
          )
        ],
      ),
    );
  }
}