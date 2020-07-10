import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs.dart';
import '../globals.dart';
import '../classes.dart';

class SkillsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          image: DecorationImage(image: AssetImage("assets/uibackground.png"), repeat: ImageRepeat.repeat)
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Skill Points: ${player.skillPoints}"),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SkillTree(treeIndex: 0, treeName: "strength"),
                SkillTree(treeIndex: 1, treeName: "endurance"),
                SkillTree(treeIndex: 2, treeName: "wisdom")
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SkillTree extends StatefulWidget {
  final int treeIndex;
  final String treeName;
  final showDescription;

  SkillTreeState createState() => SkillTreeState();
  SkillTree({this.treeIndex, this.treeName, this.showDescription});
}

class SkillTreeState extends State<SkillTree> {

  void useSkill(Skill skill, int treeIndex) {
    setState(() {
      player.skillProgress[treeIndex]++;
      skill.use(
          hpBloc: BlocProvider.of<HeroHpBloc>(context),
          expBloc: BlocProvider.of<HeroExpBloc>(context),
          behaviours: skill.behaviours
      );
    });
  }

  void showDescription(Skill skill, int treeIndex, int index) {
    AlertDialog description = AlertDialog(
      title: Text(skill.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image(image: AssetImage("assets/skills/${skill.id}.png"),),
          Text(skill.description, style: TextStyle(fontFamily: "Centurion", fontSize: 12.0)),
          player.skillProgress[treeIndex] == index ? MaterialButton(
            color: Colors.blueAccent,
            child: Text("Unlock Skill"),
            onPressed: () {
              if (player.skillPoints > 0) {
                useSkill(skill, treeIndex);
                player.skillPoints--;
                Navigator.pop(context);
              }
            },
          ) : Container()
        ],
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => description
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.treeName.toUpperCase()),
          ),
          Stack(
            children: <Widget>[
              Center(
                child: Container(
                  width: 4.0,
                  height: 200.0,
                  color: Colors.black,
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: gameData.skills[widget.treeName].length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 20.0,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  Skill currSkill = gameData.skills[widget.treeName][index];
                  return Center(
                      child: GestureDetector(
                        onTap: () {
                          showDescription(currSkill, widget.treeIndex, index);
                        },
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          foregroundDecoration: player.skillProgress[widget.treeIndex] <= index ? BoxDecoration(
                              color: Colors.grey,
                              backgroundBlendMode: BlendMode.saturation
                          ) : null ,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                          ),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Image(image: AssetImage("assets/skills/${currSkill.id}.png")),
                          ),
                        ),
                      )
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}