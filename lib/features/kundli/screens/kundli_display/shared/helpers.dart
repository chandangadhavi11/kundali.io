import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kundali_app/core/services/kundali_calculation_service.dart';
import 'constants.dart';

/// Astrological helper functions for Kundli Display

// ============ SIGN & PLANET HELPERS ============

String getLagnaLord(String sign) {
  const lords = {
    'Aries': 'Mars',
    'Taurus': 'Venus',
    'Gemini': 'Mercury',
    'Cancer': 'Moon',
    'Leo': 'Sun',
    'Virgo': 'Mercury',
    'Libra': 'Venus',
    'Scorpio': 'Mars',
    'Sagittarius': 'Jupiter',
    'Capricorn': 'Saturn',
    'Aquarius': 'Saturn',
    'Pisces': 'Jupiter',
  };
  return lords[sign] ?? 'Unknown';
}

String getSignElement(String sign) {
  const elements = {
    'Aries': 'Fire',
    'Taurus': 'Earth',
    'Gemini': 'Air',
    'Cancer': 'Water',
    'Leo': 'Fire',
    'Virgo': 'Earth',
    'Libra': 'Air',
    'Scorpio': 'Water',
    'Sagittarius': 'Fire',
    'Capricorn': 'Earth',
    'Aquarius': 'Air',
    'Pisces': 'Water',
  };
  return elements[sign] ?? 'Unknown';
}

IconData getElementIcon(String sign) {
  final element = getSignElement(sign);
  switch (element) {
    case 'Fire':
      return Icons.local_fire_department_rounded;
    case 'Earth':
      return Icons.landscape_rounded;
    case 'Air':
      return Icons.air_rounded;
    case 'Water':
      return Icons.water_drop_rounded;
    default:
      return Icons.circle;
  }
}

Color getElementColor(String sign) {
  final element = getSignElement(sign);
  switch (element) {
    case 'Fire':
      return const Color(0xFFF87171);
    case 'Earth':
      return const Color(0xFF6EE7B7);
    case 'Air':
      return const Color(0xFF60A5FA);
    case 'Water':
      return const Color(0xFF67E8F9);
    default:
      return KundliDisplayColors.textMuted;
  }
}

// ============ NAKSHATRA HELPERS ============

String getNakshatraFromLongitude(double longitude) {
  final index = (longitude / 13.333333).floor() % 27;
  return KundaliCalculationService.nakshatras[index];
}

String getNakshatraLord(String nakshatra) {
  const lords = {
    'Ashwini': 'Ketu',
    'Bharani': 'Venus',
    'Krittika': 'Sun',
    'Rohini': 'Moon',
    'Mrigashira': 'Mars',
    'Ardra': 'Rahu',
    'Punarvasu': 'Jupiter',
    'Pushya': 'Saturn',
    'Ashlesha': 'Mercury',
    'Magha': 'Ketu',
    'Purva Phalguni': 'Venus',
    'Uttara Phalguni': 'Sun',
    'Hasta': 'Moon',
    'Chitra': 'Mars',
    'Swati': 'Rahu',
    'Vishakha': 'Jupiter',
    'Anuradha': 'Saturn',
    'Jyeshtha': 'Mercury',
    'Mula': 'Ketu',
    'Purva Ashadha': 'Venus',
    'Uttara Ashadha': 'Sun',
    'Shravana': 'Moon',
    'Dhanishta': 'Mars',
    'Shatabhisha': 'Rahu',
    'Purva Bhadrapada': 'Jupiter',
    'Uttara Bhadrapada': 'Saturn',
    'Revati': 'Mercury',
  };
  return lords[nakshatra] ?? 'Unknown';
}

