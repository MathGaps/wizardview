import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_scope_node_mixin.dart';
import 'package:wizardview/wizardview.dart';

//TODO: #1 Documentation on WizardScope

class WizardScopeNode = FocusScopeNode with WizardScopeNodeMixin;

typedef WizardCallback = FutureOr<void> Function();

class WizardScope extends StatefulWidget {
  const WizardScope({
    required this.child,
    this.background,
    this.policy,
    this.onStart,
    this.onEnd,
    this.actions,
    this.actionsAlignment = Alignment.bottomRight,
    this.actionsPadding = const EdgeInsets.all(20),
    Key? key,
  }) : super(key: key);

  final Widget child;

  ///
  final Widget? background;

  final FocusTraversalPolicy? policy;

  /// Executed before traversing through all of its [Wizard] children
  final WizardCallback? onStart;

  /// Executed after traversing through all of its [Wizard] children
  final WizardCallback? onEnd;

  /// Widgets to be displayed on the overlay, supposedly to assist with
  /// [Wizard] traversal
  final Widget? actions;

  /// Alignment of the `actions` widgets
  final Alignment actionsAlignment;

  final EdgeInsets actionsPadding;

  static WizardScopeState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_InheritedWizardScope>()
            as _InheritedWizardScope)
        .data;
  }

  @override
  WizardScopeState createState() => WizardScopeState();
}

class WizardScopeState extends State<WizardScope> {
  final WizardScopeNode _node = WizardScopeNode(
    debugLabel: 'WizardScope',
  );

  /// The [WizardNode] currently in focus
  WizardNode? _focussedNode;

  /// Keeps track of the already visited [WizardNode]s
  final List<WizardNode> _history = [];

  /// Flag used to make sure [WizardNode]s do not interfere with the focus
  /// traversal while [WizardScope] traversal is inactive
  bool get started => _started.value;
  ValueNotifier<bool> _started = ValueNotifier(false);

  /// Reference to the `action` widgets for latter cleanup
  OverlayEntry? _actionsOverlay;

  /// Reference to the currently presented overlay, we need this to call
  /// `markNeedsBuild` on it when animating
  OverlayEntry? _currentOverlayEntry;

  /// Call this if the `overlay` widget of your [Wizard] needs to be animated
  void animate() {
    if (_currentOverlayEntry?.mounted ?? false) {
      _currentOverlayEntry?.markNeedsBuild();
    }
  }

  // Future<void> showIntro() {
  //   Future<bool> done = Future();
  // }

  /// Start the [WizardScope] traversal, or move on to the next object to focus if
  /// traversal is ongoing
  Future<void> next() async {
    debugPrint('[WizardScopeState] next()');

    if (!_started.value) {
      _started.value = true;

      _inflateActionsOverlay();

      await widget.onStart?.call();
    } else {
      await _focussedNode?.state?.onNodeEnd();
      _currentOverlayEntry?.remove();
      _focussedNode?.state?..active = false;
    }

    /// Handles edge where there are no [WizardNode]'s in the ancestors
    final List<FocusNode> history = [..._history];

    // Ensures [WizardScopeNode] already has the focus before iterating
    // through its children, that way `_node.focusedChild` will not return `null`.
    if (!_node.hasFocus) {
      _node.requestFocus();

      // Wait for the next frame to ensure [_node] has received focus since
      // notification may lag for up to a frame
      await Future.delayed(Duration(seconds: 0));
    }

    FocusNode? focussedNode;
    do {
      if (!_node.nextFocus() ||
          history.contains(focussedNode = _node.focusedChild)) {
        _currentOverlayEntry = null;
        return end();
      }
    } while (focussedNode is! WizardNode);
    _history.add(_focussedNode = focussedNode);

    debugPrint('[WizardScopeState] WizardNode ${_history.length} found');

    _focussedNode!.state!.active = true;
    Overlay.of(context)?.insert(
        _currentOverlayEntry = _focussedNode!.state!.overlayEntry(
          background: widget.background,
        ),
        below: _actionsOverlay);
    setState(() {});
    await _focussedNode!.state!.onNodeStart();
  }

  /// Re-focus on the previously focused node
  void prev() async {
    if (_history.isEmpty) {
      end();
      return;
    }

    final removedNode = _history.removeLast();
    await removedNode.state?.onNodeEnd();
    removedNode.state?..active = false;
    _currentOverlayEntry?.remove();

    if (_history.isEmpty) {
      removedNode.previousFocus();
      end();
      return;
    }

    _focussedNode = _history.last
      ..requestFocus()
      ..state?.active = true;
    Overlay.of(
      context,
    )?.insert(_currentOverlayEntry = _focussedNode!.state!.overlayEntry(
      background: widget.background,
    ));
    await _history.last.state?.onNodeStart();
  }

  void end() async {
    debugPrint('[WizardScopeState] end()');
    _history.clear();
    _node.unfocus();
    _currentOverlayEntry?.remove();
    _actionsOverlay?.remove();
    _focussedNode?.unfocus();
    await _focussedNode?.state?.onNodeEnd();
    widget.onEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedWizardScope(
      data: this,
      child: FocusScope(
        node: _node,
        // skipTraversal: !started,
        // canRequestFocus: started,
        child: FocusTraversalGroup(
          policy: widget.policy,
          child: widget.child,
        ),
      ),
    );
  }

  void _inflateActionsOverlay() {
    if (widget.actions == null) return;

    Overlay.of(context)?.insert(
      _actionsOverlay = OverlayEntry(
        builder: (BuildContext context) => Align(
          alignment: widget.actionsAlignment,
          child: Padding(
            padding: widget.actionsPadding,
            child: widget.actions,
          ),
        ),
      ),
    );
  }
}

class _InheritedWizardScope extends InheritedNotifier {
  _InheritedWizardScope({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final WizardScopeState data;

  @override
  bool updateShouldNotify(_InheritedWizardScope old) =>
      old.data != data || old.child != child;
}
