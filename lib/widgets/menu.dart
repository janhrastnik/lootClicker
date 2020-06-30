import 'package:flutter/material.dart';
import 'backdrop.dart';
import 'package:scoped_model/scoped_model.dart';
import '../globals.dart';
import 'character.dart';
import 'shop.dart';
import 'skills.dart';

class FrontPanelModel extends Model {
  FrontPanelModel(this._activePanel);
  FrontPanels _activePanel;

  FrontPanels get activePanelType => _activePanel;

  Widget get activePanel {
    if (_activePanel == FrontPanels.characterPage) {
      return CharacterScreen();
    } else if (_activePanel == FrontPanels.shopPage) {
      return ShopScreen();
    } else if (_activePanel == FrontPanels.skillsPage) {
      return SkillsScreen();
    }
  }

  void activate(FrontPanels panel) {
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
                    color: model._activePanel == FrontPanels.characterPage &&
                        widget.frontPanelOpen.value
                        ? Colors.blueGrey
                        : Colors.white,
                    child: Text("Character"),
                    onPressed: () {
                      if (widget.frontPanelOpen.value == true &&
                          model._activePanel == FrontPanels.characterPage) {
                        toggleBackdropPanelVisibility(
                            widget.frontPanelOpen.value);
                        isMenu = false;
                      } else {
                        isMenu = true;
                        model.activate(FrontPanels.characterPage);
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
                    color: model._activePanel == FrontPanels.shopPage &&
                        widget.frontPanelOpen.value
                        ? Colors.blueGrey
                        : Colors.white,
                    child: Text("Shop"),
                    onPressed: () {
                      if (widget.frontPanelOpen.value == true &&
                          model._activePanel == FrontPanels.shopPage) {
                        toggleBackdropPanelVisibility(
                            widget.frontPanelOpen.value);
                        isMenu = false;
                      } else {
                        isMenu = true;
                        model.activate(FrontPanels.shopPage);
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
                    color: model._activePanel == FrontPanels.skillsPage &&
                        widget.frontPanelOpen.value
                        ? Colors.blueGrey
                        : Colors.white,
                    child: Text("Skills"),
                    onPressed: () {
                      if (widget.frontPanelOpen.value == true &&
                          model._activePanel == FrontPanels.skillsPage) {
                        toggleBackdropPanelVisibility(
                            widget.frontPanelOpen.value);
                        isMenu = false;
                      } else {
                        isMenu = true;
                        model.activate(FrontPanels.skillsPage);
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