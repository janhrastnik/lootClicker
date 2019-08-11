import 'package:bloc/bloc.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'classes.dart';

Future wait(n) async {
  return Future.delayed(Duration(seconds: n));
}

class DungeonBloc extends Bloc<List<DungeonTile>, List<DungeonTile>> {
  @override
  List<DungeonTile> get initialState => dungeonTiles;
  final ActionBloc actionBloc;
  List eventTypes = ["loot", "fight", "puzzle"];

  DungeonBloc({this.actionBloc});

  DungeonTile generateDungeon() {
    int randomRange(int min, int max) => min + Random().nextInt(max - min);
    String dungeonType = eventTypes[Random().nextInt(eventTypes.length)];
    int lootAmount = (randomRange(1, 10) *
        player.lootModifierPercentage).floor() *
        player.dungeonLevel +
        player.lootModifierRaw;
    int length = randomRange(10, 20) * player.dungeonLevel;
    Enemy randomEnemy;
    if (dungeonType == "fight") {
      // generate a random enemy
      String randomEnemyType = monsters.keys.toList()[Random().nextInt(monsters.keys.toList().length)];
      randomEnemy = monsters[randomEnemyType];
      length = randomEnemy.hp * player.dungeonLevel;
    }

    return DungeonTile(event: DungeonEvent(
        eventType: dungeonType,
        length: length,
        loot: lootAmount,
        enemy: dungeonType == "fight" ? randomEnemy : null
    ));
  }

  @override
  Stream<List<DungeonTile>> mapEventToState(List<DungeonTile> event) async* {

    switch (event.length) {
      case 3:
        final List<DungeonTile> newList = List.from(event, growable: true);
        newList.add(generateDungeon());
        dungeonTiles = newList;
        yield newList;
        break;
      case 4:
        final List<DungeonTile> newList = List.from(event);
        newList.removeAt(0);
        actionBloc.dispatch(newList[1].event.eventType);
        dungeonTiles = newList;
        yield newList;
        break;
      case 0:
        final List<DungeonTile> newList = [];
        newList.add(DungeonTile(event: DungeonEvent(eventType: "wall", length: null)));
        newList.add(DungeonTile(event: DungeonEvent(eventType: "shrine", length: null)));
        newList.add(DungeonTile(event: DungeonEvent(eventType: "merchant", length: null)));
        dungeonTiles = newList;
        yield newList;
        break;
    }
  }
}

void scrollToMiddle() {
  scrollController.jumpTo(TILE_LENGTH/2);
}

Future scrollDungeon(DungeonBloc dbloc, [ClickerBloc cbloc]) async {
  progressAnimationController.forward();
  scrollToMiddle();
  dbloc.dispatch(dungeonTiles);
  await scrollController.animateTo(
      scrollController.offset + TILE_LENGTH,
      duration: Duration(seconds: 1),
      curve: Curves.ease
  );
  dbloc.dispatch(dungeonTiles);
  scrollToMiddle();
  isScrolling = false;
  progressAnimationController.reset();
  if (cbloc != null) {
    cbloc.dispatch(<DungeonTile>[]);
  }
}

class ClickerBloc extends Bloc<List<DungeonTile>, double> {
  double get initialState => 1.0;
  final GoldBloc goldBloc;
  final HeroHpBloc heroHpBloc;
  final HeroExpBloc heroExpBloc;
  final DungeonBloc dungeonBloc;
  final ActionBloc actionBloc;

  ClickerBloc({this.goldBloc, this.heroHpBloc, this.heroExpBloc, this.dungeonBloc, this.actionBloc});

