import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_node_mixin.dart';
import 'package:wizardview/src/wizard_overlay.dart';
import 'package:wizardview/src/wizard_parent_data_widget.dart';
import 'package:wizardview/src/wizard_render_object.dart';

import 'wizard_scope.dart';

class WizardNode = FocusNode with WizardNodeMixin;

extension WizardNodeX on WizardNode {
  WizardState? get state => context?.findAncestorStateOfType<WizardState>();
}

/// Represents an indiviudal node in the Feature Discovery.
///
/// [Wizard] manages a [FocusNode], which, when instantiated; should be a
/// descendant of a [WizardScope].
class Wizard extends StatefulWidget {
  const Wizard({
    required this.child,
    required List<WizardOverlay>? overlays,
    this.activeChild,
    this.background,
    this.onNodeStart,
    this.onNodeEnd,
    this.renderChild = true,
    Key? key,
  })  :

        ///! This list is not growable => overlays cannot be added after Wizard
        ///! construction.
        overlays = overlays ?? const [],
        super(key: key);

  /// The widget to be focused
  final Widget child;

  /// An optional [Widget] to be shown instead of `child` when this [Wizard] is
  /// in focus
  final Widget? activeChild;

  /// Flag for if this [Wizard] should render the focused child
  final bool renderChild;

  /// A list of [WizardOverlay] objects which contain rendering information
  /// about the overlays that you want to display
  final List<WizardOverlay> overlays;

  /// The widget to be shown behind the [child] and the [overlays]. Typically,
  /// an empty [Container] with `color: Colors.black12` to emulate a dimming
  /// effect
  final Widget? background;

  /// Callback executed after focusing on a new node
  final WizardCallback? onNodeStart;

  /// Callback executed before moving focus to the next node
  final WizardCallback? onNodeEnd;

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

  OverlayEntry overlayEntry({Widget? background}) {
    return OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          top: _wizardNode.offset.dy,
          left: _wizardNode.offset.dx,
          child: Material(
            color: Colors.transparent,
            child: WizardRenderObjectWidget(
              active: active,
              // `overlays` have to pass their alignments inside the
              // [WizardRenderObjectWidget]
              overlays: widget.overlays.map((overlay) {
                final builtWizardOverlay = overlay.builder?.call(
                  _wizardNode.offset,
                  _wizardNode.size,
                );

                return WizardParentDataWidget(
                  id: WizardObjectId.overlay,
                  alignment: overlay.alignment,
                  overlayOffset: builtWizardOverlay?.offset,
                  overlaySize: builtWizardOverlay?.size,
                  child: builtWizardOverlay?.child ?? overlay.child!,
                );
              }).toList(),
              child: widget.activeChild ?? widget.child,
              background: widget.background ??
                  context
                      .findAncestorStateOfType<WizardScopeState>()
                      ?.background ??
                  Container(
                    child: Text('[WizardScopeState] not found'),
                  ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 0 : 1,
      child: Focus(
        focusNode: _wizardNode,
        child: widget.child,
      ),
    );
  }
}
