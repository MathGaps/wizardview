import 'package:flutter/material.dart';

import 'wizard_node.dart';

class WizardScopeNode extends FocusScopeNode {
  void start() {
    for (final FocusNode child in children) {
      if (child is WizardNode) {
        final OverlayEntry entry = OverlayEntry(
          builder: (_) => Positioned.fromRect(
            rect: child.offset & child.size,
            child: Material(
              color: Colors.amber.withOpacity(0.3),
            ),
          ),
        );

        Overlay.of(child.context!)!.insert(entry);
      }
    }
  }
}
