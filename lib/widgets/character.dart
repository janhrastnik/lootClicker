import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs.dart';
import '../classes.dart';
import '../globals.dart';
import 'effect.dart';

class CharacterScreen extends StatefulWidget {
  CharacterScreenState createState() => CharacterScreenState();
}

class CharacterScreenState extends State<CharacterScreen> {
  @override
  void initState() {
    super.initState();
  }

  useItem(Item item, int index, bool equipped) {
    dynamic hp = BlocProvider.of<HeroHpBloc>(context);
    dynamic exp = BlocProvider.of<HeroExpBloc>(context);
    setState(() {
      if (equipped == null || equipped == false) {
        // if the item is unequipped then we remove it
        player.inventory.removeAt(index);
        if (player.equipped[item.equip] != null) {
          // we 'unequip' the current item by using it with an opposite value
          player.inventory.add(player.equipped[item.equip].id); // add it to the inventory
          player.equipped[item.equip].use( // unequip it
              hpBloc: hp,
              expBloc: exp,
              isEquipped: true,
              equip: item.equip,
              behaviours: item.behaviours,
              id: item.id
          );
        }
      } else {
        player.inventory.add(item.id);
      }

      item.use(
          hpBloc: hp,
          expBloc: exp,
          isEquipped: equipped,
          equip: item.equip,
          behaviours: item.behaviours,
          id: item.id
      );
      if (item.time != 0) { // item is a consumable with a temporary effect
        effectsStream.sink.add(Effect(
          desc: item.name,
          time: item.time,
        ));
        wait(item.time).then((data) {
          // we wait for the effect to run out
            print("Item effect has ran out. Item equip was ${item.equip}");
            print("INVENTORY IS ${player.inventory}");
            item.use(
              // we use the item as if it were equipped, this reverts the item effects
                hpBloc: hp,
                expBloc: exp,
                isEquipped: true,
                equip: item.equip,
                behaviours: item.behaviours,
                id: item.id
            );
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
                  image: AssetImage("assets/items/${item.id}.png"),
                )
              ],
            ),
            Text(item.description, style: TextStyle(
                fontFamily: "Centurion"
            ),),
            MaterialButton(
              color: Colors.blueAccent,
              child: ButtonDescriptionText(equipped: equipped),
              onPressed: () {
                useItem(item, index, equipped);
                Navigator.pop(context);
              },
            ),
            equipped != true ? MaterialButton(
              color: Colors.redAccent,
              child: Text("Discard Item"),
              onPressed: () {
                setState(() {
                  player.inventory.removeAt(index);
                  Navigator.pop(context);
                });
              },
            ) : Container()
          ],
        ));
    showDialog(
        context: context, builder: (BuildContext context) => description);
  }

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          image: DecorationImage(image: AssetImage("assets/uibackground.png"), repeat: ImageRepeat.repeat)
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("Stats"),
                      Text("HP: ${player.hp}/${player.hpCap}"),
                      Text("Attack: ${player.attack}"),
                      Text("Critical Hit Chance: ${player.criticalHitChance}"),
                      Text("Dodge Chance: ${player.dodgeChance}"),
                      Text("Intelligence: ${player.intelligence}"),
                      Text("Looting: ${player.looting}"),
                      Text("Loot Amount: ${player.lootModifierPercentage}"),
                      Text("EXP: ${player.exp}/${player.expCap}"),
                      Text("EXP Amount: ${player.expModifierPercentage}"),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text("Equipment"),
                    ),
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
                ),
              ],
            ),
          ),
          Text("Inventory"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: Stack(
                children: <Widget>[
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 6,
                    children: List.generate(24, (int index) => ItemSlot()),
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
              ),
            ),
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
            width: 55.0,
            height: 55.0,
            child: item != null
                ? Center(
              child: Image(
                image: AssetImage("assets/items/${item.id}.png"),
              ),
            )
                : null),
      ),
    );
  }
}