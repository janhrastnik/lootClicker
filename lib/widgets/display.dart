import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs.dart';
import '../classes.dart';
import '../globals.dart';

class Display extends StatelessWidget {
  final DungeonBloc dungeonBloc;
  final PromptBloc promptBloc;
  Display({this.dungeonBloc, this.promptBloc});

  @override
  Widget build(BuildContext context) {
    return Stack(
      // dungeon
      alignment: Alignment.center,
      children: <Widget>[
        // the dungeon list
        BlocBuilder(
          bloc: dungeonBloc,
          builder: (BuildContext context, List<DungeonTile> dungeonTiles) {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: scrollController,
              padding: EdgeInsets.all(0.0),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: dungeonTiles.length,
              itemBuilder: (BuildContext context, int index) =>
                  dungeonTiles[index],
            );
          },
        ),
        StreamBuilder(
          initialData: CharacterState.idle,
          stream: characterStream.stream,
          builder: (BuildContext context, AsyncSnapshot<CharacterState> snapshot) {
            String characterImage;
            if (snapshot.data == CharacterState.idle) {
              characterImage = "assets/idle.gif";
            } else if (snapshot.data == CharacterState.attack) {
              characterImage = "assets/attack.gif";
            } else if (snapshot.data == CharacterState.run) {
              characterImage = "assets/run.gif";
            }
            return Container(
              // player
              alignment: Alignment(-0.2, 0.0),
              child: Image(
                image: AssetImage(characterImage),
                width: 128.0,
                height: 128.0,
              ),
            );
          },
        ),
        BlocBuilder(
            // dungeon level display
            bloc: promptBloc,
            builder: (BuildContext context, String event) => Container(
                  child: Text(
                    "Dungeon Level ${player.dungeonLevel}",
                    style: TextStyle(wordSpacing: 2.0, letterSpacing: 2.0),
                  ),
                  alignment: Alignment(0.0, -0.7),
                )),
        DamageDisplay()
      ],
    );
  }
}

class DamageDisplay extends StatefulWidget {
  DamageDisplayState createState() => DamageDisplayState();
}

class DamageDisplayState extends State<DamageDisplay>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // damage animations
      stream: damageStream.stream,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        AnimationController damageAnimationController = AnimationController(
            vsync: this, duration: Duration(milliseconds: 1000));
        if (snapshot.hasData && !gameData.isMenu) {
          List damageValues = snapshot.data;
          if (damageValues[0] == "0") {
            damageValues[0] = "Dodged!";
          }
          Animation<double> damageAnimation =
          Tween(begin: 1.0, end: 0.0).animate(damageAnimationController);
          damageAnimationController.forward();
          print("stream builder gets run");
          return AnimatedBuilder(
            animation: damageAnimation,
            builder: (BuildContext context, _) {
              return Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, -50.0 / (1 + damageAnimation.value)),
                child: FadeTransition(
                    opacity: damageAnimation,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("- ${damageValues[0]}", style: TextStyle(color: Colors.red)),
                          Text("- ${damageValues[1]}", style: TextStyle(color: Colors.red))
                        ])),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
