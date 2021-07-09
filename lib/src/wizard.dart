import 'package:flutter/material.dart';

import 'wizard_node.dart';

class Wizard extends Focus {
  const Wizard({
    required Widget child,
    WizardNode? focusNode,
  }) : super(
          child: child,
          focusNode: focusNode,
        );

  @override
  _WizardState createState() => _WizardState();
}

class _WizardState extends _FocusState {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
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
