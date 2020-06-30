import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs.dart';
import '../globals.dart';
import '../classes.dart';

class SkillsScreen extends StatefulWidget {
  @override
  SkillsScreenState createState() => SkillsScreenState();
}

class SkillsScreenState extends State<SkillsScreen> {

  void useSkill(Skill skill, int treeIndex) {
    setState(() {
      player.skillProgress[treeIndex]++;
      skill.use(
          BlocProvider.of<HeroHpBloc>(context),
          BlocProvider.of<HeroExpBloc>(context),
          BlocProvider.of<GoldBloc>(context),
          BlocProvider.of<ClickerBloc>(context),
          null,
          null,
          skill.behaviours,
          null
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
            child: Text("Unlock Skill", ),
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
                SkillTree(treeIndex: 0, treeName: "strength", showDescription: showDescription),
                SkillTree(treeIndex: 1, treeName: "endurance", showDescription: showDescription),
                SkillTree(treeIndex: 2, treeName: "wisdom", showDescription: showDescription)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SkillTree extends StatelessWidget {
  final int treeIndex;
  final String treeName;
  final showDescription;

  SkillTree({this.treeIndex, this.treeName, this.showDescription});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(treeName.toUpperCase()),
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: skills[treeName].length,
              separatorBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    CustomPaint(
                      size: Size(MediaQuery.of(context).size.width / 2, 20.0),
                      painter: Line(width: MediaQuery.of(context).size.width / 6),
                    ),
                  ],
                );
              },
              itemBuilder: (BuildContext context, int index) {
                Skill currSkill = skills[treeName][index];
                return Center(
                    child: GestureDetector(
                      onTap: () {
                        showDescription(currSkill, treeIndex, index);
                      },
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        foregroundDecoration: player.skillProgress[treeIndex] <= index ? BoxDecoration(
                            color: Colors.grey,
                            backgroundBlendMode: BlendMode.saturation
                        ) : null,
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
          ),
        ],
      ),
    );
  }
}

class Line extends CustomPainter {
  double width;

  Line({this.width});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(width, 0.0), Offset(width, 20.0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}