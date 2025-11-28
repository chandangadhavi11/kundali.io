import 'package:flutter/material.dart';

class LuckyElementsCard extends StatelessWidget {
  final int luckyNumber;
  final String luckyColor;
  final String luckyTime;
  final String mood;

  const LuckyElementsCard({
    super.key,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckyTime,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFDAB3D).withOpacity(0.1),
            const Color(0xFFFF6B6B).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDAB3D).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: const Color(0xFFFDAB3D),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lucky Elements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildElement(
                  Icons.looks_one_rounded,
                  'Number',
                  luckyNumber.toString(),
                  const Color(0xFF4ECDC4),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildElement(
                  Icons.palette_rounded,
                  'Color',
                  luckyColor,
                  const Color(0xFFFF6B94),
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildElement(
                  Icons.access_time_rounded,
                  'Time',
                  luckyTime,
                  const Color(0xFF6C5CE7),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildElement(
                  Icons.mood_rounded,
                  'Mood',
                  mood,
                  const Color(0xFF00B894),
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElement(
    IconData icon,
    String label,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]?.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


