// In a new file named rtl_fix.dart

import 'package:flutter/material.dart';

class RTLFix {
  static Widget number(String text, {TextStyle? style}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(text, style: style),
    );
  }
}
