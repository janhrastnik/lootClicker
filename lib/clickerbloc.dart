import 'main.dart';
import 'package:bloc/bloc.dart';
import 'dart:math';

class ClickerBloc extends Bloc<DungeonEvent, double> {
  double get initialState => 0.0;

  Stream<double> mapEventToState(DungeonEvent event) async* {
    print(event.eventType);
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

class DungeonBloc extends Bloc<List<DungeonTile>, List<DungeonTile>> {
  int r = Random().nextInt(eventTypes.length);

  @override
  List<DungeonTile> get initialState => [
    DungeonTile(event: DungeonEvent(eventType: "loot", length: 10)),
    DungeonTile(event: DungeonEvent(eventType: "fight", length: 10)),
    DungeonTile(event: DungeonEvent(eventType: "puzzle", length: 10))
  ];

  @override
  Stream<List<DungeonTile>> mapEventToState(List<DungeonTile> event) async* {
    switch(event.length) {
      case 3:
        final List newList = List.from(event, growable: true);
        newList.add(DungeonTile(event: DungeonEvent(eventType: eventTypes[r], length: 10)));
        yield newList;
        break;
      case 4:
        final List newList = List.from(event);
        newList.removeAt(0);
        yield newList;
        break;
    }
  }

}