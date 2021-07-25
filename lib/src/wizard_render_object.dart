import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'wizard_parent_data_widget.dart';

class WizardRenderObjectWidget extends MultiChildRenderObjectWidget {
  WizardRenderObjectWidget({
    required Widget child,
    required Widget background,
    required List<Widget> overlays,
    required this.active,
    required Offset childOffset,
    Key? key,
  })  : _childOffset = childOffset,
        super(
          key: key,
          children: [
            WizardParentDataWidget(
                id: WizardObjectId.background, child: background),
            WizardParentDataWidget(
              id: WizardObjectId.child,
              child: child,
              offset: childOffset,
            ),
            ...overlays
          ],
        );

  final bool active;
  final Offset _childOffset;

  @override
  _RenderWizardRenderObject createRenderObject(BuildContext context) {
    return _RenderWizardRenderObject(
      active: active,
      childOffset: _childOffset,
      context: context,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWizardRenderObject renderObject,
  ) {
    renderObject
      ..active = active
      ..childOffset = _childOffset;
  }
}

enum WizardObjectId {
  child,
  background,
  overlay,
}

class WizardParentData extends ContainerBoxParentData<RenderBox> {
  WizardObjectId? id;
  Alignment? alignment;
  Size? size;
  Offset? overlayOffset;
  Size? overlaySize;
}

class _RenderWizardRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WizardParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WizardParentData> {
  _RenderWizardRenderObject({
    required bool active,
    required BuildContext context,
    required Offset childOffset,
  })  : _active = active,
        _childOffset = childOffset,
        _screenSize = MediaQuery.of(context).size;

  bool _active;
  bool get active => _active;
  set active(bool active) {
    if (_active == active) return;
    _active = active;
  }

  Size _screenSize;

  Offset _childOffset;
  Offset get childOffset => _childOffset;
  set childOffset(Offset childOffset) {
    if (_childOffset == childOffset) return;
    _childOffset = childOffset;
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
          child.paint(context, childParentData.offset);
          break;
        case WizardObjectId.background:
          if (active) child.paint(context, Offset.zero);
          break;
        case WizardObjectId.overlay:
          if (active) {
            if (childParentData.alignment == null) {
              child.paint(
                  context, childParentData.overlayOffset ?? Offset.zero);
            } else {
              child.paint(
                context,
                childParentData.offset,
              );
            }
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
    late Size childSize;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as WizardParentData;

      if (childParentData.id == WizardObjectId.child) {
        childSize = childParentData.size!;
      }

      if (childParentData.id == WizardObjectId.overlay) {
        if (childParentData.offset == _childOffset) {
          Offset centeringOffset = Offset(
              -childParentData.size!.width / 2 + childSize.width / 2,
              -childParentData.size!.height / 2 + childSize.height / 2);
          final alignmentFactor = Size(
              childParentData.size!.width / 2 + childSize.width / 2,
              childParentData.size!.height / 2 + childSize.height / 2);

          childParentData.offset += centeringOffset +
              Offset(
                childParentData.alignment!.x * alignmentFactor.width,
                childParentData.alignment!.y * alignmentFactor.height,
              );
        }
      }

      child = childParentData.nextSibling;
    }
  }

  Size _computeLayoutSize({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    // double height = 0, width = 0;
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
      // if (childParentData.id == WizardObjectId.child) {
      //   width = max(child.size.width, width);
      //   height = max(child.size.height, height);
      // }

      // ! Size is now set to the screen size for easier [hitTest]ing purposes
      // if (childParentData.id != WizardObjectId.background) {
      //   width = max(child.size.width, width);
      //   height = max(child.size.height, height);
      // }

      childParentData.size = child.size;
      child = childParentData.nextSibling;
    }

    return _screenSize;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
