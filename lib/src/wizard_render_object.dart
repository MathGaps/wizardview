import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wizardview/src/enums/overlay_anchor.dart';

///! This is a Widget, not a RenderObject
class WizardRenderObject extends MultiChildRenderObjectWidget {
  WizardRenderObject({
    required Widget child,
    required Widget background,
    required Widget overlay,
    required this.active,
    required this.overlayAnchor,
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
  final OverlayAnchor overlayAnchor;

  @override
  _RenderWizardRenderObject createRenderObject(BuildContext context) {
    return _RenderWizardRenderObject(
      active: active,
      overlayAnchor: overlayAnchor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWizardRenderObject renderObject,
  ) {
    renderObject
      ..active = active
      ..overlayAnchor = overlayAnchor;
  }
}

enum WizardObjectId {
  child,
  background,
  overlay,
}

class WizardParentData extends ContainerBoxParentData<RenderBox> {
  WizardObjectId? id;
  Size? size;
}

class _RenderWizardRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WizardParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WizardParentData> {
  _RenderWizardRenderObject({
    required bool active,
    required OverlayAnchor overlayAnchor,
  })  : _active = active,
        _overlayAnchor = overlayAnchor;

  bool _active;
  bool get active => _active;
  set active(bool active) {
    if (_active == active) return;
    _active = active;
  }

  OverlayAnchor _overlayAnchor;
  OverlayAnchor get overlayAnchor => _overlayAnchor;
  set overlayAnchor(OverlayAnchor overlayAnchor) {
    if (_overlayAnchor == overlayAnchor) return;

    _overlayAnchor = overlayAnchor;
    markNeedsLayout();
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
          if (active) {
            late Offset overlayOffset;

            switch (overlayAnchor) {
              case OverlayAnchor.topLeft:
                overlayOffset =
                    Offset(-childParentData.size!.width, -size.height);
                break;
              case OverlayAnchor.topCenter:
                overlayOffset = Offset(
                  -childParentData.size!.width / 2 + size.width / 2,
                  -size.height,
                );
                break;
              case OverlayAnchor.topRight:
                overlayOffset = Offset(size.width, -size.height);
                break;
              case OverlayAnchor.centerLeft:
                overlayOffset = Offset(
                  -childParentData.size!.width,
                  -childParentData.size!.height / 2 + size.height / 2,
                );
                break;
              case OverlayAnchor.center:
                overlayOffset = Offset(
                  -childParentData.size!.width / 2 + size.width / 2,
                  -childParentData.size!.height / 2 + size.height / 2,
                );
                break;
              case OverlayAnchor.centerRight:
                overlayOffset = Offset(
                  size.width,
                  -childParentData.size!.height / 2 + size.height / 2,
                );
                break;
              case OverlayAnchor.bottomLeft:
                overlayOffset =
                    Offset(-childParentData.size!.width, size.height);
                break;
              case OverlayAnchor.bottomCenter:
                overlayOffset = Offset(
                    -childParentData.size!.width / 2 + size.width / 2,
                    size.height);
                break;
              case OverlayAnchor.bottomRight:
                overlayOffset = Offset(size.width, size.height);
                break;
            }

            child.paint(
              context,
              offset + overlayOffset,
            );
          }
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

      childParentData.size = child.size;
      child = childParentData.nextSibling;
    }

    return Size(width, height);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
