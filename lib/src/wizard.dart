import 'package:flutter/material.dart';

import 'package:wizardview/src/mixins/wizard_node_mixin.dart';
import 'package:wizardview/src/wizard_parent_data_widget.dart';
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
/// [Wizard] manages a [FocusNode], which, when instantiated; should be a
/// descendant of a [WizardScope].

class WizardNode = FocusNode with WizardNodeMixin;

extension WizardNodeX on WizardNode {
  WizardState? get state => context?.findAncestorStateOfType<WizardState>();
}

//TODO: How do we instantiate this
typedef OverlayBuilder = Widget Function(Offset offset, Size size);

class Wizard extends StatefulWidget {
  const Wizard({
    Key? key,
    required this.child,
    this.background,
    this.overlay,
    this.onNodeStart,
    this.onNodeEnd,
  }) : super(key: key);

  /// Parameters passed down to [Focus]. The lifecycle of a [FocusNode] should
  /// be managed inside the [Widget] it's instantiated in. If a [FocusNode] is
  /// not provided, [Focus] will implicitly create and manage one.
  final Widget child;
  final Widget? background;
  final Widget? overlay;
  final VoidCallback? onNodeStart;
  final VoidCallback? onNodeEnd;

  @override
  WizardState createState() => WizardState();
}

class WizardState extends State<Wizard> {
  late final WizardNode _wizardNode;
  // ! Test
  bool active = false;

  @override
  void initState() {
    super.initState();

    _wizardNode = WizardNode(debugLabel: 'WizardNode');
  }

  @override
  void dispose() {
    _wizardNode.dispose();

    super.dispose();
  }

  // ! Test
  void onNodeStart() {
    widget.onNodeStart?.call();

    setState(() => active = true);
  }

  void onNodeEnd() {
    widget.onNodeEnd?.call();

    setState(() => active = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool started = WizardScope.of(context).started;
    print(active);

    /// * Animations are a bit cooked. They're rendering extremely slowly
    return WizardRenderObject(
      active: active,
      child: WizardParentDataWidget(
        id: WizardObjectId.child,
        child: Focus(
          focusNode: _wizardNode,
          child: widget.child,
          // canRequestFocus: started,
          // skipTraversal: !started,
        ),
      ),
      background: WizardParentDataWidget(
        id: WizardObjectId.background,
        child: widget.background ?? Container(),
      ),
      overlay: WizardParentDataWidget(
        id: WizardObjectId.overlay,
        child: widget.overlay ?? Container(),
      ),
    );
  }
}

// Stack/MultiC