String getNakshatraDeity(String nakshatra) {
  const deities = {
    'Ashwini': 'Ashwini Kumaras',
    'Bharani': 'Yama',
    'Krittika': 'Agni',
    'Rohini': 'Brahma',
    'Mrigashira': 'Soma',
    'Ardra': 'Rudra',
    'Punarvasu': 'Aditi',
    'Pushya': 'Brihaspati',
    'Ashlesha': 'Nagas',
    'Magha': 'Pitris',
    'Purva Phalguni': 'Bhaga',
    'Uttara Phalguni': 'Aryaman',
    'Hasta': 'Savitar',
    'Chitra': 'Vishwakarma',
    'Swati': 'Vayu',
    'Vishakha': 'Indra-Agni',
    'Anuradha': 'Mitra',
    'Jyeshtha': 'Indra',
    'Mula': 'Nirriti',
    'Purva Ashadha': 'Apas',
    'Uttara Ashadha': 'Vishvadevas',
    'Shravana': 'Vishnu',
    'Dhanishta': 'Vasus',
    'Shatabhisha': 'Varuna',
    'Purva Bhadrapada': 'Aja Ekapada',
    'Uttara Bhadrapada': 'Ahir Budhnya',
    'Revati': 'Pushan',
  };
  return deities[nakshatra] ?? 'Unknown';
}

String getNakshatraGana(String nakshatra) {
  const ganas = {
    'Ashwini': 'Deva',
    'Bharani': 'Manushya',
    'Krittika': 'Rakshasa',
    'Rohini': 'Manushya',
    'Mrigashira': 'Deva',
    'Ardra': 'Manushya',
    'Punarvasu': 'Deva',
    'Pushya': 'Deva',
    'Ashlesha': 'Rakshasa',
    'Magha': 'Rakshasa',
    'Purva Phalguni': 'Manushya',
    'Uttara Phalguni': 'Manushya',
    'Hasta': 'Deva',
    'Chitra': 'Rakshasa',
    'Swati': 'Deva',
    'Vishakha': 'Rakshasa',
    'Anuradha': 'Deva',
    'Jyeshtha': 'Rakshasa',
    'Mula': 'Rakshasa',
    'Purva Ashadha': 'Manushya',
    'Uttara Ashadha': 'Manushya',
    'Shravana': 'Deva',
    'Dhanishta': 'Rakshasa',
    'Shatabhisha': 'Rakshasa',
    'Purva Bhadrapada': 'Manushya',
    'Uttara Bhadrapada': 'Manushya',
    'Revati': 'Deva',
  };
  return ganas[nakshatra] ?? 'Manushya';
}

String getNakshatraSymbol(String nakshatra) {
  const symbols = {
    'Ashwini': '🐴',
    'Bharani': '🔺',
    'Krittika': '🔥',
    'Rohini': '🛞',
    'Mrigashira': '🦌',
    'Ardra': '💎',
    'Punarvasu': '🏹',
    'Pushya': '🌸',
    'Ashlesha': '🐍',
    'Magha': '👑',
    'Purva Phalguni': '🛏️',
    'Uttara Phalguni': '🛏️',
    'Hasta': '✋',
    'Chitra': '💠',
    'Swati': '🌱',
    'Vishakha': '🎯',
    'Anuradha': '🪷',
    'Jyeshtha': '☂️',
    'Mula': '🦁',
    'Purva Ashadha': '🐘',
    'Uttara Ashadha': '🐘',
    'Shravana': '👂',
    'Dhanishta': '🎵',
    'Shatabhisha': '⭕',
    'Purva Bhadrapada': '⚔️',
    'Uttara Bhadrapada': '🐍',
    'Revati': '🐟',
  };
  return symbols[nakshatra] ?? '⭐';
}

String getNakshatraYoni(String nakshatra) {
  const yonis = {
    'Ashwini': 'Horse',
    'Bharani': 'Elephant',
    'Krittika': 'Goat',
    'Rohini': 'Serpent',
    'Mrigashira': 'Serpent',
    'Ardra': 'Dog',
    'Punarvasu': 'Cat',
    'Pushya': 'Goat',
    'Ashlesha': 'Cat',
    'Magha': 'Rat',
    'Purva Phalguni': 'Rat',
    'Uttara Phalguni': 'Cow',
    'Hasta': 'Buffalo',
    'Chitra': 'Tiger',
    'Swati': 'Buffalo',
    'Vishakha': 'Tiger',
    'Anuradha': 'Deer',
    'Jyeshtha': 'Deer',
    'Mula': 'Dog',
    'Purva Ashadha': 'Monkey',
    'Uttara Ashadha': 'Mongoose',
    'Shravana': 'Monkey',
    'Dhanishta': 'Lion',
    'Shatabhisha': 'Horse',
    'Purva Bhadrapada': 'Lion',
    'Uttara Bhadrapada': 'Cow',
    'Revati': 'Elephant',
  };
  return yonis[nakshatra] ?? 'Unknown';
}

