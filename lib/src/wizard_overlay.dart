import 'package:flutter/material.dart';

typedef OverlayBuilder = Widget Function(Offset offset, Size size);

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