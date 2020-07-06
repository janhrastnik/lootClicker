import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs.dart';
import '../globals.dart';

class ShopScreen extends StatelessWidget {
  final List shopItems = [
    items["redPotion"],
    items["atkPotion"],
    items["atkGem"],
    items["luckyCharm"],
    items["woodSword"],
    items["woodShield"],
    items["leatherHelmet"],
    items["commonShirt"],
    items["steelAxe"],
    items["steelDagger"],
    items["steelSword"],
    items["steelShield"],
    items["steelHelm"],
    items["steelChest"],
  ];

  @override
  Widget build(BuildContext context) {
    final GoldBloc _goldBloc = BlocProvider.of<GoldBloc>(context);
    final ActionBloc _actionBloc = BlocProvider.of<ActionBloc>(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          image: DecorationImage(image: AssetImage("assets/uibackground.png"), repeat: ImageRepeat.repeat)
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Shop"),
            )],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: shopItems.length + 1,
                  itemBuilder: (BuildContext context, int index) => index != shopItems.length ? ExpansionTile(
                    leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black54),
                        ),
                        width: 48.0,
                        height: 48.0,
                        child: Center(
                          child: Image(
                            image: AssetImage("assets/items/${shopItems[index].id}.png"),
                          ),
                        )),
                    title: Text(shopItems[index].name),
                    children: <Widget>[
                      Text(shopItems[index].description, style: TextStyle(fontFamily: "Centurion"),)
                    ],
                    trailing: MaterialButton(
                      color: Colors.white,
                      onPressed: () {
                        if (player.gold >= shopItems[index].cost && player.inventory.length < 24) {
                          // player.gold -= shopItems[index].cost;
                          player.inventory.add(shopItems[index].id);
                          print("PLAYER INVENTORY IS" +
                              player.inventory.toString());
                          _goldBloc.dispatch(-shopItems[index].cost);
                        }
                      },
                      child: Text("${shopItems[index].cost} Gold"),
                    ),
                  ) : ExpansionTile(
                      leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black54),
                          ),
                          width: 55.0,
                          height: 55.0,
                          child: Center(
                            child: Image(
                              image: AssetImage("assets/items/key.gif"),
                              width: 32.0,
                              height: 32.0,
                            ),
                          )),
                      title: Text("Dungeon Key"),
                      children: <Widget>[
                        Text("Increases Dungeon Level by 1.", style: TextStyle(fontFamily: "Centurion"),)
                      ],
                      trailing: MaterialButton(
                        color: Colors.white,
                        onPressed: () {
                          if (player.gold >= player.keyCost) {
                            _actionBloc.dispatch("dungeonKey");
                            _goldBloc.dispatch(-player.keyCost);
                          }
                        },
                        child: Text("${player.keyCost} Gold"),
                      )
                  )),
            ),
          )
        ],
      ),
    );
  }
}
