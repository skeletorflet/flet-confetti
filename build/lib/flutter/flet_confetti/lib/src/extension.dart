import 'package:flet/flet.dart';
import 'package:flutter/cupertino.dart';

import 'confetti.dart';

class Extension extends FletExtension {
  @override
  Widget? createWidget(Key? key, Control control) {
    switch (control.type) {
      case "Confetti":
        return ConfettiControl(control: control);
      default:
        return null;
    }
  }
}
