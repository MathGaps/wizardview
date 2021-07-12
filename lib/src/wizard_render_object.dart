import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WizardRenderObject extends MultiChildRenderObjectWidget {
  WizardRenderObject({
    required Widget child,
    required Widget background,
    required Widget overlay,
    Key? key,
  }) : super(
          key: key,
          children: [
            background,
            child,
            overlay,
          ],
        );

  @override
  _RenderWizardRenderObject createRenderObject(BuildContext context) {
    return _RenderWizardRenderObject();
  }
}

enum WizardObjectId {
  child,
  background,
  overlay,
}

class WizardParentData extends ContainerBoxParentData<RenderBox> {
  WizardObjectId? id;
}

class _RenderWizardRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WizardParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WizardParentData> {
  /// ParentData
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! WizardParentData) {
      child.parentData = WizardParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as WizardParentData;

      // ? Just for the snippets
      if (childParentData.id == WizardObjectId.background) {
        // ? Assuming background covers the whole screen, base it at [Offset.zero]
        child.paint(context, Offset.zero);
      } else if (childParentData.id == WizardObjectId.overlay) {
        child.paint(context, offset - Offset(12.5, 12.5));
      } else {
        child.paint(context, offset);
      }

      child = childParentData.nextSibling;
    }
  }

  /// Layout
  @override
  void performLayout() {
    size = _computeLayoutSize(
      constraints: constraints,
      dry: false,
    );
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as WizardParentData;

      child = childParentData.nextSibling;
    }
  }

  Size _computeLayoutSize({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    double height = 0, width = 0;
    RenderBox? child = firstChild;

    while (child != null) {
      final childParentData = child.parentData! as WizardParentData;

      if (!dry) {
        child.layout(
          BoxConstraints(maxWidth: constraints.maxWidth),
          parentUsesSize: true,
        );
      } else {
        child.getDryLayout(
          BoxConstraints(maxWidth: constraints.maxWidth),
        );
      }

      // TODO: Update this to account for the size of the overlay for better hitTesting
      if (childParentData.id == WizardObjectId.child) {
        height = child.size.height;
        width = child.size.width;
      }

      child = childParentData.nextSibling;
    }

    return Size(width, height);
  }
}
