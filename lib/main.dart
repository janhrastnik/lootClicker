import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs.dart';
import 'widgets/backdrop.dart';
import 'package:scoped_model/scoped_model.dart';
import 'classes.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'globals.dart';
import 'widgets/menu.dart';
import 'widgets/dungeon.dart';

class MyBlocDelegate extends BlocDelegate {
  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    // print(error);
  }

  @override
  void onTransition(Transition transition) {
    super.onTransition(transition);
    print(dungeonTiles[1].event.eventType);
  }
}

void main() {
  BlocSupervisor().delegate = MyBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  TextStyle textStyle(fontSize) => TextStyle(
  fontSize: fontSize,
  color: Colors.black,
  shadows: [
  Shadow( // bottomLeft
    offset: Offset(-1.5, -1.5),
    color: Colors.white
  ),
  Shadow( // bottomRight
    offset: Offset(0.0, -1.5),
    color: Colors.white
  ),
  Shadow( // topRight
    offset: Offset(1.5, 1.5),
    color: Colors.white
  ),
  Shadow(// topLeft
    offset: Offset(-1.5, 0.0),
    color: Colors.white
  ),
  Shadow(// topLeft
      offset: Offset(0.0, 1.5),
      color: Colors.white
  ),
  Shadow(// topLeft
      offset: Offset(1.5, 0.0),
      color: Colors.white
  ),
  ]);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "Boxy",
          textTheme: TextTheme(
            bodyText1: textStyle(12.0),
            bodyText2: textStyle(12.0),
            button: textStyle(11.0),
            subtitle1: textStyle(11.0),
          )
      ),
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {

  Future readData(file) async {
    try {
      String data = await rootBundle.loadString(file);
      return jsonDecode(data);
    } catch (e) {
      print(e);
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    String path = await _localPath;
    return File('$path/player.json');
  }

  Future<File> saveProgress() async {
    final file = await _localFile;
    var jsonData = jsonEncode(player.toJson());
    // Write the file
    return file.writeAsString(jsonData);
  }

  Future readProgress() async {
    try {
      final file = await _localFile;
      // Read the file
      String jsonString = await file.readAsString();
      print(jsonString);
      Map contents = jsonDecode(jsonString);
      if (contents != null) {
        Player tempPlayer = Player.fromJson(contents);
        tempPlayer.equipped = {
          "weapon": contents["equipped"]["weapon"] != null ? Item.fromJson(contents["equipped"]["weapon"]): null,
          "shield": contents["equipped"]["shield"] != null ? Item.fromJson(contents["equipped"]["shield"]) : null,
          "helmet": contents["equipped"]["helmet"] != null ? Item.fromJson(contents["equipped"]["helmet"]) : null,
          "body": contents["equipped"]["body"] != null ? Item.fromJson(contents["equipped"]["body"]): null
        };
        return tempPlayer;
      }
    } catch (e) {
      print(e);
      return 0;
      // If encountering an error, return 0
    }
  }

  void wrap() async {
    Timer.periodic(Duration(seconds: 5), (Timer t) => saveProgress()); // save game every 5 seconds
    await readData("assets/monsters.json").then((data) {
      data.forEach((key, value) {
        monsters[key] = Enemy(
            name: key,
            hp: value["hp"],
            expValue: value["expValue"],
            attack: value["attack"],
            loot: value["loot"]);
      });
      print(monsters.keys.toList().toString());
    });
    await readData("assets/items.json").then((data) {
      Map _data = data["items"];
      _data.forEach((key, args) {
        items[key] = Item(
            name: args["name"],
            id: key,
            equip: args["equip"],
            behaviours: args,
            description: args["description"],
            cost: args["cost"],
            time: args["time"]);
      });
    });
    await readData("assets/skills.json").then((data) {
      data.forEach((tree, _skills) {
        _skills.forEach((skillName, skillDetail) {
          List temp = skills[tree];
          temp.add(Skill(
              name: skillDetail["name"],
              id: skillName,
              description: skillDetail["description"],
              behaviours: skillDetail
          ));
          skills[tree] = temp;
        });
      });
      print(skills);
    });
    readProgress().then((data) {
      if (data != 0) {
        player = data;
        print("Found json");
      } else {
        player = Player(
            inventory: [],
            equipped: {"weapon": null, "shield": null, "helmet": null, "body": null},
            skillProgress: [0, 0, 0]
        );
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BlocPage()));
    });
  }

  @override
  void initState() {
    wrap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromARGB(255, 94, 54, 64),
        child: Center(
          child: Image(image: AssetImage("assets/icon.png"), width: 96.0, height: 96.0,),
        ),
      ),
    );
  }
}

class BlocPage extends StatefulWidget {
  BlocPageState createState() => BlocPageState();
}

class BlocPageState extends State<BlocPage> {
  DungeonBloc _dungeonBloc;
  ClickerBloc _clickerBloc;
  GoldBloc _goldBloc;
  TapAnimationBloc _tapAnimationBloc;
  HeroHpBloc _heroHpBloc;
  HeroExpBloc _heroExpBloc;
  ActionBloc _actionBloc;

  @override
  void initState() {
    _actionBloc = ActionBloc();
    _goldBloc = GoldBloc();
    _dungeonBloc = DungeonBloc(actionBloc: _actionBloc);
    _heroHpBloc = HeroHpBloc(dungeonBloc: _dungeonBloc);
    _heroExpBloc = HeroExpBloc(heroHpBloc: _heroHpBloc);
    _clickerBloc = ClickerBloc(
      goldBloc: _goldBloc,
      heroHpBloc: _heroHpBloc,
      heroExpBloc: _heroExpBloc,
      dungeonBloc: _dungeonBloc,
      actionBloc: _actionBloc
    );
    _tapAnimationBloc = TapAnimationBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: <BlocProvider>[
        BlocProvider<ActionBloc>(bloc: _actionBloc),
        BlocProvider<DungeonBloc>(bloc: _dungeonBloc),
        BlocProvider<ClickerBloc>(bloc: _clickerBloc),
        BlocProvider<GoldBloc>(bloc: _goldBloc),
        BlocProvider<TapAnimationBloc>(bloc: _tapAnimationBloc),
        BlocProvider<HeroHpBloc>(bloc: _heroHpBloc),
        BlocProvider<HeroExpBloc>(bloc: _heroExpBloc),
      ],
      child: ClickerApp(),
    );
  }
}

class ClickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ScopedModel(
      model: FrontPanelModel(FrontPanels.characterPage),
      child: Scaffold(body: SafeArea(child: Panels())));
}

class Panels extends StatelessWidget {
  final frontPanelVisible = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<FrontPanelModel>(
      builder: (context, _, model) => Scaffold(
        body: Backdrop(
          menuRow: MenuRow(
            frontPanelOpen: frontPanelVisible,
          ),
          frontLayer: model.activePanel,
          backLayer: DungeonScreen(),
          panelVisible: frontPanelVisible,
          frontPanelOpenHeight: 30.0,
          frontHeaderHeight: 0.0,
        ),
      ),
    );
  }
}