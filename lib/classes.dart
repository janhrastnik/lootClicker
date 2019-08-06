import 'package:flutter/material.dart';
import 'dart:math';
import 'main.dart';
import 'package:json_annotation/json_annotation.dart';

part 'classes.g.dart';

class DungeonTile extends StatelessWidget {
  DungeonTile({Key key, @required this.event}) : super(key: key);

  final DungeonEvent event;
  String img;

  @override
  Widget build(BuildContext context) {
    if (event.eventType == "fight") {
      img = event.enemy.name;
    } else {
      img = event.eventType;
    }
    return Center(
        child: Container(
            width: MediaQuery.of(context).size.width/2,
            height: 200.0,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/dungeon2.gif"), fit: BoxFit.cover),
            ),
            alignment: Alignment(0.8, 0.4),
            child:  Image(image: AssetImage("assets/$img.gif"), width: 96.0, height: 96.0)
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

@JsonSerializable()
class Player {
  int gold;
  int hp;
  int hpCap;
  int attack;
  int looting;
  int intelligence;
  int exp;
  int expCap;
  int expModifierRaw;
  int lootModifierRaw;
  int skillPoints;
  int criticalHitDamage;
  int dungeonLevel;
  List skillProgress;
  double expModifierPercentage;
  double lootModifierPercentage;
  double criticalHitChance;
  double dodgeChance;
  List inventory;
  Map<dynamic, dynamic> equipped;
  bool bloodSteal;

  Player({this.gold = 0,
    this.hp = 100,
    this.hpCap = 100,
    this.attack = 1,
    this.intelligence = 1,
    this.looting = 1,
    this.exp = 0,
    this.expCap = 100,
    this.expModifierRaw = 0,
    this.lootModifierRaw = 0,
    this.expModifierPercentage = 1.00,
    this.lootModifierPercentage = 1.00,
    this.criticalHitDamage = 2,
    this.criticalHitChance = 0.01,
    this.dodgeChance = 0.01,
    this.inventory,
    this.equipped,
    this.bloodSteal = false,
    this.skillPoints = 2,
    this.skillProgress,
    this.dungeonLevel = 1
  });

  factory Player.fromJson(Map<String, dynamic> json)  => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  void levelUp() {
    this.hpCap = (this.hpCap * 1.2).floor();
    this.attack = this.attack + Random().nextInt(2);
    this.looting = this.looting + Random().nextInt(2);
    this.intelligence = this.intelligence + Random().nextInt(2);
    this.exp = 0;
    this.hp = this.hpCap;
    this.expCap = (this.expCap * 2).ceil();
    this.skillPoints++;
  }
}

class Enemy {
  String name;
  String loot;
  int hp;
  int expValue;
  int attack;

  Enemy({
    this.name,
    this.loot,
    this.hp,
    this.expValue,
    this.attack
  });
}

class Usable {

  void use(hpBloc, expBloc, clickBloc, goldBloc, equipped, equip, behaviours, id) {
    print(equip);
    print(equipped);
    print(behaviours);
    if (equipped != null) {
      if (equipped == false) {// if item isn't equipped then equip it
        player.equipped[equip] = items[id];
        print("player.equipped is " + player.equipped.toString());
        print("ITEMS ID IS " + items[id].toString());
      } else { // if item is equipped then unequip it
        player.equipped[equip] = null;
      }
    }
    behaviours.forEach((behaviour, args) {
      // if item is equip, then reverse the value to 'unequip' it
      switch(behaviour) {
        case "changeHp":
          changeHp(equipped == true ? 0 - args["value"] : args["value"], args["percentage"], hpBloc);
          break;
        case "changeAttack":
          changeAttack(equipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeHpCap":
          changeHpCap(equipped == true ? 0 - args["value"] : args["value"], args["percentage"], hpBloc);
          break;
        case "changeLoot":
          changeLoot(equipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeIntelligence":
          changeIntelligence(equipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeExpGain":
          changeExpGain(equipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeCriticalHitChance":
          changeCriticalHitChance(equipped == true ? 0 - args["value"] : args["value"]);
          break;
        case "changeCriticalHitDamage":
          changeCriticalHitDamage(equipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeDodgeChance":
          changeDodgeChance(equipped == true ? 0 - args["value"] : args["value"]);
          break;
      }
    });
  }

  void changeHp(n, percentage, hpBloc) {
    if (percentage) {
      hpBloc.dispatch((player.hpCap * (n/100)).ceil());
    } else {
      hpBloc.dispatch(n);
    }
  }

  void changeHpCap(n, percentage, hpBloc) {
    if (percentage) {
      player.hpCap = (player.hpCap * (1 + n/100)).floor();
      hpBloc.dispatch(0); // refreshes hp bar
    } else {
      player.hpCap += n;
      hpBloc.dispatch(0);
    }
  }

  void changeAttack(n, percentage) {
    if (percentage) {
      player.attack = (player.attack * (1 + n/100)).floor();
    } else {
      player.attack += n;
    }
  }

  void changeIntelligence(n, percentage) {
    if (percentage) {
      player.intelligence = (player.intelligence * (1 + n/100)).floor();
    } else {
      player.intelligence += n;
    }
  }

  void changeLooting() {

  }

  void changeLoot(n, percentage) {
    if (percentage) {
      player.lootModifierPercentage += (n/100);
    } else {
      player.lootModifierRaw += n;
    }
  }

  void changeDodgeChance(n) {
    player.dodgeChance += n;
  }

  void changeCriticalHitChance(n) {
    player.criticalHitChance += n;
  }

  void changeCriticalHitDamage(n, percentage) {
    if (percentage) {
      player.criticalHitDamage = (player.criticalHitDamage * (1 + n/100)).floor();
    } else {
      player.criticalHitDamage += n;
    }
  }

  void changeExpGain(n, percentage) {
    if (percentage) {
      player.expModifierPercentage += (n/100);
    } else {
      player.expModifierRaw += n;
    }
  }
}

@JsonSerializable()
class Item extends Usable {
  String name;
  String id;
  Map behaviours;
  String equip;
  String description;
  int cost;
  int time;

  Item({
    this.name,
    this.id,
    this.behaviours,
    this.equip,
    this.description,
    this.cost,
    this.time,
  });

  factory Item.fromJson(Map<String, dynamic> json)  => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

class Skill extends Usable {
  String name;
  String id;
  String description;
  Map behaviours;

  Skill({
    this.name,
    this.id,
    this.description,
    this.behaviours
  });
}