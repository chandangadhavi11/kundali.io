import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

// Premium Cosmic Colors
class _CosmicColors {
  static const background = Color(0xFF0A0612);
  static const cardDark = Color(0xFF16101F);
  static const golden = Color(0xFFE8B931);
  static const goldenLight = Color(0xFFF5D563);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFF9CA3AF);
  static const accent = Color(0xFF6C5CE7);
  static const success = Color(0xFF00B894);
  static const danger = Color(0xFFFF6B6B);
}

class RemindersView extends StatefulWidget {
  const RemindersView({super.key});

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _reminders = [
    {
      'title': 'Ekadashi Fast',
      'type': 'tithi',
      'date': 'Every Ekadashi',
      'time': '05:00 AM',
      'enabled': true,
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFF00B894),
    },
    {
      'title': 'Purnima Puja',
      'type': 'tithi',
      'date': 'Every Full Moon',
      'time': '07:00 PM',
      'enabled': true,
      'icon': Icons.nightlight_rounded,
      'color': const Color(0xFF6C5CE7),
    },
    {
      'title': 'Birthday (Hindu)',
      'type': 'nakshatra',
      'date': 'Rohini Nakshatra',
      'time': '08:00 AM',
      'enabled': false,
      'icon': Icons.cake_rounded,
      'color': const Color(0xFFFF6B94),
    },
    {
      'title': 'Anniversary',
      'type': 'gregorian',
      'date': 'Dec 25, 2024',
      'time': '09:00 AM',
      'enabled': true,
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF6B6B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Column(
        children: [
          _buildAddReminderButton(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + index * 100),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildReminderCard(_reminders[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReminderButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showAddReminderSheet();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_CosmicColors.golden, _CosmicColors.goldenLight],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _CosmicColors.golden.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: _CosmicColors.background,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Add New Reminder',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _CosmicColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final color = reminder['color'] as Color;
    final isEnabled = reminder['enabled'] as bool;

    return Dismissible(
      key: Key(reminder['title'] as String),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _CosmicColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_rounded, color: _CosmicColors.danger, size: 22),
      ),
      onDismissed: (direction) {
        setState(() => _reminders.remove(reminder));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reminder['title']} deleted'),
            backgroundColor: _CosmicColors.cardDark,
            action: SnackBarAction(
              label: 'Undo',
              textColor: _CosmicColors.golden,
              onPressed: () {
                setState(() => _reminders.add(reminder));
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isEnabled ? 0.04 : 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(isEnabled ? 0.2 : 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                reminder['icon'] as IconData,
                color: color.withOpacity(isEnabled ? 1.0 : 0.5),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _CosmicColors.textPrimary.withOpacity(isEnabled ? 1.0 : 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: _CosmicColors.textSecondary.withOpacity(isEnabled ? 1.0 : 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder['date'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: _CosmicColors.textSecondary.withOpacity(isEnabled ? 1.0 : 0.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: _CosmicColors.textSecondary.withOpacity(isEnabled ? 1.0 : 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder['time'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: _CosmicColors.textSecondary.withOpacity(isEnabled ? 1.0 : 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(reminder['type'] as String).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTypeLabel(reminder['type'] as String),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getTypeColor(reminder['type'] as String),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: (value) {
                setState(() => reminder['enabled'] = value);
              },
              activeColor: color,
              activeTrackColor: color.withOpacity(0.3),
              inactiveThumbColor: _CosmicColors.textSecondary,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'tithi':
        return _CosmicColors.accent;
      case 'nakshatra':
        return _CosmicColors.golden;
      case 'gregorian':
        return _CosmicColors.success;
      default:
        return _CosmicColors.textSecondary;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'tithi':
        return 'Hindu Tithi';
      case 'nakshatra':
        return 'Nakshatra';
      case 'gregorian':
        return 'Gregorian';
      default:
        return type;
    }
  }

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddReminderSheet(),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  String _selectedType = 'tithi';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.7,
      decoration: BoxDecoration(
        color: _CosmicColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Add Reminder',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _CosmicColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: _CosmicColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Reminder Type'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypeChip('Hindu Tithi', 'tithi'),
                      const SizedBox(width: 8),
                      _buildTypeChip('Nakshatra', 'nakshatra'),
                      const SizedBox(width: 8),
                      _buildTypeChip('Gregorian', 'gregorian'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInputField('Reminder Title', Icons.edit_rounded),
                  const SizedBox(height: 16),
                  _buildInputField('Select Time', Icons.access_time_rounded),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _CosmicColors.textPrimary,
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    _CosmicColors.golden.withOpacity(0.2),
                    _CosmicColors.golden.withOpacity(0.1),
                  ],
                )
              : null,
          color: !isSelected ? Colors.white.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _CosmicColors.golden.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? _CosmicColors.golden
                : _CosmicColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _CosmicColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            hint,
            style: TextStyle(
              fontSize: 14,
              color: _CosmicColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_CosmicColors.golden, _CosmicColors.goldenLight],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _CosmicColors.golden.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Save Reminder',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _CosmicColors.background,
            ),
          ),
        ),
      ),
    );
  }
}
