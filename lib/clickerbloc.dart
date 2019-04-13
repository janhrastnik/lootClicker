import 'package:bloc/bloc.dart';
import 'main.dart';

class DungeonBloc extends Bloc<List<DungeonTile>, List<DungeonTile>> {
  @override
  List<DungeonTile> get initialState => [
    DungeonTile(event: DungeonEvent(eventType: "loot", length: 10)),
    DungeonTile(event: DungeonEvent(eventType: "fight", length: 10)),
    DungeonTile(event: DungeonEvent(eventType: "puzzle", length: 10))
  ];

  @override
  Stream<List<DungeonTile>> mapEventToState(List<DungeonTile> event) async* {

    switch (event.length) {
      case 3:
        final List<DungeonTile> newList = List.from(event, growable: true);
        newList.add(generateDungeon());
        yield newList;
        break;
      case 4:
        final List<DungeonTile> newList = List.from(event);
        newList.removeAt(0);
        yield newList;
        break;
    }
  }
}

class ClickerBloc extends Bloc<List<DungeonTile>, double> {
  double get initialState => 0.0;
  final GoldBloc goldBloc;

  ClickerBloc({this.goldBloc}) : assert(goldBloc != null);

  @override
  Stream<double> mapEventToState(List<DungeonTile> event) async* {
    final DungeonEvent currEvent = event[1].event;

    print(isMenu.toString());
    switch(currEvent.eventType) {
      case "fight":
        currEvent.progress++;
        if (currEvent.progress == currEvent.length) {
          currEvent.progress = 0;
          currEvent.length = event[2].event.length;
          yield -1;
        } else {
          yield currEvent.progress / currEvent.length;
        }
        break;
      case "loot":
        currEvent.progress++;
        if (currEvent.progress == currEvent.length) {
          currEvent.progress = 0;
          currEvent.length = event[2].event.length;
          goldBloc.dispatch(currEvent.loot);
          yield -1;
        } else {
          yield currEvent.progress / currEvent.length;
        }
        break;
      case "puzzle":
        currEvent.progress++;
        if (currEvent.progress == currEvent.length) {
          currEvent.progress = 0;
          currEvent.length = event[2].event.length;
          yield -1;
        } else {
          yield currEvent.progress / currEvent.length;
        }
        break;
    }
  }
}

class GoldBloc extends Bloc<int, int> {
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(int gold) async* {
    int newGold = gold;
    yield newGold;
  }
}

class HeroHpBloc extends Bloc<String, double> {
  double get initialState => 1.0;

  @override
  Stream<double> mapEventToState(String event) async* {
    yield hero.hp / hero.hpCap;
  }
}

class HeroExpBloc extends Bloc<String, double> {
  double get initialState => 0.0;

  @override
  Stream<double> mapEventToState(String event) async* {
    yield hero.exp / hero.expCap;
  }
}

class TapAnimationBloc extends Bloc<List, List> {
  List get initialState => [];

  @override
  Stream<List> mapEventToState(List event) async* {
    switch(event[2]) {
      case "fight":
        print("mate");
        final List newList = List.from(event, growable: true);
        newList[2] = hero.attack;
        yield newList;
        break;
      case "loot":
        final List newList = List.from(event, growable: true);
        newList[2] = hero.looting;
        yield newList;
        break;
      case "puzzle":
        final List newList = List.from(event, growable: true);
        newList[2] = hero.intelligence;
        yield newList;
        break;
    }
  }
}