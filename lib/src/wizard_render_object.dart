import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wizardview/src/wizard_parent_data_widget.dart';

///! This is a Widget, not a RenderObject
class WizardRenderObject extends MultiChildRenderObjectWidget {
  WizardRenderObject({
    required Widget child,
    required Widget background,
    // required Widget overlay,
    required this.active,
    required this.overlayAlignment,
    Key? key,
  }) : super(
          key: key,
          children: [
            WizardParentDataWidget(
              id: WizardObjectId.background,
              child: RepaintBoundary(child: background),
            ),
            // WizardParentDataWidget(
            //   id: WizardObjectId.overlay,
            //   child: RepaintBoundary(child: overlay),
            // ),
            WizardParentDataWidget(
              id: WizardObjectId.child,
              child: RepaintBoundary(child: child),
            ),
          ],
        );

  final bool active;
  final Alignment overlayAlignment;

  @override
  _RenderWizardRenderObject createRenderObject(BuildContext context) {
    return _RenderWizardRenderObject(
      active: active,
      overlayAlignment: overlayAlignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWizardRenderObject renderObject,
  ) {
    renderObject
      ..active = active
      ..overlayAlignment = overlayAlignment;
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
    required Alignment overlayAlignment,
  })  : _active = active,
        _overlayAlignment = overlayAlignment;

  bool _active;
  bool get active => _active;
  set active(bool active) {
    if (_active == active) return;
    _active = active;
    markNeedsPaint();
  }

  Alignment _overlayAlignment;
  Alignment get overlayAlignment => _overlayAlignment;
  set overlayAlignment(Alignment overlayAlignment) {
    if (_overlayAlignment == overlayAlignment) return;

    _overlayAlignment = overlayAlignment;
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

            // switch (overlayAlignment) {
            //   case Alignment.topLeft:
            //     overlayOffset =
            //         Offset(-childParentData.size!.width, -size.height);
            //     break;
            //   case Alignment.topCenter:
            //     overlayOffset = Offset(
            //       -childParentData.size!.width / 2 + size.width / 2,
            //       -size.height,
            //     );
            //     break;
            //   case Alignment.topRight:
            //     overlayOffset = Offset(size.width, -size.height);
            //     break;
            //   case Alignment.centerLeft:
            //     overlayOffset = Offset(
            //       -childParentData.size!.width,
            //       -childParentData.size!.height / 2 + size.height / 2,
            //     );
            //     break;
            //   case Alignment.center:
            //     overlayOffset = Offset(
            //       -childParentData.size!.width / 2 + size.width / 2,
            //       -childParentData.size!.height / 2 + size.height / 2,
            //     );
            //     break;
            //   case Alignment.centerRight:
            //     overlayOffset = Offset(
            //       size.width,
            //       -childParentData.size!.height / 2 + size.height / 2,
            //     );
            //     break;
            //   case Alignment.bottomLeft:
            //     overlayOffset =
            //         Offset(-childParentData.size!.width, size.height);
            //     break;
            //   case Alignment.bottomCenter:
            //     overlayOffset = Offset(
            //         -childParentData.size!.width / 2 + size.width / 2,
            //         size.height);
            //     break;
            //   case Alignment.bottomRight:
            //     overlayOffset = Offset(size.width, size.height);
            //     break;
            // }
            final alignmentFactor = Size(
                childParentData.size!.width / 2 + size.width / 2,
                childParentData.size!.height / 2 + size.height / 2);
            overlayOffset = Offset(
                -childParentData.size!.width / 2 + size.width / 2,
                -childParentData.size!.height / 2 + size.height / 2);

            child.paint(
              context,
              offset +
                  overlayOffset +
                  Offset(
                    overlayAlignment.x * alignmentFactor.width,
                    overlayAlignment.y * alignmentFactor.height,
                  ),
              // offset,
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

      if (childParentData.id == WizardObjectId.overlay) {
        childParentData.offset -= Offset(
            childParentData.size!.width / 2, childParentData.size!.height / 2);
      }

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

      ///! Need to think about this. If we change the size beyond the size of the child,
      ///! it'll cause inconsistencies with how the child is rendered
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
