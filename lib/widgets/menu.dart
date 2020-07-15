import 'package:flutter/material.dart';
import 'backdrop.dart';
import 'package:scoped_model/scoped_model.dart';
import '../globals.dart';
import 'character.dart';
import 'shop.dart';
import 'skills.dart';

class FrontPanelModel extends Model {
  FrontPanelModel(this._activePanel);
  FrontPanel _activePanel;

  FrontPanel get activePanelType => _activePanel;

  Widget get activePanel {
    if (_activePanel == FrontPanel.characterPage) {
      return CharacterScreen();
    } else if (_activePanel == FrontPanel.shopPage) {
      return ShopScreen();
    } else {
      return SkillsScreen();
    }
  }

  void activate(FrontPanel panel) {
    _activePanel = panel;
    notifyListeners();
  }
}

class MenuRow extends StatefulWidget {
  MenuRow({@required this.frontPanelOpen});
  final ValueNotifier<bool> frontPanelOpen;

  MenuRowState createState() => MenuRowState();
}

class MenuRowState extends State<MenuRow> {
  bool panelOpen;

  @override
  initState() {
    super.initState();
    panelOpen = widget.frontPanelOpen.value;
    widget.frontPanelOpen.addListener(_subscribeToValueNotifier);
  }

  void _subscribeToValueNotifier() =>
      setState(() => panelOpen = widget.frontPanelOpen.value);

  /// Required for resubscribing when hot reload occurs
  @override
  void didUpdateWidget(MenuRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.frontPanelOpen.removeListener(_subscribeToValueNotifier);
    widget.frontPanelOpen.addListener(_subscribeToValueNotifier);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ScopedModelDescendant<FrontPanelModel>(
                  rebuildOnChange: false,
                  builder: (context, _, model) => MaterialButton(
                    height: 50.0,
                    color: model._activePanel == FrontPanel.characterPage &&
                        widget.frontPanelOpen.value
                        ? Colors.blueGrey
                        : Colors.white,
                    child: Text("Character"),
                    onPressed: () {
                      if (widget.frontPanelOpen.value == true &&
                          model._activePanel == FrontPanel.characterPage) {
                        toggleBackdropPanelVisibility(
                            widget.frontPanelOpen.value);
                        gameData.isMenu = false;
                      } else {
                        gameData.isMenu = true;
                        model.activate(FrontPanel.characterPage);
                        widget.frontPanelOpen.value = true;
                      }
                    },
                  )),
            ),
            Expanded(
              child: ScopedModelDescendant<FrontPanelModel>(
                  rebuildOnChange: false,
                  builder: (context, _, model) => MaterialButton(
                    height: 50.0,
                    color: model._activePanel == FrontPanel.shopPage &&
                        widget.frontPanelOpen.value
                        ? Colors.blueGrey
                        : Colors.white,
                    child: Text("Shop"),
                    onPressed: () {
                      if (widget.frontPanelOpen.value == true &&
                          model._activePanel == FrontPanel.shopPage) {
                        toggleBackdropPanelVisibility(
                            widget.frontPanelOpen.value);
                        gameData.isMenu = false;
                      } else {
                        gameData.isMenu = true;
                        model.activate(FrontPanel.shopPage);
                        widget.frontPanelOpen.value = true;
                      }
                    },
                  )),
            ),
            Expanded(
              child: ScopedModelDescendant<FrontPanelModel>(
                  rebuildOnChange: false,
                  builder: (context, _, model) => MaterialButton(
                    height: 50.0,
                    color: model._activePanel == FrontPanel.skillsPage &&
                        widget.frontPanelOpen.value
                        ? Colors.blueGrey
                        : Colors.white,
                    child: Text("Skills"),
                    onPressed: () {
                      if (widget.frontPanelOpen.value == true &&
                          model._activePanel == FrontPanel.skillsPage) {
                        toggleBackdropPanelVisibility(
                            widget.frontPanelOpen.value);
                        gameData.isMenu = false;
                      } else {
                        gameData.isMenu = true;
                        model.activate(FrontPanel.skillsPage);
                        widget.frontPanelOpen.value = true;
                      }
                    },
                  )),
            )
          ],
        ),
      ],
    )
    ;
  }
}