import 'package:flutter/cupertino.dart';
import 'package:wizardview/src/wizard_render_object.dart';

class WizardParentDataWidget extends ParentDataWidget<WizardParentData> {
  //? Maybe break up these so that we have a builder ?
  WizardParentDataWidget({
    required Widget child,
    required this.id,
    this.alignment = Alignment.bottomRight,
    this.offset,
    this.overlayOffset,
    this.overlaySize,
    Key? key,
  })  : assert((overlayOffset == null &&
                overlaySize == null &&
                alignment != null) ||
            (overlayOffset != null &&
                overlaySize != null &&
                alignment == null)),

        /// ? I feel like this boolean can be condensed, it's bugging me

        super(
          key: key,
          child: child,
        );

  final WizardObjectId id;
  // Only used by overlays to positioned themselves according to the actual `child`
  final Alignment? alignment;
  final Offset? offset;
  final Offset? overlayOffset;
  final Size? overlaySize;

  /// TODO: apply overlayOffset etc
  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as WizardParentData;

    if (parentData.id != id) {
      parentData.id = id;
    }

    if (parentData.alignment != alignment) {
      parentData.alignment = alignment;
    }

    if (parentData.offset != offset) {
      parentData.offset = offset ?? Offset.zero;
    }

    final targetObject = renderObject.parent;

    if (targetObject is RenderObject) {
      targetObject.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => WizardRenderObjectWidget;
}
