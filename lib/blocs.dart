import 'package:bloc/bloc.dart';
import 'globals.dart';
import 'dart:math';
import 'classes.dart';

class DungeonBloc extends Bloc<List<DungeonTile>, List<DungeonTile>> {
  @override
  List<DungeonTile> get initialState => gameData.dungeonTiles;

  DungeonTile generateDungeon() {
    int randomRange(int min, int max) => min + Random().nextInt(max - min);
    EventType dungeonType = [EventType.loot, EventType.fight, EventType.puzzle][Random().nextInt(2)];
    int lootAmount = (randomRange(1, 11) *
        player.lootModifierPercentage).floor() *
        player.dungeonLevel +
        player.lootModifierRaw;
    int length = randomRange(10, 20) * player.dungeonLevel;
    Enemy randomEnemy;
    if (dungeonType == EventType.fight) {
      // generate a random enemy
      String randomEnemyType = gameData.monsters.keys.toList()[Random().nextInt(gameData.monsters.keys.toList().length)];
      randomEnemy = gameData.monsters[randomEnemyType];
      length = randomEnemy.hp * player.dungeonLevel;
    }

    return DungeonTile(event: DungeonEvent(
        eventType: dungeonType,
        length: length,
        loot: lootAmount,
        enemy: dungeonType == EventType.fight ? randomEnemy : null
    ));
  }

  @override
  Stream<List<DungeonTile>> mapEventToState(List<DungeonTile> event) async* {

    switch (event.length) {
      case 3:
        // we add the next room
        final List<DungeonTile> newList = List.from(event, growable: true);
        newList.add(generateDungeon());
        gameData.dungeonTiles = newList;
        yield newList;
        break;
      case 4:
        // we remove the passed room
        final List<DungeonTile> newList = List.from(event);
        newList.removeAt(0);
        gameData.dungeonTiles = newList;
        yield newList;
        break;
      case 0:
        // we generate the beginning
        final List<DungeonTile> newList = [];
        newList.add(DungeonTile(event: DungeonEvent(eventType: EventType.wall, length: null)));
        newList.add(DungeonTile(event: DungeonEvent(eventType: EventType.shrine, length: null)));
        newList.add(DungeonTile(event: DungeonEvent(eventType: EventType.merchant, length: null)));
        gameData.dungeonTiles = newList;
        yield newList;
        break;
    }
  }
}

class ClickerBloc extends Bloc<List<DungeonTile>, double> {
  // handle click events
  double get initialState => 1.0;
  final GoldBloc goldBloc;
  final HeroHpBloc heroHpBloc;
  final HeroExpBloc heroExpBloc;
  final DungeonBloc dungeonBloc;
  final PromptBloc promptBloc;

  ClickerBloc({this.goldBloc, this.heroHpBloc, this.heroExpBloc, this.dungeonBloc, this.promptBloc});

  @override
  Stream<double> mapEventToState(List<DungeonTile> event) async* {

    if (event.length == 0) { // updates text
      yield 0.0;
    }

    final DungeonEvent currEvent = event[1].event;

    switch(currEvent.eventType) {
      case EventType.fight:
        double randFloat = Random().nextDouble(); // TODO: rework dodging
        double dodgeRoll = Random().nextDouble();
        int damageTaken = 0;
        int damageDealt = 0;

        if (player.agility * dodgeRoll < randFloat) { // if the player doesn't dodge
          // if the player dies
          damageTaken = currEvent.enemy.attack;
          if (damageTaken >= player.hp) {
            heroHpBloc.dispatch(-damageTaken);
            promptBloc.dispatch("death");
            await wait(3);
            goldBloc.dispatch(-(player.gold/2).floor()); // updates gold counter
            promptBloc.dispatch("shrine");
            yield 1.0;
            break;
          } else {
            // player takes damage
            heroHpBloc.dispatch(-damageTaken);
          }
        }
        if (gameData.failedFlee == false) {
          randFloat = Random().nextDouble();
          if (player.criticalHitChance >= randFloat) {// if the player lands a critical hit
            damageDealt = player.attack * player.criticalHitDamage;
          } else {
            damageDealt = player.attack;
          }
        } else { // flee failed, player takes damage whilst dealing no damage
          gameData.failedFlee = false;
        }
        // display the damage
        damageStream.sink.add([damageTaken.toString(), damageDealt.toString()]);
        // progress the event
        currEvent.progress = currEvent.progress + damageDealt;
        // if the player beats the monster
        if (currEvent.progress >= currEvent.length) {
          if (currEvent.enemy.loot != null) {
            player.inventory.add(currEvent.enemy.loot);
          }
          heroExpBloc.dispatch(currEvent.enemy.expValue);
          if (event[2].event.eventType == EventType.fight) {
            currEvent.progress = 0;
          } else {
            currEvent.progress = event[2].event.length;
          }
          currEvent.length = event[2].event.length;
          if (gameData.isMenu == false) {
            await scrollDungeon(dungeonBloc, promptBloc);
          }
          yield 1;
        } else {
          print("else block gets run");
          yield 1 - (currEvent.progress / currEvent.length);
        }
        break;
      case EventType.loot:
        currEvent.progress = currEvent.progress + player.looting;
        if (currEvent.progress >= currEvent.length) {
          currEvent.progress = 0;
          currEvent.length = event[2].event.length;
          goldBloc.dispatch(currEvent.loot);
          if (gameData.isMenu == false) {
            await scrollDungeon(dungeonBloc, promptBloc);
          }
          yield 1;
        } else {
          yield 1 - (currEvent.progress / currEvent.length);
        }
        break;
      case EventType.puzzle:
        currEvent.progress = currEvent.progress + player.intelligence;
        if (currEvent.progress >= currEvent.length) {
          currEvent.progress = 0;
          currEvent.length = event[2].event.length;
          if (gameData.isMenu == false) {
            await scrollDungeon(dungeonBloc, promptBloc);
          }
          yield 1;
        } else {
          yield 1 - (currEvent.progress / currEvent.length);
        }
        break;
      case EventType.shrine:
        if (gameData.isMenu == false) {
          await scrollDungeon(dungeonBloc, promptBloc);
        }
        yield 2; // needs to be different than 1 otherwise doesn't yield
        break;
    }
  }
}

class PromptBloc extends Bloc<String, String> {
  // handle events
  String get initialState => "shrine";
  DungeonBloc dungeonBloc;

  PromptBloc({this.dungeonBloc});

  @override
  Stream<String> mapEventToState(String event) async* {
    if (event == "dungeonKey") {
      // dungeon key usage -> increases dungeon level
      player.keyCost = player.keyCost * 2;
      player.dungeonLevel++;
    } else if (event == "flee") {
      scrollDungeon(
          dungeonBloc,
          this,
      ); // updates text
    }
    yield event;
  }

}

class GoldBloc extends Bloc<int, int> {
  // used to increase player gold
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(int gold) async* {
    int newGold = gold;
    yield 0; // we must yield 0 so that the bloc builds on same consecutive gold yields
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
  // handle player hp
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
      gameData.isDead = true;
      print("hero hp dropped to zero.");
      player.hp = player.hpCap;
      gameData.isScrolling = true;
      deathAnimationController.forward();
      yield 0.0;
      await wait(3);
      deathAnimationController.value = 1.0;
      deathAnimationController.reverse();
      dungeonBloc.dispatch(<DungeonTile>[]);
      yield 1.0;
      await wait(3);
      gameData.isScrolling = false;
    }
  }
}

class HeroExpBloc extends Bloc<int, double> {
  // handle player exp
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