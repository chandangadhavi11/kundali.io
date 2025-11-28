import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickActionsSection extends StatelessWidget {
  final bool isDarkMode;

  const QuickActionsSection({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00B894).withOpacity(0.1),
            const Color(0xFF00CEC9).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00B894).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: const Color(0xFF00B894),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
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
                child: _buildQuickAction(
                  'New Kundli',
                  Icons.add_circle_rounded,
                  const Color(0xFF6C5CE7),
                  () => _createNewKundli(context),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  'Set Primary',
                  Icons.star_rounded,
                  const Color(0xFFFDAB3D),
                  () => _setPrimaryChart(context),
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  'Backup',
                  Icons.cloud_upload_rounded,
                  const Color(0xFF00B894),
                  () => _backupData(context),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  'Export',
                  Icons.download_rounded,
                  const Color(0xFF3498DB),
                  () => _exportData(context),
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850]?.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewKundli(BuildContext context) {
    // Navigate to new Kundli creation
  }

  void _setPrimaryChart(BuildContext context) {
    // Show primary chart selector
  }

  void _backupData(BuildContext context) {
    // Backup data to cloud
  }

  void _exportData(BuildContext context) {
    // Export data
  }
}


