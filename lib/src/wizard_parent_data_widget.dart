import 'package:flutter/cupertino.dart';
import 'package:wizardview/src/wizard_render_object.dart';

class WizardParentDataWidget extends ParentDataWidget<WizardParentData> {
  WizardParentDataWidget({
    required Widget child,
    required this.id,
    Key? key,
  }) : super(
          key: key,
          child: child,
        );

  final WizardObjectId id;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as WizardParentData;

    if (parentData.id != id) {
      parentData.id = id;
    }

    final targetObject = renderObject.parent;

    if (targetObject is RenderObject) {
      targetObject.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => WizardRenderObjectWidget;
}
