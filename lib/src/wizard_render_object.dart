import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///! This is a Widget, not a RenderObject
class WizardRenderObject extends MultiChildRenderObjectWidget {
  WizardRenderObject({
    required Widget child,
    required Widget background,
    required Widget overlay,
    required this.active,
    Key? key,
  }) : super(
          key: key,
          children: [
            background,
            child,
            overlay,
          ],
        );

  final bool active;

  @override
  _RenderWizardRenderObject createRenderObject(BuildContext context) {
    return _RenderWizardRenderObject(active: active);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWizardRenderObject renderObject,
  ) {
    renderObject..active = active;
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
  _RenderWizardRenderObject({required bool active}) : _active = active;

  bool _active;
  bool get active => _active;
  set active(bool active) {
    if (_active == active) return;
    _active = active;
  }

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

      switch (childParentData.id) {
        case WizardObjectId.child:
          child.paint(context, offset);
          break;
        case WizardObjectId.background:
          // ? Assuming background covers the whole screen, base it at [Offset.zero]
          if (active) child.paint(context, Offset.zero);
          break;
        case WizardObjectId.overlay:
          if (active) child.paint(context, offset - Offset(12.5, 12.5));
          break;
        case null:
          break;
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

      /// ! Need to think about this. If we change the size beyond the size of the child,
      /// it'll cause inconsistencies with how the child is rendered
      if (childParentData.id == WizardObjectId.child) {
        width = max(child.size.width, width);
        height = max(child.size.height, height);
      }

      child = childParentData.nextSibling;
    }

    return Size(width, height);
  }
}
