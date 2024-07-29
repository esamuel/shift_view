import 'package:flutter/material.dart';

class DirectionalNumber extends StatelessWidget {
  final String number;
  final TextStyle? style;

  const DirectionalNumber(this.number, {Key? key, this.style})
      : super(key: key);

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
