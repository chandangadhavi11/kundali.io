import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RemindersView extends StatefulWidget {
  const RemindersView({super.key});

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Add Reminder Button
          _buildAddReminderButton(isDarkMode),

          // Reminders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                return _buildReminderCard(_reminders[index], isDarkMode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReminderButton(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showAddReminderSheet();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFDAB3D), Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFDAB3D).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Add New Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900]?.withOpacity(0.7) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (reminder['color'] as Color).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (reminder['color'] as Color).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(reminder['title'] as String),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.red, size: 24),
        ),
        onDismissed: (direction) {
          setState(() {
            _reminders.remove(reminder);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${reminder['title']} deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  setState(() {
                    _reminders.add(reminder);
                  });
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (reminder['color'] as Color).withOpacity(0.2),
                      (reminder['color'] as Color).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  reminder['icon'] as IconData,
                  color: reminder['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reminder['date'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reminder['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(
                          reminder['type'] as String,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
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
                value: reminder['enabled'] as bool,
                onChanged: (value) {
                  setState(() {
                    reminder['enabled'] = value;
                  });
                },
                activeColor: reminder['color'] as Color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'tithi':
        return const Color(0xFF6C5CE7);
      case 'nakshatra':
        return const Color(0xFFFDAB3D);
      case 'gregorian':
        return const Color(0xFF00B894);
      default:
        return Colors.grey;
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
      builder: (context) => _AddReminderSheet(),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  String _selectedType = 'tithi';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
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
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
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
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type selector
                  Text(
                    'Reminder Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypeChip('Hindu Tithi', 'tithi', isDarkMode),
                      const SizedBox(width: 8),
                      _buildTypeChip('Nakshatra', 'nakshatra', isDarkMode),
                      const SizedBox(width: 8),
                      _buildTypeChip('Gregorian', 'gregorian', isDarkMode),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Form fields based on type
                  if (_selectedType == 'tithi') ...[
                    _buildDropdownField('Select Tithi', [
                      'Ekadashi',
                      'Purnima',
                      'Amavasya',
                    ], isDarkMode),
                  ] else if (_selectedType == 'nakshatra') ...[
                    _buildDropdownField('Select Nakshatra', [
                      'Ashwini',
                      'Bharani',
                      'Krittika',
                    ], isDarkMode),
                  ] else ...[
                    _buildDateField('Select Date', isDarkMode),
                  ],

                  const SizedBox(height: 20),
                  _buildTextField('Reminder Title', isDarkMode),

                  const SizedBox(height: 20),
                  _buildTimeField('Reminder Time', isDarkMode),

                  const SizedBox(height: 20),
                  _buildRepeatOptions(isDarkMode),

                  const SizedBox(height: 32),

                  // Save button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFDAB3D), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Save Reminder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String value, bool isDarkMode) {
    final isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFFDAB3D).withOpacity(0.2)
                  : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFDAB3D) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color:
                isSelected
                    ? const Color(0xFFFDAB3D)
                    : (isDarkMode ? Colors.white : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items[0],
              items:
                  items.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
              onChanged: (value) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextField(
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
            decoration: InputDecoration(
              hintText: 'Enter title',
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 20,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Text(
                '08:00 AM',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatOptions(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildRepeatChip('Once', isDarkMode),
            _buildRepeatChip('Daily', isDarkMode),
            _buildRepeatChip('Weekly', isDarkMode),
            _buildRepeatChip('Monthly', isDarkMode),
            _buildRepeatChip('Yearly', isDarkMode),
          ],
        ),
      ],
    );
  }

  Widget _buildRepeatChip(String label, bool isDarkMode) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isDarkMode ? Colors.white : Colors.grey[700],
        ),
      ),
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
    );
  }
}


