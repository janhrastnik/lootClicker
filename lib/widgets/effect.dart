import 'package:flutter/material.dart';
import 'package:lootclicker/globals.dart';

class Effect extends StatefulWidget {
  final int time;
  final String desc;

  Effect({Key key, @required this.desc, @required this.time})
      : super(key: key);

  @override
  EffectState createState() => EffectState();
}

class EffectState extends State<Effect> {
  @override
  Widget build(BuildContext context) {
    return Text("${widget.desc} : ${widget.time}");
  }
}

class EffectsList extends StatefulWidget {
  @override
  EffectsListState createState() => EffectsListState();
}

class EffectsListState extends State<EffectsList> {
  List<Effect> effectsList = List();

  updateList() {

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: effectsStream.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          effectsList.add(snapshot.data);
        }
        return ListView.builder(
            itemCount: effectsList.length,
            itemBuilder: (BuildContext context, int index) => ListTile(
              title: Text(effectsList[index].toString()),
            )
        );
      },
    );
  }
}