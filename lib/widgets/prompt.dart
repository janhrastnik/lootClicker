import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'progressbar.dart';
import '../blocs.dart';
import '../globals.dart';
import 'merchant.dart';

class Prompt extends StatelessWidget {
  final PromptBloc promptBloc;
  final ClickerBloc clickerBloc;
  final DungeonBloc dungeonBloc;

  Prompt({this.promptBloc, this.clickerBloc, this.dungeonBloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: promptBloc,
        builder: (BuildContext context, String event) {
          if (event == "fight") { // show fight prompt
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(dungeonTiles[1].event.enemy.displayName),
                ),
                ProgressBar(clickerBloc),
                Expanded(
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: 95.0,
                        height: 95.0,
                        decoration: BoxDecoration(
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
                              clickerBloc.dispatch(dungeonTiles);
                              characterStream.sink.add(CharacterStates.attack);
                              wait(1).then((value) => characterStream.sink.add(CharacterStates.idle));
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 95.0,
                        height: 95.0,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black54)
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
                            if (!isScrolling) {
                              scrollDungeon(
                                  dungeonBloc,
                                  promptBloc,
                                  clickerBloc
                              ); // updates text
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (event == "merchant") {
            return Column(
              children: <Widget>[
                ProgressBar(clickerBloc),
                Expanded(
                  child: Merchant(dungeonBloc, clickerBloc, promptBloc),
                )
              ],
            );
          } else if (event == "transition" || event == "death") {
            return Container();
          } else {
            return ProgressBar(clickerBloc);
          }
        });
  }
}