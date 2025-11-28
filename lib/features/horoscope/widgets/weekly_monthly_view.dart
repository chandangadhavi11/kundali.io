import 'package:flutter/material.dart';

class WeeklyMonthlyView extends StatefulWidget {
  final String userSign;

  const WeeklyMonthlyView({super.key, required this.userSign});

  @override
  State<WeeklyMonthlyView> createState() => _WeeklyMonthlyViewState();
}

class _WeeklyMonthlyViewState extends State<WeeklyMonthlyView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Period Selector
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.grey[900]?.withOpacity(0.5)
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF8B7EFF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: Colors.white,
            unselectedLabelColor:
                isDarkMode ? Colors.grey[400] : Colors.grey[600],
            tabs: const [
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
            ],
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildForecastView('Weekly', isDarkMode),
              _buildForecastView('Monthly', isDarkMode),
              _buildForecastView('Yearly', isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastView(String period, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Jump Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildJumpChip('Overview', true, isDarkMode),
                const SizedBox(width: 8),
                _buildJumpChip('Love', false, isDarkMode),
                const SizedBox(width: 8),
                _buildJumpChip('Career', false, isDarkMode),
                const SizedBox(width: 8),
                _buildJumpChip('Finance', false, isDarkMode),
                const SizedBox(width: 8),
                _buildJumpChip('Remedies', false, isDarkMode),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Forecast Content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey[900]?.withOpacity(0.5)
                      : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.grey[800]!.withOpacity(0.5)
                        : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$period Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This $period brings significant opportunities for growth and transformation. The planetary alignments favor new beginnings and creative pursuits.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJumpChip(String label, bool isSelected, bool isDarkMode) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      backgroundColor:
          isDarkMode ? Colors.grey[800]?.withOpacity(0.5) : Colors.grey[100],
      selectedColor: const Color(0xFF6C5CE7).withOpacity(0.2),
      checkmarkColor: const Color(0xFF6C5CE7),
      labelStyle: TextStyle(
        fontSize: 12,
        color:
            isSelected
                ? const Color(0xFF6C5CE7)
                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected
                  ? const Color(0xFF6C5CE7).withOpacity(0.3)
                  : Colors.transparent,
        ),
      ),
    );
  }
}
