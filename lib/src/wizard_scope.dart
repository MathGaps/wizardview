import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_scope_node_mixin.dart';
import 'package:wizardview/wizardview.dart';

class WizardScopeNode = FocusScopeNode with WizardScopeNodeMixin;

typedef WizardCallback = FutureOr<void> Function();
typedef WizardStateCallback = FutureOr<void> Function(WizardScopeState);

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

  ///  The focusable [Widget]
  final Widget child;

  /// The [Widget] to be rendered behind the focused widget. This can be set on
  /// the [WizardScope] itself to provide a background to all [Wizard] children.
  /// The background can be overriden by each [Wizard] child through the child's
  /// `background` property and have this as the fallback
  final Widget? background;

  /// The [FocusTraversalPolicy] to be respected to determine the order in which
  /// each [Wizard] is traversed
  final FocusTraversalPolicy? policy;

  /// Executed before traversing through all of its [Wizard] children
  final WizardStateCallback? onStart;

  /// Executed after traversing through all of its [Wizard] children
  final WizardStateCallback? onEnd;

  /// Widgets to be displayed on the overlay, supposedly to assist with
  /// [Wizard] traversal. We needed to provide the `state` here because if we
  /// pass the `context` here, it wont necesarrily contain the [WizardScope]
  /// instance that we want because `actions` are being rendered in an
  /// [OverlayState]
  final Widget Function(WizardScopeState state)? actions;

  /// Alignment of the `actions` widget
  final Alignment actionsAlignment;

  /// Padding for the `actions` widget
  final EdgeInsets actionsPadding;

  static WizardScopeState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_InheritedWizardScope>() as _InheritedWizardScope).data;
  }

  @override
  WizardScopeState createState() => WizardScopeState();
}

class WizardScopeState extends State<WizardScope> {
  final WizardScopeNode _node = WizardScopeNode(
    debugLabel: 'WizardScope',
  );

  bool _paused = false;

  late FocusAttachment _focusAttachment;
  @override
  void initState() {
    super.initState();

    _focusAttachment = _node.attach(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusAttachment.reparent();
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  /// The [WizardNode] currently in focus
  WizardNode? _focussedNode;
  WizardNode? get focussedNode => _focussedNode;

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

  /// Getter used by [Wizard] children to obtain a background [Widget] if none
  /// has been set for that child
  Widget? get background => widget.background;

  /// Start the [WizardScope] traversal, or move on to the next object to focus if
  /// a traversal is ongoing
  Future<void> next({bool pause = false}) async {
    if (_paused) return;

    if (!_started.value) {
      _started.value = true;
      await widget.onStart?.call(this);

      if (!_node.hasPrimaryFocus) {
        FocusManager.instance.rootScope.requestFocus(_node);
        // _node.requestFocus();

        // Waits for the next frame to ensure [_node] has received focus since
        // notification may lag for up to a frame
        await Future.delayed(Duration(seconds: 0));

        // Makes sure that the first `_node.nextFocus()` call will start restart
        // any traversal that's happening
        _node.focusedChild?.unfocus();
      }

      _inflateActionsOverlay();
    } else {
      await _focussedNode?.state?.onNodeEnd();
      if (_currentOverlayEntry?.mounted ?? false) {
        _currentOverlayEntry?.remove();
        _currentOverlayEntry = null;
      }
      _focussedNode?.state?..active = false;

      if (pause) return;
    }

    /// Handles edge where there are no [WizardNode]'s in the ancestors
    final List<FocusNode> history = [..._history];

    // Ensures [WizardScopeNode] already has the focus before iterating
    // through its children, that way `_node.focusedChild` will not return `null`.

    FocusNode? focussedNode;
    do {
      if (!_node.nextFocus() || history.contains(focussedNode = _node.focusedChild)) {
        _currentOverlayEntry = null;
        return end();
      }
    } while (focussedNode is! WizardNode);
    _history.add(_focussedNode = focussedNode);

    _focussedNode!.state!.active = true;
    Overlay.of(context)?.insert(
        _currentOverlayEntry = _focussedNode!.state!.overlayEntry(
          background: widget.background,
        ),
        below: _actionsOverlay);
    await _focussedNode!.state!.onNodeStart();
  }

  void pause() async {
    if (mounted) {
      if (_currentOverlayEntry != null) _currentOverlayEntry?.remove();
      _focussedNode?.state?.active = false;
      _paused = true;
    }
  }

  void resume() async {
    if (mounted) {
      Overlay.of(context)?.insert(_currentOverlayEntry!, below: _actionsOverlay);
      _focussedNode?.state?.active = true;
      _paused = false;
    }
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
    if (!_paused) _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;

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
    )?.insert(
        _currentOverlayEntry = _focussedNode!.state!.overlayEntry(
          background: widget.background,
        ),
        below: _actionsOverlay);
    await _history.last.state?.onNodeStart();
  }

  /// Ends the current [WizardScope] traversal
  void end() async {
    _history.clear();

    _actionsOverlay?.remove();
    _actionsOverlay = null;

    _focussedNode?.unfocus();
    await _focussedNode?.state?.onNodeEnd();
    _focussedNode = null;

    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;

    widget.onEnd?.call(this);
    _started.value = false;
  }

  /// Insert an [OverlayEntry] for the provided `actions` [Widget]
  void _inflateActionsOverlay() {
    if (widget.actions == null) return;

    Overlay.of(context)?.insert(
      _actionsOverlay = OverlayEntry(
        builder: (BuildContext overlayContext) => Align(
          alignment: widget.actionsAlignment,
          child: Padding(
            padding: widget.actionsPadding,
            child: widget.actions?.call(this),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();

    return _InheritedWizardScope(
      data: this,
      child: FocusScope(
        autofocus: true,
        node: _node,
        child: FocusTraversalGroup(
          policy: widget.policy,
          child: widget.child,
        ),
      ),
    );
  }
}

class _InheritedWizardScope extends InheritedWidget {
  _InheritedWizardScope({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final WizardScopeState data;

  @override
  bool updateShouldNotify(_InheritedWizardScope old) => old.data != data || old.child != child;
}
