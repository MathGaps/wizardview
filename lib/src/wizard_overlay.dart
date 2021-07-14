import 'package:flutter/material.dart';

//TODO: Think of a better name here / a better approach
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

  final OverlayBuilder? builder;
  final Widget? child;
  final Alignment? alignment;
}

class BuiltWizardOverlay {
  //TODO:
  BuiltWizardOverlay(this.child, this.offset, this.size);

  final Widget child;
  final Offset offset;
  final Size size;
}
