import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../globals.dart';
import '../blocs.dart';

class ProgressBar extends StatelessWidget {
  ClickerBloc clickerBloc;

  ProgressBar(this.clickerBloc);

  String getText() {
    if (dungeonTiles[1].event.eventType == "shrine") {
      return "Enter The Dungeon";
    } else if (dungeonTiles[1].event.eventType == "merchant") {
      return "The merchant offers you a trade.";
    } else if (isDead) {
      return "Enter The Dungeon";
    } else {
      return "";
    }
  }

  MaterialAccentColor getColor() {
    return Colors.lightBlueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: clickerBloc,
        builder:
            (BuildContext context, double progress) {
          String eventText = getText();
          if (isDead) {
            progress = 1.0;
            isDead = false;
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
                    backgroundColor: getColor(),
                    value: progress,
                  ),
                ),
                eventText != ""
                    ? Text(eventText)
                    : Text(
                    "${dungeonTiles[1].event.length - dungeonTiles[1].event.progress} / ${dungeonTiles[1].event.length}"),
              ],
            ),
          );
        });
  }
}