import 'package:flutter/material.dart';
import 'package:wizardview/wizardview.dart';

typedef WizardOverlayBuilder = BuiltWizardOverlay Function(
    WizardScopeState state, Offset offset, Size size);

class WizardOverlay {
  const WizardOverlay({
    required Widget child,
    Alignment alignment = Alignment.bottomCenter,
  })  : alignment = alignment,
        builder = null,
        child = child;

  const WizardOverlay.builder({
    required WizardOverlayBuilder builder,
  })  : alignment = null,
        child = null,
        builder = builder;

  /// A builder function which provides the `offset` and `size` of the focused child
  final WizardOverlayBuilder? builder;
  final Widget? child;
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
