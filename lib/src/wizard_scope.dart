import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_scope_node_mixin.dart';
import 'package:wizardview/src/wizard.dart';

//TODO: #1 Documentation on WizardScope

class WizardScopeNode = FocusScopeNode with WizardScopeNodeMixin;

class WizardScope extends StatefulWidget {
  const WizardScope({
    required this.child,
    this.onStart,
    this.onEnd,
    Key? key,
  }) : super(key: key);

  final Widget child;
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
  final WizardScopeNode _node = WizardScopeNode(debugLabel: 'WizardScope');

  void start() {
    debugPrint('[WizardScopeState] start()');

    for (final FocusNode childNode in _node.children) {
      debugPrint('childNode.context.widget: ${childNode.context?.widget}');

      // if (childNode is WizardNode) {
      //   debugPrint('childNode.context.widget: ${childNode.context?.widget}');
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedWizardScope(
      data: this,
      child: FocusScope(
        node: _node,
        child: widget.child,
      ),
    );
  }
}

// Callbacks

// InheritedNotifier - expose WizardScope to context

// Background

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
