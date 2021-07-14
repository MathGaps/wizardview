import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_node_mixin.dart';
import 'package:wizardview/src/wizard_render_object.dart';

import 'wizard_scope.dart';

/// Represents an indiviudal node in the Feature Discovery.
///
/// [Wizard] manages a [FocusNode], which, when instantiated; should be a
/// descendant of a [WizardScope].

class WizardNode = FocusNode with WizardNodeMixin;

extension WizardNodeX on WizardNode {
  WizardState? get state => context?.findAncestorStateOfType<WizardState>();
}

class Wizard extends StatefulWidget {
  const Wizard({
    Key? key,
    required this.child,
    this.background,
    this.overlay,
    this.onNodeStart,
    this.onNodeEnd,
    this.overlayAlignment = Alignment.bottomRight,
  }) : super(key: key);

  /// The widget to be focused
  final Widget child;

  /// The widget to be shown behind the [child] and the [overlay]. Typically,
  /// an empty [Container] with `color: Colors.black12` to emulate a dimming
  /// effect
  final Widget? background;

  /// The
  final Widget? overlay;

  ///
  final WizardCallback? onNodeStart;

  final WizardCallback? onNodeEnd;

  final Alignment overlayAlignment;

  @override
  WizardState createState() => WizardState();
}

class WizardState extends State<Wizard> {
  late final WizardNode _wizardNode;

  bool _active = false;
  bool get active => _active;
  set active(bool active) {
    if (_active == active) return;
    setState(() => _active = active);
  }

  @override
  void initState() {
    super.initState();
    _wizardNode = WizardNode(debugLabel: 'WizardNode');
  }

  @override
  void dispose() {
    _wizardNode.dispose();
    super.dispose();
  }

  Future<void> onNodeStart() async {
    active = true;
    await widget.onNodeStart?.call();
  }

  Future<void> onNodeEnd() async {
    await widget.onNodeEnd?.call();
    active = false;
  }

  OverlayEntry get overlayEntry => OverlayEntry(
        builder: (BuildContext context) => Positioned(
          top: _wizardNode.offset.dy,
          left: _wizardNode.offset.dx,
          child: Material(
            color: Colors.transparent,
            child: widget.overlay ?? Container(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // final bool started = WizardScope.of(context).started;

    return WizardRenderObject(
      active: active,
      overlayAlignment: widget.overlayAlignment,
      child: Focus(
        focusNode: _wizardNode,
        child: widget.child,
        // skipTraversal: !started,
        // canRequestFocus: started,
      ),
      background: widget.background ?? Container(),
      // overlay: widget.overlay ?? Container(),
    );
  }
}
