import 'package:flutter/material.dart';
import '../globals.dart';
import '../classes.dart';
import '../blocs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

class Merchant extends StatelessWidget {
  List<Item> merchantItems = [items["apple"], items["tomato"], items["meat"]];
  ClickerBloc clickerBloc;
  DungeonBloc dungeonBloc;
  PromptBloc promptBloc;

  Merchant(this.dungeonBloc, this.clickerBloc, this.promptBloc);

  @override
  Widget build(BuildContext context) {
    Item randomItem = merchantItems[Random().nextInt(merchantItems.length)];
    ClickerBloc _clickerBloc = BlocProvider.of<ClickerBloc>(context);
    final GoldBloc _goldBloc = BlocProvider.of<GoldBloc>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Stack(
          children: <Widget>[
            Image(
              width: double.infinity,
              height: double.infinity,
              image: AssetImage("assets/uibackground.png"), repeat: ImageRepeat.repeat,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black54),
                      ),
                      width: 48.0,
                      height: 48.0,
                      child: Image(image: AssetImage("assets/items/${randomItem.id}.png"), width: 32.0, height: 32.0,)),
                  title: Text(randomItem.name),
                ),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      child: Text(
                        randomItem.description,
                        style: TextStyle(fontFamily: "Centurion", fontSize: 12.0),
                      )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        color: Colors.blueAccent,
                        child: Text("Buy (${randomItem.cost} Gold)"),
                        onPressed: () {
                          if (player.gold >= randomItem.cost) {
                            player.inventory.add(randomItem.id);
                            print("PLAYER INVENTORY IS" + player.inventory.toString());
                            _goldBloc.dispatch(-randomItem.cost);
                            _clickerBloc.dispatch(dungeonTiles);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        color: Colors.redAccent,
                        child: Text("Leave"),
                        onPressed: () {
                          scrollDungeon(
                              dungeonBloc,
                              promptBloc
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}