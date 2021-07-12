import 'package:flutter/cupertino.dart';
import 'package:wizardview/src/wizard.dart';

/// This mixin is just used to differentiate [WizardNode] from [FocusNode] in
/// equality statements
mixin WizardNodeMixin on FocusNode {}