Color getGanaColor(String gana) {
  switch (gana) {
    case 'Deva':
      return const Color(0xFF6EE7B7);
    case 'Manushya':
      return const Color(0xFF60A5FA);
    case 'Rakshasa':
      return const Color(0xFFF87171);
    default:
      return KundliDisplayColors.textMuted;
  }
}

String getNadi(String nakshatra) {
  const nadis = {
    'Ashwini': 'Aadi',
    'Bharani': 'Madhya',
    'Krittika': 'Antya',
    'Rohini': 'Aadi',
    'Mrigashira': 'Madhya',
    'Ardra': 'Antya',
    'Punarvasu': 'Aadi',
    'Pushya': 'Madhya',
    'Ashlesha': 'Antya',
    'Magha': 'Aadi',
    'Purva Phalguni': 'Madhya',
    'Uttara Phalguni': 'Antya',
    'Hasta': 'Aadi',
    'Chitra': 'Madhya',
    'Swati': 'Antya',
    'Vishakha': 'Aadi',
    'Anuradha': 'Madhya',
    'Jyeshtha': 'Antya',
    'Mula': 'Aadi',
    'Purva Ashadha': 'Madhya',
    'Uttara Ashadha': 'Antya',
    'Shravana': 'Aadi',
    'Dhanishta': 'Madhya',
    'Shatabhisha': 'Antya',
    'Purva Bhadrapada': 'Aadi',
    'Uttara Bhadrapada': 'Madhya',
    'Revati': 'Antya',
  };
  return nadis[nakshatra] ?? 'Unknown';
}

// ============ COMPATIBILITY HELPERS ============

String getVarna(String moonSign) {
  const varnas = {
    'Aries': 'Kshatriya',
    'Leo': 'Kshatriya',
    'Sagittarius': 'Kshatriya',
    'Taurus': 'Vaishya',
    'Virgo': 'Vaishya',
    'Capricorn': 'Vaishya',
    'Gemini': 'Shudra',
    'Libra': 'Shudra',
    'Aquarius': 'Shudra',
    'Cancer': 'Brahmin',
    'Scorpio': 'Brahmin',
    'Pisces': 'Brahmin',
  };
  return varnas[moonSign] ?? 'Unknown';
}

String getVashya(String moonSign) {
  const vashyas = {
    'Aries': 'Chatushpad',
    'Taurus': 'Chatushpad',
    'Leo': 'Chatushpad',
    'Sagittarius': 'Chatushpad',
    'Capricorn': 'Chatushpad',
    'Gemini': 'Nara',
    'Virgo': 'Nara',
    'Libra': 'Nara',
    'Aquarius': 'Nara',
    'Cancer': 'Jalachara',
    'Pisces': 'Jalachara',
    'Scorpio': 'Keeta',
  };
  return vashyas[moonSign] ?? 'Unknown';
}

String getTara(String nakshatra) {
  // Simplified - would need actual calculation based on birth nakshatra
  return 'Janma';
}

String getGrahaMaitri(String moonSign) {
  return getLagnaLord(moonSign);
}

String getBhakoot(String moonSign) {
  return moonSign;
}

// ============ LUCKY FACTORS ============

String getLuckyNumbers(String moonSign) {
  const numbers = {
    'Aries': '1, 8, 9',
    'Taurus': '2, 6, 7',
    'Gemini': '3, 5, 6',
    'Cancer': '2, 4, 7',
    'Leo': '1, 4, 5',
    'Virgo': '3, 5, 6',
    'Libra': '2, 6, 7',
    'Scorpio': '3, 9, 4',
    'Sagittarius': '3, 5, 8',
    'Capricorn': '4, 8, 6',
    'Aquarius': '4, 7, 8',
    'Pisces': '3, 7, 9',
  };
  return numbers[moonSign] ?? '1, 7, 9';
}

String getLuckyDay(String moonSign) {
  const days = {
    'Aries': 'Tuesday',
    'Taurus': 'Friday',
    'Gemini': 'Wednesday',
    'Cancer': 'Monday',
    'Leo': 'Sunday',
    'Virgo': 'Wednesday',
    'Libra': 'Friday',
    'Scorpio': 'Tuesday',
    'Sagittarius': 'Thursday',
    'Capricorn': 'Saturday',
    'Aquarius': 'Saturday',
    'Pisces': 'Thursday',
  };
  return days[moonSign] ?? 'Sunday';
}

