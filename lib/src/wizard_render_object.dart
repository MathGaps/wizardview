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
  RenderObject createRenderObject(BuildContext context) {
    return _RenderWizardRenderObject();
  }
}

class _RenderWizardRenderObject extends RenderBox {
  _RenderWizardRenderObject({
    Widget? background,
    Widget? overlay,
  })  : _background = background,
        _overlay = overlay;

  Widget? _background;
  Widget? _overlay;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }
}
