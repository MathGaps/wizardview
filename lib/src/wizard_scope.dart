import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_scope_node_mixin.dart';
import 'package:wizardview/wizardview.dart';

//TODO: #1 Documentation on WizardScope

class WizardScopeNode = FocusScopeNode with WizardScopeNodeMixin;

class WizardScope extends StatefulWidget {
  const WizardScope({
    required this.child,
    this.policy,
    this.onStart,
    this.onEnd,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final FocusTraversalPolicy? policy;
  final VoidCallback? onStart;
  final VoidCallback? onEnd;

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

  // TODO: Separate next() from start() since we're using the contents
  // of `_history` as a basis if the [Wizard] has started, or change
  // `started` logic

  // How come this is a problem? When the showcase finishes, we could simply
  // do _history.clear(), so that `started` goes back to `false`

  final List<WizardNode> _history = [];

  // TODO: Ensure [WizardScopeNode] already has the focus before iterating
  // through its children, that way `_node.focusedChild` will not return `null`
  @override
  void initState() {
    super.initState();

    _node.requestFocus();
  }

  Future<void> next() async {
    debugPrint('[WizardScopeState] next()');

    /// Handles edge where there are no [WizardNode]'s in the ancestors
    final List<FocusNode> history = [..._history];

    debugPrint(
        '[WizardScopeState] _node.traversalChildren: ${_node.traversalChildren}');
    debugPrint('[WizardScopeState] _node.focusedChild: ${_node.focusedChild}');
    debugPrint(
        '[WizardScopeState] _node.children.first: ${_node.children.first}');

    if (!_node.hasFocus) {
      _node.requestFocus();

      /// ? You'll laugh at this one. I mean shit how else do you wait for a frame?
      await Future.delayed(Duration(seconds: 0));
    }
    debugPrint('[WizardScopeState] _node.hasFocus: ${_node.hasFocus}');

    FocusNode? focussedNode;
    do {
      if (!_node.nextFocus() ||
          history.contains(focussedNode = _node.focusedChild)) {
        return end();
      }
    } while (focussedNode is! WizardNode);

    debugPrint('[WizardScopeState] first WizardNode found');

    /// This can be asserted, as otherwise the loop would break or the `nextFocus()`
    /// would return `false` => focussedNode == null.
    _focussedNode = focussedNode as WizardNode;
    _history.add(focussedNode);

    final wizard =
        focussedNode.context!.findAncestorStateOfType<WizardState>()!;
    debugPrint('childNode.context.widget: $wizard');

    wizard.onNodeStart();

    /// extra logic -> beginning the next [WizardNode], handling callbacks
    /// etc.
  }

  void prev() {
    _history.removeLast();
  }

  void end() {
    debugPrint('[WizardScopeState] end()');
    _history.clear();
    _node.unfocus();
    _focussedNode?.state?.onNodeEnd();
  }

  bool get started => _history.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return _InheritedWizardScope(
      data: this,
      child: FocusScope(
        node: _node,
        // TODO: Fix `skipTraversal` & `canRequestFocus` flags from [WizardScope] implementation
        // skipTraversal: !started,
        canRequestFocus: true,
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
