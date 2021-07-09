import 'package:flutter/cupertino.dart';

import 'wizard_scope_node.dart';

class WizardScope extends FocusScope {
  const WizardScope({
    required Widget child,
    required this.node,
  }) : super(
          child: child,
          node: node,
        );

  final WizardScopeNode node;
}