  @override
  Stream<double> mapEventToState(List<DungeonTile> event) async* {

    if (event.length == 0) { // updates text
      yield 0.0;
    }

    final DungeonEvent currEvent = event[1].event;

    switch(currEvent.eventType) {
      case "fight":
        double r = Random().nextDouble();
        if (player.dodgeChance < r) { // if the player doesn't dodge
          // if the player dies
          if (currEvent.enemy.attack >= player.hp) {
            heroHpBloc.dispatch(-currEvent.enemy.attack);
            actionBloc.dispatch("death");
            await wait(3);
            yield 1;
          } else
          if (player.hp >= 0) {
            heroHpBloc.dispatch(-currEvent.enemy.attack);
          }
        }
        r = Random().nextDouble();
        if (player.criticalHitChance >= r) { // if the player lands a critical hit
          currEvent.progress = currEvent.progress + (player.attack * player.criticalHitDamage);
        } else {
          currEvent.progress = currEvent.progress + player.attack;
        }
        // if the player beats the monster
        if (currEvent.progress >= currEvent.length) {
          if (currEvent.enemy.loot != null) {
            player.inventory.add(currEvent.enemy.loot);
          }
          heroExpBloc.dispatch(currEvent.enemy.expValue);
          if (event[2].event.eventType == "fight") {
            currEvent.progress = 0;
          } else {
            currEvent.progress = event[2].event.length;
          }
          currEvent.length = event[2].event.length;
          if (isMenu == false) {
            isScrolling = true;
            await scrollDungeon(dungeonBloc);
          }
          yield 1;
        } else {
          yield 1 - (currEvent.progress / currEvent.length);
        }
        break;
      case "loot":
        currEvent.progress = currEvent.progress + player.looting;
        if (currEvent.progress >= currEvent.length) {
          currEvent.progress = 0;
          currEvent.length = event[2].event.length;
          goldBloc.dispatch(currEvent.loot);
          goldBloc.dispatch(0); // fixes bug where gold counter doesn't update
          if (isMenu == false) {
            isScrolling = true;
            await scrollDungeon(dungeonBloc);
          }
          yield 1;
        } else {
          yield 1 - (currEvent.progress / currEvent.length);
        }
        break;
      case "puzzle":
        currEvent.progress = currEvent.progress + player.intelligence;
        if (currEvent.progress >= currEvent.length) {
          currEvent.progress = 0;
          currEvent.length = event[2].event.length;
          if (isMenu == false) {
            isScrolling = true;
            await scrollDungeon(dungeonBloc);
          }
          yield 1;
        } else {
          yield 1 - (currEvent.progress / currEvent.length);
        }
        break;
      case "shrine":
        if (isMenu == false) {
          isScrolling = true;
          await scrollDungeon(dungeonBloc);
        }
        yield 2; // needs to be different than 1 otherwise doesn't yield
        break;
      case "merchant":
        if (isMenu == false) {
          isScrolling = true;
          await scrollDungeon(dungeonBloc);
          yield 1;
        }
        break;
    }
  }
}

class ActionBloc extends Bloc<String, String> {
  String get initialState => "shrine";

  @override
  Stream<String> mapEventToState(String event) async* {
    if (event == "dungeonKey") {
      player.keyCost = player.keyCost * 2;
      player.dungeonLevel++;
    }
    yield event;
  }

}

class GoldBloc extends Bloc<int, int> {
  int get initialState => player.gold;

  @override
  Stream<int> mapEventToState(int gold) async* {
    int newGold = gold;
    if (newGold != 0) {
      goldAnimationController.reset();
      goldAnimationController.value = 1.0;
      goldAnimationController.reverse();
      player.gold += newGold;
      yield newGold;
    } else {
      yield newGold;
    }
  }
}

class HeroHpBloc extends Bloc<int, double> {
  double get initialState => player.hp / player.hpCap;
  final DungeonBloc dungeonBloc;

  HeroHpBloc({this.dungeonBloc});

  @override
  Stream<double> mapEventToState(int event) async* {
    player.hp = player.hp + event;
    if (player.hp > player.hpCap) {
      player.hp = player.hpCap;
    }
    yield player.hp / player.hpCap;
    if (player.hp <= 0) {
      isDead = true;
      print("hero hp dropped to zero.");
      player.gold = (player.gold / 2).round();
      player.hp = player.hpCap;
      isScrolling = true;
      deathAnimationController.forward();
      yield 0.0;
      await wait(3);
      print("yoooo");
      deathAnimationController.value = 1.0;
      deathAnimationController.reverse();
      dungeonBloc.dispatch(<DungeonTile>[]);
      yield 1.0;
      await wait(3);
      isScrolling = false;
    }
  }
}

class HeroExpBloc extends Bloc<int, double> {
  double get initialState => player.exp / player.expCap;
  final HeroHpBloc heroHpBloc;

  HeroExpBloc({this.heroHpBloc});

  @override
  Stream<double> mapEventToState(int event) async* {
    player.exp = player.exp + (event * player.expModifierPercentage).round() + player.expModifierRaw;
    if (player.exp >= player.expCap) { // player levels up
      player.exp = 0;
      // increase stats
      player.levelUp();
      heroHpBloc.dispatch(0); // update new hp on screen
    }
    yield player.exp / player.expCap;
  }
}

class TapAnimationBloc extends Bloc<List, List> {
  List get initialState => [];

  @override
  Stream<List> mapEventToState(List event) async* {
    switch(event[2]) {
      case "fight":
        final List newList = List.from(event, growable: true);
        newList[2] = player.attack;
        yield newList;
        break;
      case "loot":
        final List newList = List.from(event, growable: true);
        newList[2] = player.looting;
        yield newList;
        break;
      case "puzzle":
        final List newList = List.from(event, growable: true);
        newList[2] = player.intelligence;
        yield newList;
        break;
    }
  }
}
