import 'package:flutter/material.dart';
import 'dart:math';
import 'main.dart';

class DungeonTile extends StatelessWidget {
  DungeonTile({Key key, @required this.event}) : super(key: key);

  final DungeonEvent event;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          width: MediaQuery.of(context).size.width/2,
          height: 200.0,
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/mayclover_meadow_example.png"), fit: BoxFit.cover),
              border: new Border.all(color: Colors.blueAccent)
          ),
          alignment: Alignment(0.7, 0.0),
          child: event.enemy != null ? Text(event.enemy.name) : Text(event.eventType),
        )
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return 'DungeonTile { event: $event }';
  }
}

class DungeonEvent {
  String eventType;
  int length;
  int progress;
  int loot;
  Enemy enemy;

  DungeonEvent({
    @required this.eventType,
    @required this.length,
    this.progress = 0,
    this.loot = 1,
    this.enemy
  });

  @override
  String toString() =>
      'DungeonEvent { evenType: $eventType, length: $length, progress: $progress }';
}

class Player {
  int gold;
  int hp;
  int hpCap;
  int attack;
  int looting;
  int intelligence;
  int exp;
  int expCap;
  List skills;
  List inventory;

  Player({this.gold = 0,
    this.hp = 100,
    this.hpCap = 100,
    this.attack = 1,
    this.intelligence = 1,
    this.looting = 1,
    this.exp = 0,
    this.expCap = 100,
    this.skills,
    this.inventory,
  });

  void levelUp() {
    this.hpCap = this.hpCap + 20;
    this.attack = this.attack + Random().nextInt(2);
    this.looting = this.looting + Random().nextInt(2);
    this.intelligence = this.intelligence + Random().nextInt(2);
    this.expCap = this.expCap * 2;
    this.exp = 0;
    this.hp = this.hpCap;
    print(this.hpCap);
  }
}

class Enemy {
  String name;
  int hp;
  int expValue;
  int attack;

  Enemy({
    this.name,
    this.hp,
    this.expValue,
    this.attack
  });
}

class Item {
  String name;
  Map behaviours;

  Item({
   this.name,
   this.behaviours
});

  void use() {
    behaviours.forEach((behaviour, args) {
      switch(behaviour) {
        case "increaseHp":
          increaseHp(args["value"], args["percentage"]);
      }
    });
  }

}

void increaseHp(n, percentage) {
  if (percentage) {
    player.hp += player.hpCap * (n/100);
  } else {
    player.hp += n;
  }
  if (player.hp > player.hpCap) {
    player.hp = player.hpCap;
  }
}