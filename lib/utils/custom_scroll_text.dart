/*
 * Copyright (c) 2023.
 *
 *   Created by Samuel Philip on 11/09/23, 12:19 pm
 *   Copyright Ⓒ 2023 Syndicate Studios
 *   Owner: Samuel Philip
 *   Last modified: 11/09/23, 12:19 pm
 *   WARNING: Unauthorized distribution or access to this code may result in legal action.
 * /
 */

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomScrollText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextStyle textStyle;
  final TextAlign? textAlign;
  final double width;
  final double height;
  final int maxLines;
  final bool? isDebug;

  const CustomScrollText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.width,
    required this.height,
    this.maxLines = 200,
    this.isDebug,
    required this.fontSize,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: isDebug == true ? Colors.red : Colors.transparent,
      child: AutoSizeText(
        text,
        style: textStyle,
        maxLines: maxLines,
        minFontSize: fontSize,
        textAlign: textAlign,
        // overflowReplacement: Marquee(
        //   text: text,
        //   fadingEdgeStartFraction: 0.1,
        //   fadingEdgeEndFraction: 0.1,
        //   blankSpace: 20,
        //   scrollAxis: Axis.horizontal,
        //   pauseAfterRound: Duration(seconds: 1),
        //   accelerationCurve: Curves.easeIn,
        //   startPadding: 2.0,
        //   velocity: 15,
        //   startAfter: Duration(seconds: 1),
        //   style: textStyle,
        // ),
      ),
    );
  }
}
