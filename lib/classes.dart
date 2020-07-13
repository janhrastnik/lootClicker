import 'package:flutter/material.dart';
import 'dart:math';
import 'globals.dart';
import 'package:json_annotation/json_annotation.dart';

part 'classes.g.dart';

class DungeonTile extends StatelessWidget {
  DungeonTile({Key key, @required this.event}) : super(key: key);

  final DungeonEvent event;

  @override
  Widget build(BuildContext context) {
    String img;
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
          alignment: img != "skeleton" ? Alignment(0.8, 0.4) : Alignment(0.8, 0.3),
          child:  Image(image: AssetImage("assets/$img.gif"), width: 96.0, height: 96.0)
      ),
    );
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
  int keyCost;
  List skillProgress;
  double expModifierPercentage;
  double lootModifierPercentage;
  double criticalHitChance;
  int agility;
  List inventory;
  Map<dynamic, dynamic> equipped;
  bool bloodSteal;

  Player({this.gold = 0,
    this.hp = 5,
    this.hpCap = 5,
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
    this.agility = 1,
    this.inventory,
    this.equipped,
    this.bloodSteal = false,
    this.skillPoints = 0,
    this.skillProgress,
    this.dungeonLevel = 1,
    this.keyCost = 500
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
  String displayName;
  String name;
  String loot;
  int hp;
  int expValue;
  int attack;
  int agility;
  double lootChance;

  Enemy({
    this.name,
    this.displayName,
    this.loot,
    this.hp,
    this.expValue,
    this.attack,
    this.agility,
    this.lootChance
  });
}

class Usable {

  use({hpBloc, expBloc, bool isEquipped, equip, behaviours, id}) {
    print(equip);
    print(isEquipped);
    print(behaviours);
    if (isEquipped != null) {
      if (isEquipped == false) {// if item isn't equipped then equip it
        player.equipped[equip] = gameData.items[id];
        print("player.equipped is " + player.equipped.toString());
        print("ITEMS ID IS " + gameData.items[id].toString());
      } else if (equip != null) { // if item is equipped then unequip it
        player.equipped[equip] = null;
      }
    }
    behaviours.forEach((behaviour, args) {
      // if item is equipped, then reverse the value to 'unequip' it
      switch(behaviour) {
        case "changeHp":
          changeHp(isEquipped == true ? 0 - args["value"] : args["value"], args["percentage"], hpBloc);
          break;
        case "changeAttack":
          changeAttack(isEquipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeHpCap":
          changeHpCap(isEquipped == true ? 0 - args["value"] : args["value"], args["percentage"], hpBloc);
          break;
        case "changeLoot":
          changeLoot(isEquipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeIntelligence":
          changeIntelligence(isEquipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeExpGain":
          changeExpGain(isEquipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeCriticalHitChance":
          changeCriticalHitChance(isEquipped == true ? 0 - args["value"] : args["value"]);
          break;
        case "changeCriticalHitDamage":
          changeCriticalHitDamage(isEquipped == true ? 0 - args["value"] : args["value"], args["percentage"]);
          break;
        case "changeAgility":
          changeAgility(isEquipped == true ? 0 - args["value"] : args["value"]);
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

  void changeAgility(n) {
    player.agility += n;
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
  String equip; // the equip slot
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

class GameData {
  bool isMenu = false;
  bool isScrolling = false;
  bool isDead = false;
  bool failedFlee;
  double tileLength;
  List<DungeonTile> dungeonTiles = [
    DungeonTile(event: DungeonEvent(eventType: "wall", length: null)),
    DungeonTile(event: DungeonEvent(eventType: "shrine", length: null)),
    DungeonTile(event: DungeonEvent(eventType: "merchant", length: null))
  ];
  Map monsters = {};
  Map items = {};
  Map skills = {"strength" : [], "endurance": [], "wisdom": []};
  List assetNames = [];

  static final GameData _singleton = GameData._internal();

  factory GameData() {
    return _singleton;
  }

  GameData._internal();
}