import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const _kFlingVelocity = 2.0;
AnimationController controller;

void toggleBackdropPanelVisibility(_backdropPanelVisible) => controller.fling(
    velocity: _backdropPanelVisible ? -_kFlingVelocity : _kFlingVelocity);

class _BackdropPanel extends StatelessWidget {
  const _BackdropPanel({
    Key key,
    this.onTap,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.title,
    this.child,
    this.titleHeight,
    this.padding,
  }) : super(key: key);

  final VoidCallback onTap;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final Widget title;
  final Widget child;
  final double titleHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Material(
        elevation: 12.0,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: onVerticalDragUpdate,
              onVerticalDragEnd: onVerticalDragEnd,
              onTap: onTap,
              child: Container(height: titleHeight, child: title),
            ),
            Divider(
              height: 1.0,
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds a Backdrop.
///
/// A Backdrop widget has two panels, front and back. The front panel is shown
/// by default, and slides down to show the back panel, from which a user
/// can make a selection. The user can also configure the titles for when the
/// front or back panel is showing.
class Backdrop extends StatefulWidget {
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontHeader;
  final Widget menuRow;
  final double frontPanelOpenHeight;
  final double frontHeaderHeight;
  final bool frontHeaderVisibleClosed;
  final EdgeInsets frontPanelPadding;
  final ValueNotifier<bool> panelVisible;

  Backdrop(
      {@required this.frontLayer,
        @required this.backLayer,
        @required this.menuRow,
        this.frontPanelOpenHeight = 0.0,
        this.frontHeaderHeight = 48.0,
        this.frontPanelPadding = const EdgeInsets.all(0.0),
        this.frontHeaderVisibleClosed = true,
        this.panelVisible,
        this.frontHeader})
      : assert(frontLayer != null),
        assert(backLayer != null);

  @override
  createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final _backdropKey = GlobalKey(debugLabel: 'Backdrop');

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 300),
      // value of 0 hides the panel; value of 1 fully shows the panel
      value: (widget.panelVisible?.value ?? true) ? 1.0 : 0.0,
      vsync: this,
    );

    // Listen on the toggle value notifier if it's not null

    widget.panelVisible?.addListener(_subscribeToValueNotifier);

    // Ensure that the value notifier is updated when the panel is opened or closed
    if (widget.panelVisible != null) {
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed)
          widget.panelVisible.value = true;
        else if (status == AnimationStatus.dismissed)
          widget.panelVisible.value = false;
      });
    }
  }

  void _subscribeToValueNotifier() {
    if (widget.panelVisible.value != _backdropPanelVisible)
      toggleBackdropPanelVisibility(_backdropPanelVisible);
  }

  /// Required for resubscribing when hot reload occurs
  @override
  void didUpdateWidget(Backdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.panelVisible?.removeListener(_subscribeToValueNotifier);
    widget.panelVisible?.addListener(_subscribeToValueNotifier);
  }

  @override
  void dispose() {
    controller.dispose();
    widget.panelVisible?.dispose();
    super.dispose();
  }

  bool get _backdropPanelVisible =>
      controller.status == AnimationStatus.completed ||
          controller.status == AnimationStatus.forward;

  double get _backdropHeight {
    final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!controller.isAnimating)
      controller.value -= details.primaryDelta / _backdropHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (controller.isAnimating ||
        controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      controller.fling(velocity: math.max(_kFlingVelocity, -flingVelocity));
    else if (flingVelocity > 0.0)
      controller.fling(velocity: math.min(-_kFlingVelocity, -flingVelocity));
    else
      controller.fling(
          velocity:
          controller.value < 0.5 ? -_kFlingVelocity : _kFlingVelocity);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final panelSize = constraints.biggest;
      final closedPercentage = widget.frontHeaderVisibleClosed
          ? (panelSize.height - widget.frontHeaderHeight) / panelSize.height
          : 1.0;
      final openPercentage = widget.frontPanelOpenHeight / panelSize.height;

      final panelDetailsPosition = Tween<Offset>(
        begin: Offset(0.0, closedPercentage),
        end: Offset(0.0, openPercentage),
      ).animate(controller.view);

      return Container(
        key: _backdropKey,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  widget.backLayer,
                  SlideTransition(
                    position: panelDetailsPosition,
                    child: _BackdropPanel(
                      onTap: () {
                        toggleBackdropPanelVisibility(_backdropPanelVisible);
                      },
                      onVerticalDragUpdate: _handleDragUpdate,
                      onVerticalDragEnd: _handleDragEnd,
                      title: widget.frontHeader,
                      titleHeight: widget.frontHeaderHeight,
                      child: widget.frontLayer,
                      padding: widget.frontPanelPadding,
                    ),
                  ),
                  // TODO: ADD MENU ROW HEREEE
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: widget.menuRow,
            )
          ],
        ),
      );
    });
  }
}
