import 'package:flutter/material.dart';
import 'package:wizardview/wizardview.dart';

typedef WizardOverlayBuilder = BuiltWizardOverlay Function(
    WizardScopeState state, Offset offset, Size size);

class WizardOverlay {
  const WizardOverlay({
    required this.builder,
    this.alignment = Alignment.bottomCenter,
  });

  /// A builder function which provides the `offset` and `size` of the focused child
  final WizardOverlayBuilder builder;
  final Alignment? alignment;
}

class BuiltWizardOverlay {
  BuiltWizardOverlay({
    required this.child,
    required this.offset,
    required this.size,
  });

  final Widget child;
  final Offset offset;
  final Size size;
}
