import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs.dart';
import '../globals.dart';
import 'effect.dart';
import 'display.dart';
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
      gameData.tileLength = MediaQuery.of(context).size.width / 2;
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
        if (!gameData.isScrolling &&
            gameData.dungeonTiles[1].event.eventType != "fight" &&
            gameData.dungeonTiles[1].event.eventType != "merchant") {
          _clickerBloc.dispatch(gameData.dungeonTiles);
        }
      },
      onTapUp: (TapUpDetails details) {
        if (!gameData.isScrolling &&
            gameData.dungeonTiles[1].event.eventType != "fight" &&
            gameData.dungeonTiles[1].event.eventType != "merchant") {
          _tapAnimationBloc.dispatch(
              getTapCoords(details) + [gameData.dungeonTiles[1].event.eventType]);
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
                repeat: ImageRepeat.repeat,
                image: AssetImage("assets/backgroundbrick.png"),
              )),
            ],
          ),
          Column(
            children: <Widget>[
              Stack(
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
                                      Text(
                                          "${player.gold}"),
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
                                    width: MediaQuery.of(context).size.width /
                                        1.10,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
                                    height: 20.0,
                                    child: LinearProgressIndicator(
                                      value: value,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.red),
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
                              padding: EdgeInsets.only(
                                  top: 4.0, left: 4.0, right: 4.0, bottom: 4.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width /
                                        1.10,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
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
                    ],
                  )
                ],
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: Display(
                        dungeonBloc: _dungeonBloc,
                        promptBloc: _promptBloc,
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
          BlocBuilder(
              // show tap animation
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
          BlocBuilder(
              // death animation
              bloc: _promptBloc,
              builder: (BuildContext context, String prompt) {
                if (!gameData.isDead) {
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
              // show current effects
              left: 0,
              top: 0,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80.0,
                  child: EffectsList())),
          BlocBuilder(
            bloc: _goldBloc,
            builder: (BuildContext context, int newGold) {
              return newGold > 0 ? Positioned(
                  left: MediaQuery.of(context).size.width / 2.2,
                  top: MediaQuery.of(context).size.height / 3,
                  child: AnimatedBuilder(
                    animation: goldAnimation,
                    builder: (BuildContext context, _) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..translate(0.0, -100.0 / (1 + goldAnimation.value)),
                        child: FadeTransition(
                          opacity: goldAnimation,
                          child: Text(
                            "+ $newGold",
                            style: TextStyle(color: Colors.orangeAccent),
                          ),
                        ),
                      );
                    },
                  )) : Container();
            },
          )
        ],
      ),
    );
  }
}
