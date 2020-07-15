import 'package:flutter/material.dart';
import 'widgets/effect.dart';
import 'classes.dart';
import 'blocs.dart';
import 'dart:async';

enum FrontPanel { characterPage, shopPage, skillsPage }
enum CharacterState { idle, attack, run }
enum EventType { wall, shrine, merchant, fight, loot, puzzle }
Player player;
GameData gameData = GameData();
ScrollController scrollController = ScrollController();
AnimationController tapAnimationController;
AnimationController deathAnimationController;
AnimationController goldAnimationController;
final StreamController<Effect> effectsStream = StreamController<Effect>();
final StreamController<CharacterState> characterStream = StreamController<CharacterState>();
final StreamController<List<String>> damageStream = StreamController<List<String>>();
final StreamController<List> tapAnimationStream = StreamController<List>();

Future wait(n) async {
  return Future.delayed(Duration(seconds: n));
}

void scrollToMiddle() {
  scrollController.jumpTo(gameData.tileLength/2);
}

Future scrollDungeon(DungeonBloc dungeonBloc, [PromptBloc promptBloc]) async {
  if (promptBloc != null) {
    promptBloc.dispatch("transition");
  }
  characterStream.sink.add(CharacterState.run);
  gameData.isScrolling = true;
  scrollToMiddle();
  dungeonBloc.dispatch(gameData.dungeonTiles);
  await scrollController.animateTo(
      scrollController.offset + gameData.tileLength,
      duration: Duration(seconds: 1),
      curve: Curves.ease
  );
  dungeonBloc.dispatch(gameData.dungeonTiles);
  promptBloc.dispatch(gameData.dungeonTiles[2].event.eventType.toString());
  scrollToMiddle();
  gameData.isScrolling = false;
  characterStream.sink.add(CharacterState.idle);
}