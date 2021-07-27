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
    this.childConstraints,
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
  final Size? childConstraints;

  @override
  _RenderWizardRenderObject createRenderObject(BuildContext context) {
    return _RenderWizardRenderObject(
      active: active,
      childOffset: _childOffset,
      context: context,
      childConstraints: childConstraints,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWizardRenderObject renderObject,
  ) {
    renderObject
      ..active = active
      ..childOffset = _childOffset
      ..childConstraints = childConstraints;
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
  Size? constraints;
}

class _RenderWizardRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WizardParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WizardParentData> {
  _RenderWizardRenderObject({
    required bool active,
    required BuildContext context,
    required Offset childOffset,
    required Size? childConstraints,
  })  : _active = active,
        _childOffset = childOffset,
        _childConstraints = childConstraints,
        _screenSize = MediaQuery.of(context).size;

  bool _active;
  bool get active => _active;
  set active(bool active) {
    if (_active == active) return;
    _active = active;
  }

  Size? _childConstraints;
  Size? get childConstraints => _childConstraints;
  set childConstraints(Size? childConstraints) {
    if (_childConstraints == childConstraints) return;
    _childConstraints = childConstraints;
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
            child.paint(
              context,
              childParentData.offset,
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
    late Size childSize;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as WizardParentData;

      if (childParentData.id == WizardObjectId.child) {
        childSize = childParentData.size!;
      }

      if (childParentData.id == WizardObjectId.overlay) {
        if (childParentData.alignment != null) {
          Offset centeringOffset = Offset(
              -childParentData.size!.width / 2 + childSize.width / 2,
              -childParentData.size!.height / 2 + childSize.height / 2);
          final alignmentFactor = Size(
              childParentData.size!.width / 2 + childSize.width / 2,
              childParentData.size!.height / 2 + childSize.height / 2);

          childParentData.offset = _childOffset +
              centeringOffset +
              Offset(
                childParentData.alignment!.x * alignmentFactor.width,
                childParentData.alignment!.y * alignmentFactor.height,
              );
        } else {
          childParentData.offset = childParentData.overlayOffset ?? Offset.zero;
        }
      }

      child = childParentData.nextSibling;
    }
  }

  Size _computeLayoutSize({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    RenderBox? child = firstChild;

    while (child != null) {
      final childParentData = child.parentData! as WizardParentData;

      if (!dry) {
        if (childParentData.id == WizardObjectId.child &&
            _childConstraints != null) {
          child.layout(
            BoxConstraints.tightFor(
                width: childParentData.constraints!.width,
                height: childParentData.constraints!.height),
            parentUsesSize: true,
          );
        } else {
          child.layout(
            BoxConstraints(maxWidth: constraints.maxWidth),
            parentUsesSize: true,
          );
        }
      } else {
        child.getDryLayout(
          BoxConstraints(maxWidth: constraints.maxWidth),
        );
      }

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
