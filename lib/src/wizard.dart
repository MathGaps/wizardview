import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'wizard_node.dart';

///? Having second thoughts about this. Maybe we should just extend [Focus].

class Focus extends StatefulWidget {
  /// Creates a widget that manages a [FocusNode].
  ///
  /// The [child] argument is required and must not be null.
  ///
  /// The [autofocus] argument must not be null.
  const Focus({
    Key? key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onKey,
    this.debugLabel,
    this.canRequestFocus,
    this.descendantsAreFocusable = true,
    this.skipTraversal,
    this.includeSemantics = true,
  }) : super(key: key);

  /// A debug label for this widget.
  ///
  /// Not used for anything except to be printed in the diagnostic output from
  /// [toString] or [toStringDeep]. Also unused if a [focusNode] is provided,
  /// since that node can have its own [FocusNode.debugLabel].
  ///
  /// To get a string with the entire tree, call [debugDescribeFocusTree]. To
  /// print it to the console call [debugDumpFocusTree].
  ///
  /// Defaults to null.
  final String? debugLabel;

  /// The child widget of this [Focus].
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Handler for keys pressed when this object or one of its children has
  /// focus.
  ///
  /// Key events are first given to the [FocusNode] that has primary focus, and
  /// if its [onKey] method return false, then they are given to each ancestor
  /// node up the focus hierarchy in turn. If an event reaches the root of the
  /// hierarchy, it is discarded.
  ///
  /// This is not the way to get text input in the manner of a text field: it
  /// leaves out support for input method editors, and doesn't support soft
  /// keyboards in general. For text input, consider [TextField],
  /// [EditableText], or [CupertinoTextField] instead, which do support these
  /// things.
  final FocusOnKeyCallback? onKey;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final ValueChanged<bool>? onFocusChange;

  /// {@template flutter.widgets.Focus.autofocus}
  /// True if this widget will be selected as the initial focus when no other
  /// node in its scope is currently focused.
  ///
  /// Ideally, there is only one widget with autofocus set in each [FocusScope].
  /// If there is more than one widget with autofocus set, then the first one
  /// added to the tree will get focus.
  ///
  /// Must not be null. Defaults to false.
  /// {@endtemplate}
  final bool autofocus;

  /// {@template flutter.widgets.Focus.focusNode}
  /// An optional focus node to use as the focus node for this widget.
  ///
  /// If one is not supplied, then one will be automatically allocated, owned,
  /// and managed by this widget. The widget will be focusable even if a
  /// [focusNode] is not supplied. If supplied, the given `focusNode` will be
  /// _hosted_ by this widget, but not owned. See [FocusNode] for more
  /// information on what being hosted and/or owned implies.
  ///
  /// Supplying a focus node is sometimes useful if an ancestor to this widget
  /// wants to control when this widget has the focus. The owner will be
  /// responsible for calling [FocusNode.dispose] on the focus node when it is
  /// done with it, but this widget will attach/detach and reparent the node
  /// when needed.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// Sets the [FocusNode.skipTraversal] flag on the focus node so that it won't
  /// be visited by the [FocusTraversalPolicy].
  ///
  /// This is sometimes useful if a [Focus] widget should receive key events as
  /// part of the focus chain, but shouldn't be accessible via focus traversal.
  ///
  /// This is different from [FocusNode.canRequestFocus] because it only implies
  /// that the widget can't be reached via traversal, not that it can't be
  /// focused. It may still be focused explicitly.
  final bool? skipTraversal;

  /// {@template flutter.widgets.Focus.includeSemantics}
  /// Include semantics information in this widget.
  ///
  /// If true, this widget will include a [Semantics] node that indicates the
  /// [SemanticsProperties.focusable] and [SemanticsProperties.focused]
  /// properties.
  ///
  /// It is not typical to set this to false, as that can affect the semantics
  /// information available to accessibility systems.
  ///
  /// Must not be null, defaults to true.
  /// {@endtemplate}
  final bool includeSemantics;

  /// {@template flutter.widgets.Focus.canRequestFocus}
  /// If true, this widget may request the primary focus.
  ///
  /// Defaults to true.  Set to false if you want the [FocusNode] this widget
  /// manages to do nothing when [FocusNode.requestFocus] is called on it. Does
  /// not affect the children of this node, and [FocusNode.hasFocus] can still
  /// return true if this node is the ancestor of the primary focus.
  ///
  /// This is different than [Focus.skipTraversal] because [Focus.skipTraversal]
  /// still allows the widget to be focused, just not traversed to.
  ///
  /// Setting [FocusNode.canRequestFocus] to false implies that the widget will
  /// also be skipped for traversal purposes.
  ///
  /// See also:
  ///
  /// * [FocusTraversalGroup], a widget that sets the traversal policy for its
  ///   descendants.
  /// * [FocusTraversalPolicy], a class that can be extended to describe a
  ///   traversal policy.
  /// {@endtemplate}
  final bool? canRequestFocus;

