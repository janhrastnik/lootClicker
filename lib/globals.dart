import 'package:flutter/material.dart';
import 'widgets/effect.dart';
import 'classes.dart';
import 'blocs.dart';
import 'dart:async';

enum FrontPanels { characterPage, shopPage, skillsPage }
enum CharacterStates { idle, attack, run }
Player player;
GameData gameData = GameData();
ScrollController scrollController = ScrollController();
AnimationController tapAnimationController;
AnimationController deathAnimationController;
AnimationController goldAnimationController;
final StreamController<Effect> effectsStream = StreamController<Effect>();
final StreamController<CharacterStates> characterStream = StreamController<CharacterStates>();
final StreamController<List<int>> damageStream = StreamController<List<int>>();
final StreamController<List> tapAnimationStream = StreamController<List>();

Future wait(n) async {
  return Future.delayed(Duration(seconds: n));
}

void scrollToMiddle() {
  scrollController.jumpTo(gameData.tileLength/2);
}

Future scrollDungeon(DungeonBloc dungeonBloc, [PromptBloc promptBloc, ClickerBloc clickerBloc]) async {
  if (promptBloc != null) {
    promptBloc.dispatch("transition");
  }
  characterStream.sink.add(CharacterStates.run);
  gameData.isScrolling = true;
  scrollToMiddle();
  dungeonBloc.dispatch(gameData.dungeonTiles);
  await scrollController.animateTo(
      scrollController.offset + gameData.tileLength,
      duration: Duration(seconds: 1),
      curve: Curves.ease
  );
  dungeonBloc.dispatch(gameData.dungeonTiles);
  promptBloc.dispatch(gameData.dungeonTiles[2].event.eventType);
  scrollToMiddle();
  gameData.isScrolling = false;
  characterStream.sink.add(CharacterStates.idle);
  if (clickerBloc != null) {
    clickerBloc.dispatch([]);
  }
}