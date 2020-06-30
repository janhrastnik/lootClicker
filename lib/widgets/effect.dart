import 'package:flutter/material.dart';
import '../globals.dart';

class Effect extends StatefulWidget {
  final int time;
  final int id;
  final String desc;

  Effect({Key key, @required this.desc, @required this.time, @required this.id})
      : super(key: key);

  @override
  EffectState createState() => EffectState();
}

class EffectState extends State<Effect> {
  @override
  Widget build(BuildContext context) {
    int remainingTime = widget.time;
    wait(1).then((_) {
      setState(() {
        remainingTime -= 1;
        if (remainingTime == 0) {
          effects.remove(widget.id);
          effectsStream.sink.add(1);
        }
      });
    });
    return Text("${widget.desc} : ${widget.time}");
  }
}

class EffectsList extends StatefulWidget {
  final List<Widget> effectsList;

  EffectsList({Key key, this.effectsList}) : super(key: key);

  @override
  EffectsListState createState() => EffectsListState();
}

class EffectsListState extends State<EffectsList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: widget.effectsList,
    );
  }
}