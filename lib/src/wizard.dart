import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wizardview/src/mixins/wizard_node_mixin.dart';
import 'package:wizardview/src/wizard_overlay.dart';
import 'package:wizardview/src/wizard_parent_data_widget.dart';
import 'package:wizardview/src/wizard_render_object.dart';
import 'package:wizardview/wizardview.dart';

import 'wizard_scope.dart';

class WizardNode = FocusNode with WizardNodeMixin;

typedef WizardBuilder = Widget Function(WizardScopeState state, BuildContext context);

/// Represents an indiviudal node in the Feature Discovery.
///
/// [Wizard] manages a [FocusNode], which, when instantiated; should be a
/// descendant of a [WizardScope].
class Wizard extends StatefulWidget {
  const Wizard({
    required this.builder,
    required List<WizardOverlay>? overlays,
    this.activeBuilder,
    this.background,
    this.onNodeStart,
    this.onNodeEnd,
    this.onPrev,
    this.renderChild = true,
    this.tightChildSize = false,
    this.debugLabel,
    this.context,
    Key? key,
  })  :

        ///! This list is not growable => overlays cannot be added after Wizard
        ///! construction.
        overlays = overlays ?? const [],
        super(key: key);

  final BuildContext? context;

  /// The builder for the widget to be focused.
  final WizardBuilder builder;

  /// An optional [Widget] to be shown instead of `child` when this [Wizard] is
  /// in focus
  final WizardBuilder? activeBuilder;

  /// Flag for if this [Wizard] should render the focused child
  final bool renderChild;

  /// A list of [WizardOverlay] objects which contain rendering information
  /// about the overlays that you want to display
  final List<WizardOverlay> overlays;

  /// The widget to be shown behind the [child] and the [overlays]. Typically,
  /// an empty [Container] with `color: Colors.black12` to emulate a dimming
  /// effect. Can be set for all [Wizard] children through its parent [WizardScope]
  final Widget? background;

  /// Callback executed after focusing on a new node
  final WizardCallback? onNodeStart;

  /// Callback executed before moving focus to the next node
  final WizardCallback? onNodeEnd;

  /// Callback executed if `prev()` was called on the parent [WizardScope]
  final WizardCallback? onPrev;

  /// Set to `true` if focused child is unbounded
  final bool tightChildSize;

  final String? debugLabel;

  @override
  WizardState createState() => WizardState();
}

class WizardState extends State<Wizard> {
  late final WizardNode _wizardNode;
  late final WizardCallback? _onPrev;
  WizardCallback? get onPrev => _onPrev;

  late FocusAttachment _focusAttachment;
  late Widget _localWidget;
  OverlayEntry? _overlayEntry;

  bool _active = false;
  bool get active => _active;
  set active(bool active) {
    if (_active == active) return;
    setState(() => _active = active);
  }

  bool _shouldShowBackground = true;
  bool get shouldShowBackground => _shouldShowBackground;

  /// Whether the [background] should be displayed in the [OverlayEntry].
  /// Using this over setting [background] to null is more efficient and less condusive to error,
  /// as we don't have to reinstantiate the [WizardRenderObjectWidget].
  set shouldShowBackground(bool? shouldShow) {
    if (shouldShow == _shouldShowBackground) return;
    _shouldShowBackground = shouldShow ?? true;
    _overlayEntry?.markNeedsBuild();
  }

  WizardScopeState get _wizardScopeState => context.findAncestorStateOfType<WizardScopeState>()!;

  @override
  void initState() {
    super.initState();
    _wizardNode = WizardNode(debugLabel: widget.debugLabel ?? 'WizardNode');
    _onPrev = widget.onPrev;
    _focusAttachment = _wizardNode.attach(_wizardScopeState.context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusAttachment.reparent();
  }

  @override
  void dispose() {
    _wizardNode.dispose();
    super.dispose();
  }

  Future<void> onNodeStart() async {
    setState(() => active = true);
    await widget.onNodeStart?.call();
  }

  Future<void> onNodeEnd() async {
    await widget.onNodeEnd?.call();
    setState(() => active = false);
  }

  OverlayEntry overlayEntry({Widget? background}) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return Positioned(
          top: 0,
          left: 0,
          child: Material(
            color: Colors.transparent,
            child: WizardRenderObjectWidget(
              active: active,
              // `overlays` have to pass their alignments inside the
              // [WizardRenderObjectWidget]
              showBackground: shouldShowBackground,
              overlays: widget.overlays.map((overlay) {
                final BuiltWizardOverlay? builtWizardOverlay = overlay.builder?.call(
                  _wizardScopeState,
                  _wizardNode.offset,
                  _wizardNode.size,
                );

                return WizardParentDataWidget(
                  id: WizardObjectId.overlay,
                  alignment: overlay.alignment,
                  overlayOffset: builtWizardOverlay?.offset,
                  overlaySize: builtWizardOverlay?.size,
                  child: builtWizardOverlay?.child ?? overlay.child!,
                  offset: _wizardNode.offset,
                  // constraints: widget.tightChildSize ? context.size : null,
                );
              }).toList(),
              child: widget.activeBuilder?.call(_wizardScopeState, overlayContext) ?? _localWidget,
              childOffset: _wizardNode.offset,
              background: widget.background ??
                  _wizardScopeState.background ??
                  Container(child: Text('[WizardScopeState] not found')),
            ),
          ),
        );
      },
    );
    return _overlayEntry!;
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();

    final localWidget = _localWidget = widget.builder(_wizardScopeState, context);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      /// This implies that builds to `overlayEntry` will occur with 1 frame of lag.
      _overlayEntry?.markNeedsBuild();
    });

    return Opacity(
      opacity: active ? 0 : 1,
      child: Focus(
        focusNode: _wizardNode,
        child: localWidget,
      ),
    );
  }
}
