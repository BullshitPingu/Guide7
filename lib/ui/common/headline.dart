import 'package:flutter/widgets.dart';

/// Headline widget.
class Headline extends StatelessWidget {
  /// Text to show in the headline.
  final String text;

  /// Create headline widget showing [text].
  Headline(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(fontFamily: "Raleway"),
        textScaleFactor: 3.0,
      );
}