String getLuckyColors(String moonSign) {
  const colors = {
    'Aries': 'Red, Coral',
    'Taurus': 'Green, Pink',
    'Gemini': 'Green, Yellow',
    'Cancer': 'White, Silver',
    'Leo': 'Gold, Orange',
    'Virgo': 'Green, White',
    'Libra': 'White, Pink',
    'Scorpio': 'Red, Maroon',
    'Sagittarius': 'Yellow, Orange',
    'Capricorn': 'Black, Blue',
    'Aquarius': 'Blue, Black',
    'Pisces': 'Yellow, Sea Green',
  };
  return colors[moonSign] ?? 'White';
}

String getLuckyMetal(String moonSign) {
  const metals = {
    'Aries': 'Iron, Copper',
    'Taurus': 'Copper, Silver',
    'Gemini': 'Bronze, Gold',
    'Cancer': 'Silver',
    'Leo': 'Gold',
    'Virgo': 'Bronze, Gold',
    'Libra': 'Copper, Silver',
    'Scorpio': 'Iron, Steel',
    'Sagittarius': 'Gold, Bronze',
    'Capricorn': 'Iron, Lead',
    'Aquarius': 'Iron, Lead',
    'Pisces': 'Gold, Platinum',
  };
  return metals[moonSign] ?? 'Gold';
}

String getLuckyGemstone(String moonSign) {
  const gemstones = {
    'Aries': 'Red Coral',
    'Taurus': 'Diamond',
    'Gemini': 'Emerald',
    'Cancer': 'Pearl',
    'Leo': 'Ruby',
    'Virgo': 'Emerald',
    'Libra': 'Diamond',
    'Scorpio': 'Red Coral',
    'Sagittarius': 'Yellow Sapphire',
    'Capricorn': 'Blue Sapphire',
    'Aquarius': 'Blue Sapphire',
    'Pisces': 'Yellow Sapphire',
  };
  return gemstones[moonSign] ?? 'Pearl';
}

String getGemstoneEmoji(String moonSign) {
  const emojis = {
    'Aries': '🔴',
    'Taurus': '💎',
    'Gemini': '💚',
    'Cancer': '🤍',
    'Leo': '❤️',
    'Virgo': '💚',
    'Libra': '💎',
    'Scorpio': '🔴',
    'Sagittarius': '💛',
    'Capricorn': '💙',
    'Aquarius': '💙',
    'Pisces': '💛',
  };
  return emojis[moonSign] ?? '💎';
}

// ============ DATE FORMATTING ============

String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

String formatDateWithTime(DateTime date) {
  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
}

String formatDateShort(DateTime date) {
  return DateFormat('dd MMM').format(date);
}

String formatDateShortWithTime(DateTime date) {
  return DateFormat('dd MMM, hh:mm a').format(date);
}

String formatDuration(double durationYears) {
  if (durationYears >= 1) {
    final years = durationYears.floor();
    final months = ((durationYears - years) * 12).round();
    if (months > 0) {
      return '${years}y ${months}m';
    }
    return '${years}y';
  } else if (durationYears >= 1 / 12) {
    final months = (durationYears * 12).floor();
    final days = ((durationYears * 12 - months) * 30).round();
    if (days > 0) {
      return '${months}m ${days}d';
    }
    return '${months}m';
  } else if (durationYears >= 1 / 365) {
    final days = (durationYears * 365).floor();
    final hours = ((durationYears * 365 - days) * 24).round();
    if (hours > 0) {
      return '${days}d ${hours}h';
    }
    return '${days}d';
  } else {
    final hours = (durationYears * 365 * 24).floor();
    final minutes = ((durationYears * 365 * 24 - hours) * 60).round();
    if (minutes > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${hours}h';
  }
}

// ============ DASHA LEVEL HELPERS ============

String getLevelDisplayName(DashaLevel level) {
  switch (level) {
    case DashaLevel.mahadasha:
      return 'Mahadasha';
    case DashaLevel.antardasha:
      return 'Antardasha';
    case DashaLevel.pratyantara:
      return 'Pratyantara';
    case DashaLevel.sookshma:
      return 'Sookshma';
    case DashaLevel.prana:
      return 'Prana';
  }
}

