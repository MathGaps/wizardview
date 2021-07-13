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
  bool _started = false;
  bool get started => _started;

  final List<WizardNode> _history = [];

  Future<void> next() async {
    debugPrint('[WizardScopeState] next()');

    if (!_started) {
      _started = true;
      widget.onStart?.call();
    } else {
      _focussedNode?.state
        ?..active = false
        ..onNodeEnd();
    }

    /// Handles edge where there are no [WizardNode]'s in the ancestors
    final List<FocusNode> history = [..._history];

    // Ensures [WizardScopeNode] already has the focus before iterating
    // through its children, that way `_node.focusedChild` will not return `null`.
    if (!_node.hasFocus) {
      _node.requestFocus();
      await Future.delayed(Duration(seconds: 0));
    }

    /// Handles the case where a [WizardNode] is already selected because of
    /// calling [prev()]
    if (_node.focusedChild is WizardNode)
      (_node.focusedChild as WizardNode).state?.onNodeEnd();

    FocusNode? focussedNode;
    do {
      if (!_node.nextFocus() ||
          history.contains(focussedNode = _node.focusedChild)) {
        return end();
      }
    } while (focussedNode is! WizardNode);
    _history.add(_focussedNode = focussedNode);

    debugPrint('[WizardScopeState] WizardNode ${_history.length} found');

    focussedNode.state!.onNodeStart();
  }

  /// * Could previous change depending on the FocusTraversal? Although, maybe
  /// if it does this isn't the expected behaviour. (I'm thinking of the scenario
  /// in which the position of the node changes, in such a way that the
  /// [ReadingOrderTraversalPolicy] changes. Eh fuck it)
  void prev() async {
    if (_history.isEmpty) {
      end();
      return;
    }

    final removedNode = _history.removeLast();
    removedNode.state
      ?..active = false
      ..onNodeEnd();

    if (_history.isEmpty) {
      removedNode.previousFocus();
      end();
      return;
    }

    _history.last.requestFocus();
    _history.last.state
      ?..active = true
      ..onNodeStart();
  }

  void end() {
    debugPrint('[WizardScopeState] end()');
    _history.clear();
    _node.unfocus();
    _focussedNode?.unfocus();
    _focussedNode?.state?.onNodeEnd();
    widget.onEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedWizardScope(
      data: this,
      child: FocusScope(
        node: _node,
        // skipTraversal: !_started,
        // canRequestFocus: true,
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
