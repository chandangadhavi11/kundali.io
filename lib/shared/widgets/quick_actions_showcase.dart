import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'animated_quick_actions.dart';
import 'elegant_action_card.dart';
import 'custom_icons.dart';

/// A showcase widget that demonstrates different Quick Actions UI styles
/// This can be used to switch between different designs or show them side by side
class QuickActionsShowcase extends StatefulWidget {
  const QuickActionsShowcase({super.key});

  @override
  State<QuickActionsShowcase> createState() => _QuickActionsShowcaseState();
}

class _QuickActionsShowcaseState extends State<QuickActionsShowcase> {
  int _selectedStyle = 0; // 0: Modern Cards, 1: Elegant Cards, 2: Animated Grid

  void _handleActionTap(String actionId) {
    switch (actionId) {
      case 'kundli':
        context.push('/kundli/input');
        break;
      case 'matching':
        context.push('/compatibility');
        break;
      case 'ai_chat':
        context.go('/chat');
        break;
      case 'festivals':
        context.go('/panchang');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Style Selector (Optional - can be removed in production)
        _buildStyleSelector(),
        const SizedBox(height: 20),

        // Display selected style
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildSelectedStyle(),
        ),
      ],
    );
  }

  Widget _buildStyleSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStyleChip('Modern', 0),
          const SizedBox(width: 8),
          _buildStyleChip('Elegant', 1),
          const SizedBox(width: 8),
          _buildStyleChip('Animated', 2),
        ],
      ),
    );
  }

  Widget _buildStyleChip(String label, int index) {
    final isSelected = _selectedStyle == index;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStyle = index;
          });
        }
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildSelectedStyle() {
    switch (_selectedStyle) {
      case 1:
        return _buildElegantStyle();
      case 2:
        return AnimatedQuickActions(
          key: const ValueKey('animated'),
          onActionTap: _handleActionTap,
        );
      default:
        return _buildModernStyle();
    }
  }

  Widget _buildModernStyle() {
    // This uses the ModernFeatureCard style that's already in home_screen.dart
    return const Center(
      child: Text(
        'Modern style is displayed in the main home screen',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildElegantStyle() {
    return Column(
      key: const ValueKey('elegant'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            ElegantActionCard(
              icon: CustomIcons.kundliIcon(),
              title: 'Generate Kundli',
              subtitle: 'Birth chart',
              accentColor: Colors.red[400]!,
              onTap: () => _handleActionTap('kundli'),
            ),
            ElegantActionCard(
              icon: CustomIcons.compatibilityIcon(),
              title: 'Matching',
              subtitle: 'Compatibility',
              accentColor: Colors.purple[400]!,
              onTap: () => _handleActionTap('matching'),
              isPremium: false,
            ),
            ElegantActionCard(
              icon: CustomIcons.aiChatIcon(),
              title: 'AI Astrologer',
              subtitle: 'Ask anything',
              accentColor: Colors.teal[400]!,
              onTap: () => _handleActionTap('ai_chat'),
            ),
            ElegantActionCard(
              icon: CustomIcons.festivalIcon(),
              title: 'Festivals',
              subtitle: 'Events',
              accentColor: Colors.orange[400]!,
              onTap: () => _handleActionTap('festivals'),
            ),
          ],
        ),
      ],
    );
  }
}


