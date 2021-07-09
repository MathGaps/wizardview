import 'package:flutter/material.dart';
import 'package:landingpagecreator/wizard_node.dart';

class Wizard extends Focus {
  const Wizard({
    required Widget child,
    WizardNode? focusNode,
  }) : super(
          child: child,
          focusNode: focusNode,
        );

  @override
  WizardState createState() => WizardState();
}

class WizardState extends State<Focus> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
