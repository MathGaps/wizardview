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
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Widget? background;
  final FocusTraversalPolicy? policy;
  final WizardCallback? onStart;
  final WizardCallback? onEnd;
  final List<Widget>? actions;
  final Alignment actionsAlignment;

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

  WizardNode? _focussedNode;
  bool get started => _started.value;
  final List<WizardNode> _history = [];
  ValueNotifier<bool> _started = ValueNotifier(false);

  /// Reference to the currently presented overlay, we need this to call
  /// `markNeedsBuild` on it when animating
  OverlayEntry? _currentOverlayEntry;

  /// Call this if the `overlay` widget of your [Wizard] needs to be animated
  void animate() {
    if (_currentOverlayEntry?.mounted ?? false) {
      _currentOverlayEntry?.markNeedsBuild();
    }
  }

  Future<void> next() async {
    debugPrint('[WizardScopeState] next()');

    if (!_started.value) {
      _started.value = true;
      await widget.onStart?.call();
    } else {
      await _focussedNode?.state?.onNodeEnd();
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
        return end();
      }
    } while (focussedNode is! WizardNode);
    _history.add(_focussedNode = focussedNode);

    debugPrint('[WizardScopeState] WizardNode ${_history.length} found');

    focussedNode.state!.active = true;
    Overlay.of(context)?.insert(
      _currentOverlayEntry = focussedNode.state!.overlayEntry(
        background: widget.background,
      ),
    );
    setState(() {});
    await focussedNode.state!.onNodeStart();
  }

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
