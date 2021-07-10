import 'package:flutter/cupertino.dart';

//TODO: #1 Documentation on WizardScope

class WizardScope extends StatefulWidget {
  const WizardScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  _WizardScopeState createState() => _WizardScopeState();
}

class _WizardScopeState extends State<WizardScope> {
  final FocusScopeNode node = FocusScopeNode(debugLabel: 'WizardScope');

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: node,
      child: widget.child,
    );
  }
}
