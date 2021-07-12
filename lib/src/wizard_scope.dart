import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_scope_node_mixin.dart';

//TODO: #1 Documentation on WizardScope

class WizardScopeNode = FocusScopeNode with WizardScopeNodeMixin;

class WizardScope extends StatefulWidget {
  const WizardScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  static WizardScopeState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_InheritedWizardScope>()
            as _InheritedWizardScope)
        .data;
  }

  @override
  WizardScopeState createState() => WizardScopeState();
}

class WizardScopeState extends State<WizardScope> {
  final WizardScopeNode node = WizardScopeNode(debugLabel: 'WizardScope');

  void testInheritance() {
    print('hello there');
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedWizardScope(
      data: this,
      child: FocusScope(
        node: node,
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
