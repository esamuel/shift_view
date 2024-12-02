import 'package:flutter/material.dart';

class DirectionalNumber extends StatelessWidget {
  final String number;
  final TextStyle? style;

  const DirectionalNumber(this.number, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        number,
        style: style,
      ),
    );
  }
}
