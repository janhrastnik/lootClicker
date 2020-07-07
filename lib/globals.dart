import 'package:flutter/material.dart';
import 'widgets/effect.dart';
import 'classes.dart';
import 'dart:async';

enum FrontPanels { characterPage, shopPage, skillsPage }
enum CharacterStates { idle, attack, run }
Player player;
bool isMenu = false;
bool isScrolling = false;
bool isDead = false;
double tileLength;
List<DungeonTile> dungeonTiles = [
    DungeonTile(event: DungeonEvent(eventType: "wall", length: null)),
    DungeonTile(event: DungeonEvent(eventType: "shrine", length: null)),
    DungeonTile(event: DungeonEvent(eventType: "merchant", length: null))
];
ScrollController scrollController = ScrollController();
AnimationController tapAnimationController;
AnimationController deathAnimationController;
AnimationController goldAnimationController;
Map monsters = {};
Map items = {};
Map skills = {"strength" : [], "endurance": [], "wisdom": []};
List assetNames = [];
final StreamController effectsStream = StreamController<Effect>();
final StreamController characterStream = StreamController<CharacterStates>();
final StreamController damageStream = StreamController<List<int>>();
Future wait(n) async {
  return Future.delayed(Duration(seconds: n));
}