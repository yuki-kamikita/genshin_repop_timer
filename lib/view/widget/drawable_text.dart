import 'package:flutter/material.dart';

/// テキストの前後に画像をつける
/// 練習用に作ったサンプル
/// アコーディオンか何か作るときに使うか
class DrawableText extends StatefulWidget {
  final String text;
  final double textSize;
  final String? startImagePath;
  final String? endImagePath;
  final double imageSize;

  DrawableText({
    required this.text,
    required this.textSize,
    this.startImagePath,
    this.endImagePath,
    required this.imageSize
  });
  @override
  _DrawableTextState createState() => _DrawableTextState();
}

class _DrawableTextState extends State<DrawableText> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.startImagePath != null) Image.asset(widget.startImagePath!, height: widget.imageSize),
        Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.textSize,
          ),
        ),
        if (widget.endImagePath != null) Image.asset(widget.endImagePath!, height: widget.imageSize),
      ],
    );
  }
}