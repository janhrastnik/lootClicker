import 'package:flutter/material.dart';

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
  final List<Effect> effectsList;

  EffectsList({Key key, this.effectsList}) : super(key: key);

  @override
  EffectsListState createState() => EffectsListState();
}

class EffectsListState extends State<EffectsList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: widget.effectsList,
    );
  }
}