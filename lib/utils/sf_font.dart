import 'package:flutter/widgets.dart';

/// USAGE:
/// Text(
//       "Hello SF Pro!",
//       style: SFPro.regular(
//         fontSize: 18,
//         color: Colors.black,
//       ),
//     );
///
///
/// Text(
//   "Bold Text",
//   style: SFPro.bold(fontSize: 20, color: Colors.blue),
// );
//
// Text(
//   "Medium Italic",
//   style: SFPro.mediumItalic(fontSize: 16, color: Colors.grey),
// );
//
// Text(
//   "Ultralight",
//   style: SFPro.ultralight(fontSize: 14, color: Colors.red),
// );
///
class SFPro {
  static const String _fontFamily = 'SFPro';

  static TextStyle font({
    FontWeight? fontWeight,
    FontStyle? style,
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: fontWeight,
      fontStyle: style,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // -------- Font Weights ---------
  static TextStyle ultralight({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w100, fontSize: fontSize, color: color);

  static TextStyle thin({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w200, fontSize: fontSize, color: color);

  static TextStyle light({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w300, fontSize: fontSize, color: color);

  static TextStyle regular({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w400, fontSize: fontSize, color: color);

  static TextStyle medium({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w500, fontSize: fontSize, color: color);

  static TextStyle semibold({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w600, fontSize: fontSize, color: color);

  static TextStyle bold({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w700, fontSize: fontSize, color: color);

  static TextStyle heavy({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w800, fontSize: fontSize, color: color);

  static TextStyle black({double? fontSize, Color? color}) =>
      font(fontWeight: FontWeight.w900, fontSize: fontSize, color: color);

  // -------- Italics ---------
  static TextStyle ultralightItalic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w100,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );

  static TextStyle thinItalic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w200,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );

  static TextStyle lightItalic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w300,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );

  static TextStyle italic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w400,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );

  static TextStyle mediumItalic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w500,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );

  static TextStyle semiboldItalic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w600,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );

  static TextStyle boldItalic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w700,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );

  static TextStyle heavyItalic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w800,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );

  static TextStyle blackItalic({double? fontSize, Color? color}) => font(
    fontWeight: FontWeight.w900,
    style: FontStyle.italic,
    fontSize: fontSize,
    color: color,
  );
}
