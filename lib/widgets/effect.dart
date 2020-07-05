import 'package:flutter/material.dart';
import '../globals.dart';

class Effect {
  int time; // in seconds
  final String desc;
  dynamic behaviours;

  Effect({@required this.desc, @required this.time});
}

class EffectsList extends StatefulWidget {
  @override
  EffectsListState createState() => EffectsListState();
}

class EffectsListState extends State<EffectsList> {
  List<Effect> effectsList = List();

  removeFromList(Effect effect) {
    setState(() {
      print("update list gets called");
      print(effectsList);
      effectsList.remove(effect);
      print(effectsList);
    });
  }

  addToList(Effect effect) {
    setState(() {
      effectsList.add(effect);
    });
  }

  Future waitForEffectEnd(int time) async {
    await wait(time);
    return 1;
  }

  @override
  void initState() {
    super.initState();
    effectsStream.stream.listen((event) {
      addToList(event);
      waitForEffectEnd(event.time).then((_) {
        removeFromList(event);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: effectsList.length,
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: Text(effectsList[index].desc.toString()),
        )
    );
  }
}