import 'package:flutter/material.dart';

typedef OverlayBuilder = BuiltWizardOverlay Function(Offset offset, Size size);

class WizardOverlay {
  const WizardOverlay({
    required Widget child,
    Alignment alignment = Alignment.bottomCenter,
  })  : alignment = alignment,
        builder = null,
        child = child;

  const WizardOverlay.builder({
    required OverlayBuilder builder,
  })  : alignment = null,
        builder = builder,
        child = null;

  /// A builder function which provides the `offset` and `size` of the focused child
  final OverlayBuilder? builder;
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