  /// {@template flutter.widgets.Focus.descendantsAreFocusable}
  /// If false, will make this widget's descendants unfocusable.
  ///
  /// Defaults to true. Does not affect focusability of this node (just its
  /// descendants): for that, use [FocusNode.canRequestFocus].
  ///
  /// If any descendants are focused when this is set to false, they will be
  /// unfocused. When `descendantsAreFocusable` is set to true again, they will
  /// not be refocused, although they will be able to accept focus again.
  ///
  /// Does not affect the value of [FocusNode.canRequestFocus] on the
  /// descendants.
  ///
  /// See also:
  ///
  /// * [ExcludeFocus], a widget that uses this property to conditionally
  ///   exclude focus for a subtree.
  /// * [FocusTraversalGroup], a widget used to group together and configure the
  ///   focus traversal policy for a widget subtree that has a
  ///   `descendantsAreFocusable` parameter to conditionally block focus for a
  ///   subtree.
  /// {@endtemplate}
  final bool descendantsAreFocusable;

  /// Returns the [focusNode] of the [Focus] that most tightly encloses the
  /// given [BuildContext].
  ///
  /// If no [Focus] node is found before reaching the nearest [FocusScope]
  /// widget, or there is no [Focus] widget in scope, then this method will
  /// throw an exception.
  ///
  /// The `context` and `scopeOk` arguments must not be null.
  ///
  /// Calling this function creates a dependency that will rebuild the given
  /// context when the focus changes.
  ///
  /// See also:
  ///
  ///  * [maybeOf], which is similar to this function, but will return null
  ///    instead of throwing if it doesn't find a [Focus] node.
  static FocusNode of(BuildContext context, {bool scopeOk = false}) {
    assert(context != null);
    assert(scopeOk != null);
    final _FocusMarker? marker =
        context.dependOnInheritedWidgetOfExactType<_FocusMarker>();
    final FocusNode? node = marker?.notifier;
    assert(() {
      if (node == null) {
        throw FlutterError(
          'Focus.of() was called with a context that does not contain a Focus widget.\n'
          'No Focus widget ancestor could be found starting from the context that was passed to '
          'Focus.of(). This can happen because you are using a widget that looks for a Focus '
          'ancestor, and do not have a Focus widget descendant in the nearest FocusScope.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    assert(() {
      if (!scopeOk && node is FocusScopeNode) {
        throw FlutterError(
          'Focus.of() was called with a context that does not contain a Focus between the given '
          'context and the nearest FocusScope widget.\n'
          'No Focus ancestor could be found starting from the context that was passed to '
          'Focus.of() to the point where it found the nearest FocusScope widget. This can happen '
          'because you are using a widget that looks for a Focus ancestor, and do not have a '
          'Focus widget ancestor in the current FocusScope.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return node!;
  }

  /// Returns the [focusNode] of the [Focus] that most tightly encloses the
  /// given [BuildContext].
  ///
  /// If no [Focus] node is found before reaching the nearest [FocusScope]
  /// widget, or there is no [Focus] widget in scope, then this method will
  /// return null.
  ///
  /// The `context` and `scopeOk` arguments must not be null.
  ///
  /// Calling this function creates a dependency that will rebuild the given
  /// context when the focus changes.
  ///
  /// See also:
  ///
  ///  * [of], which is similar to this function, but will throw an exception if
  ///    it doesn't find a [Focus] node instead of returning null.
  static FocusNode? maybeOf(BuildContext context, {bool scopeOk = false}) {
    assert(context != null);
    assert(scopeOk != null);
    final _FocusMarker? marker =
        context.dependOnInheritedWidgetOfExactType<_FocusMarker>();
    final FocusNode? node = marker?.notifier;
    if (node == null) {
      return null;
    }
    if (!scopeOk && node is FocusScopeNode) {
      return null;
    }
    return node;
  }

  /// Returns true if the nearest enclosing [Focus] widget's node is focused.
  ///
  /// A convenience method to allow build methods to write:
  /// `Focus.isAt(context)` to get whether or not the nearest [Focus] above them
  /// in the widget hierarchy currently has the input focus.
  ///
  /// Returns false if no [Focus] widget is found before reaching the nearest
  /// [FocusScope], or if the root of the focus tree is reached without finding
  /// a [Focus] widget.
  ///
  /// Calling this function creates a dependency that will rebuild the given
  /// context when the focus changes.
  static bool isAt(BuildContext context) =>
      Focus.maybeOf(context)?.hasFocus ?? false;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(StringProperty('debugLabel', debugLabel, defaultValue: null));
    properties.add(FlagProperty('autofocus',
        value: autofocus, ifTrue: 'AUTOFOCUS', defaultValue: false));
    properties.add(FlagProperty('canRequestFocus',
        value: canRequestFocus, ifFalse: 'NOT FOCUSABLE', defaultValue: false));
    properties.add(FlagProperty('descendantsAreFocusable',
        value: descendantsAreFocusable,
        ifFalse: 'DESCENDANTS UNFOCUSABLE',
        defaultValue: true));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
        defaultValue: null));
  }

  @override
  _FocusState createState() => _FocusState();
}

class _FocusState extends State<Focus> {
  FocusNode? _internalNode;
  FocusNode get focusNode => widget.focusNode ?? _internalNode!;
  bool? _hasPrimaryFocus;
  bool? _canRequestFocus;
  bool? _descendantsAreFocusable;
  bool _didAutofocus = false;
  FocusAttachment? _focusAttachment;

  @override
  void initState() {
    super.initState();
    _initNode();
  }

  void _initNode() {
    if (widget.focusNode == null) {
      // Only create a new node if the widget doesn't have one.
      // This calls a function instead of just allocating in place because
      // _createNode is overridden in _FocusScopeState.
      _internalNode ??= _createNode();
    }
    focusNode.descendantsAreFocusable = widget.descendantsAreFocusable;
    if (widget.skipTraversal != null) {
      focusNode.skipTraversal = widget.skipTraversal!;
    }
    if (widget.canRequestFocus != null) {
      focusNode.canRequestFocus = widget.canRequestFocus!;
    }
    _canRequestFocus = focusNode.canRequestFocus;
    _descendantsAreFocusable = focusNode.descendantsAreFocusable;
    _hasPrimaryFocus = focusNode.hasPrimaryFocus;
    _focusAttachment = focusNode.attach(context, onKey: widget.onKey);

    // Add listener even if the _internalNode existed before, since it should
    // not be listening now if we're re-using a previous one because it should
    // have already removed its listener.
    focusNode.addListener(_handleFocusChanged);
  }

  FocusNode _createNode() {
    return FocusNode(
      debugLabel: widget.debugLabel,
      canRequestFocus: widget.canRequestFocus ?? true,
      descendantsAreFocusable: widget.descendantsAreFocusable,
      skipTraversal: widget.skipTraversal ?? false,
    );
  }

  @override
  void dispose() {
    // Regardless of the node owner, we need to remove it from the tree and stop
    // listening to it.
    focusNode.removeListener(_handleFocusChanged);
    _focusAttachment!.detach();

    // Don't manage the lifetime of external nodes given to the widget, just the
    // internal node.
    _internalNode?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusAttachment?.reparent();
    _handleAutofocus();
  }

  void _handleAutofocus() {
    if (!_didAutofocus && widget.autofocus) {
      FocusScope.of(context).autofocus(focusNode);
      _didAutofocus = true;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    // The focus node's location in the tree is no longer valid here. But
    // we can't unfocus or remove the node from the tree because if the widget
    // is moved to a different part of the tree (via global key) it should
    // retain its focus state. That's why we temporarily park it on the root
    // focus node (via reparent) until it either gets moved to a different part
    // of the tree (via didChangeDependencies) or until it is disposed.
    _focusAttachment?.reparent();
    _didAutofocus = false;
  }

  @override
  void didUpdateWidget(Focus oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(() {
      // Only update the debug label in debug builds, and only if we own the
      // node.
      if (oldWidget.debugLabel != widget.debugLabel && _internalNode != null) {
        _internalNode!.debugLabel = widget.debugLabel;
      }
      return true;
    }());

    if (oldWidget.focusNode == widget.focusNode) {
      if (widget.onKey != focusNode.onKey) {
        focusNode.onKey = widget.onKey;
      }
      if (widget.skipTraversal != null) {
        focusNode.skipTraversal = widget.skipTraversal!;
      }
      if (widget.canRequestFocus != null) {
        focusNode.canRequestFocus = widget.canRequestFocus!;
      }
      focusNode.descendantsAreFocusable = widget.descendantsAreFocusable;
    } else {
      _focusAttachment!.detach();
      focusNode.removeListener(_handleFocusChanged);
      _initNode();
    }

    if (oldWidget.autofocus != widget.autofocus) {
      _handleAutofocus();
    }
  }

  void _handleFocusChanged() {
    final bool hasPrimaryFocus = focusNode.hasPrimaryFocus;
    final bool canRequestFocus = focusNode.canRequestFocus;
    final bool descendantsAreFocusable = focusNode.descendantsAreFocusable;
    widget.onFocusChange?.call(focusNode.hasFocus);
    if (_hasPrimaryFocus != hasPrimaryFocus) {
      setState(() {
        _hasPrimaryFocus = hasPrimaryFocus;
      });
    }
    if (_canRequestFocus != canRequestFocus) {
      setState(() {
        _canRequestFocus = canRequestFocus;
      });
    }
    if (_descendantsAreFocusable != descendantsAreFocusable) {
      setState(() {
        _descendantsAreFocusable = descendantsAreFocusable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment!.reparent();
    Widget child = widget.child;
    if (widget.includeSemantics) {
      child = Semantics(
        focusable: _canRequestFocus,
        focused: _hasPrimaryFocus,
        child: widget.child,
      );
    }
    return _FocusMarker(
      node: focusNode,
      child: child,
    );
  }
}

class _FocusMarker extends InheritedNotifier<FocusNode> {
  const _FocusMarker({
    Key? key,
    required FocusNode node,
    required Widget child,
  }) : super(key: key, notifier: node, child: child);
}
