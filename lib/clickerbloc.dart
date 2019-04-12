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

class ClickerBloc extends Bloc<DungeonEvent, double> {
  double get initialState => 0.0;
  final GoldBloc goldBloc;

  ClickerBloc({this.goldBloc}) : assert(goldBloc != null);

  @override
  Stream<double> mapEventToState(DungeonEvent event) async* {
    print(isMenu.toString());
    switch(event.eventType) {
      case "fight":
        event.progress++;
        if (event.progress == event.length) {
          yield -1;
        } else {
          yield event.progress / event.length;
        }
        break;
      case "loot":
        event.progress++;
        if (event.progress == event.length) {
          goldBloc.dispatch(event.loot);
          yield -1;
        } else {
          yield event.progress / event.length;
        }
        break;
      case "puzzle":
        event.progress++;
        if (event.progress == event.length) {
          yield -1;
        } else {
          yield event.progress / event.length;
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
    newGold = newGold + hero.gold;
    yield newGold;
  }
}

class HeroHpBloc extends Bloc<String, int> {
  int get initialState => hero.hp;

  @override
  Stream<int> mapEventToState(String event) async* {

  }
}

class HeroExpBloc extends Bloc<String, int> {
  int get initialState => hero.exp;

  @override
  Stream<int> mapEventToState(String event) async* {

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