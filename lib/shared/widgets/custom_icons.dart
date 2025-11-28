import 'package:flutter/material.dart';

class CustomIcons {
  // Kundli Icon - Birth Chart
  static Widget kundliIcon({double size = 24, Color? color}) {
    return Icon(Icons.auto_awesome_rounded, size: size, color: color);
  }

  // Compatibility Icon - Heart with stars
  static Widget compatibilityIcon({double size = 24, Color? color}) {
    return Stack(
      alignment: Alignment.center,
      children: [Icon(Icons.favorite_rounded, size: size, color: color)],
    );
  }

  // AI Chat Icon - Smart assistant
  static Widget aiChatIcon({double size = 24, Color? color}) {
    return Icon(Icons.psychology_rounded, size: size, color: color);
  }

  // Festival/Calendar Icon
  static Widget festivalIcon({double size = 24, Color? color}) {
    return Icon(Icons.celebration_rounded, size: size, color: color);
  }

  // Horoscope Icon
  static Widget horoscopeIcon({double size = 24, Color? color}) {
    return Icon(Icons.stars_rounded, size: size, color: color);
  }

  // Panchang Icon
  static Widget panchangIcon({double size = 24, Color? color}) {
    return Icon(Icons.wb_sunny_rounded, size: size, color: color);
  }

  // Profile Icon
  static Widget profileIcon({double size = 24, Color? color}) {
    return Icon(Icons.person_rounded, size: size, color: color);
  }

  // Premium Icon
  static Widget premiumIcon({double size = 24, Color? color}) {
    return Icon(Icons.workspace_premium_rounded, size: size, color: color);
  }

  // Remedies Icon
  static Widget remediesIcon({double size = 24, Color? color}) {
    return Icon(Icons.healing_rounded, size: size, color: color);
  }

  // Gemstone Icon
  static Widget gemstoneIcon({double size = 24, Color? color}) {
    return Icon(Icons.diamond_rounded, size: size, color: color);
  }
}


