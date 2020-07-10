import 'package:flutter/material.dart';
import 'widgets/effect.dart';
import 'classes.dart';
import 'dart:async';

enum FrontPanels { characterPage, shopPage, skillsPage }
enum CharacterStates { idle, attack, run }
Player player;
GameData gameData = GameData();
ScrollController scrollController = ScrollController();
AnimationController tapAnimationController;
AnimationController deathAnimationController;
AnimationController goldAnimationController;
final StreamController effectsStream = StreamController<Effect>();
final StreamController characterStream = StreamController<CharacterStates>();
final StreamController damageStream = StreamController<List<int>>();
Future wait(n) async {
  return Future.delayed(Duration(seconds: n));
}