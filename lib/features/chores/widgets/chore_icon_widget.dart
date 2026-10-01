import 'package:flutter/material.dart';
import '../utils/color_helper.dart';
import '../utils/icon_mapper.dart';

class ChoreIconWidget extends StatelessWidget {
  final String? icon;
  final String? iconBg;
  final String? iconColor;
  final double size;
  final bool isQuick;

  const ChoreIconWidget({
    super.key,
    this.icon,
    this.iconBg,
    this.iconColor,
    this.size = 44,
    this.isQuick = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = ColorHelper.parseBgDecoration(
      iconBg,
      borderRadius: isQuick ? 14 : size / 2,
    );
    final color = ColorHelper.parseHexColor(iconColor, fallback: Colors.white);
    final emoji = IconMapper.getEmoji(icon);

    Widget content;
    if (emoji != null) {
      content = Text(
        emoji,
        style: TextStyle(
          fontSize: size * 0.52,
          height: 1.0,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      final iconData = IconMapper.getIcon(icon);
      content = Icon(
        iconData,
        size: size * 0.55,
        color: color,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      alignment: Alignment.center,
      child: content,
    );
  }
}
