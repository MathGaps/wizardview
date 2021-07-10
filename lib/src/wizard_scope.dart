import 'package:flutter/cupertino.dart';
import 'package:wizardview/src/wizard.dart';

class WizardScope {
  const WizardScope({
    required Widget child,
    required this.node,
  });

  final WizardNode node;
}
