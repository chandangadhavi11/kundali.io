import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportsPlusView extends StatelessWidget {
  const ReportsPlusView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Reports Section
          Text(
            'Quick Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickReportCard(
                  'Varshphal',
                  'Annual Prediction',
                  Icons.calendar_month_rounded,
                  const Color(0xFF6C5CE7),
                  isDarkMode,
                  false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickReportCard(
                  'Numerology',
                  'Number Analysis',
                  Icons.numbers_rounded,
                  const Color(0xFFFF6B6B),
                  isDarkMode,
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickReportCard(
                  'Tarot',
                  '3 Card Reading',
                  Icons.style_rounded,
                  const Color(0xFF00B894),
                  isDarkMode,
                  false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickReportCard(
                  'Compatibility',
                  'Match Analysis',
                  Icons.favorite_rounded,
                  const Color(0xFFFF8B94),
                  isDarkMode,
                  false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Premium Reports Section
          Row(
            children: [
              Text(
                'Deep Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFDAB3D), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildPremiumReportCard(
            'Career Report',
            'Detailed career analysis and predictions',
            Icons.work_rounded,
            const Color(0xFF4ECDC4),
            '₹999',
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildPremiumReportCard(
            'Love & Marriage',
            'Complete relationship compatibility report',
            Icons.favorite_rounded,
            const Color(0xFFFF6B94),
            '₹1299',
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildPremiumReportCard(
            'Financial Fortune',
            'Wealth and prosperity predictions',
            Icons.account_balance_wallet_rounded,
            const Color(0xFFFDAB3D),
            '₹899',
            isDarkMode,
          ),

          const SizedBox(height: 100), // Space for navigation
        ],
      ),
    );
  }

  Widget _buildQuickReportCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDarkMode,
    bool isPremium,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900]?.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumReportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String price,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'View',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


