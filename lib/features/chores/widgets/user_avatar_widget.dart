import 'package:flutter/material.dart';
import '../models/user_short_model.dart';
import '../utils/color_helper.dart';
import '../utils/icon_mapper.dart';

class UserAvatarWidget extends StatelessWidget {
  final UserShort? user;
  final double size;
  final String? name;
  final String? icon;
  final String? iconColor;
  final String? iconBg;

  const UserAvatarWidget({
    super.key,
    this.user,
    this.size = 18,
    this.name,
    this.icon,
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveName = user?.name ?? name ?? '';
    final effectiveIcon = user?.icon ?? icon;
    final effectiveIconColor = user?.iconColor ?? iconColor;
    final effectiveIconBg = user?.iconBg ?? iconBg;

    if (user == null && name == null && icon == null) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF616162),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '—',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      );
    }

    final bgDecoration = ColorHelper.parseBgDecoration(
      effectiveIconBg,
      isCircle: true,
    );
    final color = ColorHelper.parseHexColor(effectiveIconColor, fallback: Colors.white);
    final initials = effectiveName.isNotEmpty ? effectiveName[0].toUpperCase() : '';

    final emoji = IconMapper.getEmoji(effectiveIcon);

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
    } else if (effectiveIcon != null && effectiveIcon.trim().isNotEmpty) {
      content = Icon(
        IconMapper.getIcon(effectiveIcon),
        size: size * 0.55,
        color: color,
      );
    } else {
      content = Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: size * 0.48,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: bgDecoration,
      alignment: Alignment.center,
      child: content,
    );
  }
}
