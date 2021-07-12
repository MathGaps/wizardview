import 'package:flutter/cupertino.dart';

class WizardRenderObject extends SingleChildRenderObjectWidget {
  WizardRenderObject({
    required Widget child,
    this.background,
    this.overlay,
    Key? key,
  }) : super(child: child, key: key);

  final Widget? background;
  final Widget? overlay;

  @override
  _RenderWizardRenderObject createRenderObject(BuildContext context) {
    return _RenderWizardRenderObject(background: background, overlay: overlay);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderWizardRenderObject renderObject) {
    renderObject
      .._background = background
      .._overlay = overlay;
  }
}

class _RenderWizardRenderObject extends RenderBox {
  _RenderWizardRenderObject({
    Widget? background,
    Widget? overlay,
  })  : _background = background,
        _overlay = overlay;

  Widget? _background;
  Widget? get background => _background;
  set background(Widget? value) {
    if (value != _background) {
      background = value;
      markNeedsPaint();
    }
  }

  Widget? _overlay;
  Widget? get overlay => _overlay;
  set overlay(Widget? value) {
    if (value != _overlay) {
      overlay = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }

  @override
  void performLayout() {
    size = Size(100, 100);
    // super.performLayout();
  }
}
