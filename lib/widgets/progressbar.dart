import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../globals.dart';
import '../blocs.dart';

class ProgressBar extends StatelessWidget {
  final ClickerBloc clickerBloc;

  ProgressBar(this.clickerBloc);

  String getText() {
    if (gameData.dungeonTiles[1].event.eventType == EventType.shrine) {
      return "Enter The Dungeon";
    } else if (gameData.dungeonTiles[1].event.eventType == EventType.merchant) {
      return "The merchant offers you a trade.";
    } else if (gameData.isDead) {
      return "Enter The Dungeon";
    } else {
      return "";
    }
  }

  List<dynamic> getColors() {
    if (gameData.dungeonTiles[1].event.eventType == EventType.fight) {
      return [AlwaysStoppedAnimation<Color>(Colors.red), Colors.brown];
    } else {
      return [AlwaysStoppedAnimation<Color>(Colors.blue), Colors.lightBlueAccent];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: clickerBloc,
        builder:
            (BuildContext context, double progress) {
          String eventText = getText();
          List<dynamic> colors = getColors();
          if (gameData.isDead) {
            progress = 1.0;
            gameData.isDead = false;
          }
          if (progress == 0.0) {
            progress = 1.0;
          }
          return Container(
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
                    valueColor: colors[0],
                    backgroundColor: colors[1],
                    value: progress,
                  ),
                ),
                eventText != ""
                    ? Text(eventText)
                    : Text(
                    "${gameData.dungeonTiles[1].event.length - gameData.dungeonTiles[1].event.progress} / ${gameData.dungeonTiles[1].event.length}"),
              ],
            ),
          );
        });
  }
}