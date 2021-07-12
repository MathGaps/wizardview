import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_node_mixin.dart';
import 'package:wizardview/src/wizard_render_object.dart';
import 'wizard_scope.dart';

//! Instead of implementing all the Focus classes + widgets, maybe we should
//! create widgets that manage their construction / lifecycle. The API is really
//! difficult to abstract.

//? We don't actually need to add anything to the Focus classes themselves;
//? objects like FocusTraversalPolicy should be working out-of-the-box, so it's
//? probably a better idea to avoid this approach altogether.

/// Represents an indiviudal node in the Feature Discovery.
///
/// [WizardNode] manages a [FocusNode], which, when instantiated; should be a
/// descendant of a [WizardScope].

class Wizard extends StatelessWidget {
  const Wizard({
    required this.child,
    this.focusNode,
    this.background,
    this.overlay,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Widget? background;
  final Widget? overlay;

  /// Parameters passed down to [Focus]. The lifecycle of a [FocusNode] should
  /// be managed inside the [Widget] it's instantiated in. If a [FocusNode] is
  /// not provided, [Focus] will implicitly create and manage one.
  final WizardNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return WizardRenderObject(
      child: Focus(
        focusNode: focusNode,
        child: child,
      ),
    );
  }
}

class WizardNode = FocusNode with WizardNodeMixin;

// Callbacks

// Stack/MultiC