import 'package:flutter/cupertino.dart';
import 'package:wizardview/src/wizard_scope.dart';

/// This mixin is just used to differentiate [WizardScopeNode] from [FocusScopeNode] in
/// equality statements
mixin WizardScopeNodeMixin on FocusScopeNode {}
