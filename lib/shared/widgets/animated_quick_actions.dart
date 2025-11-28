import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_feature_card.dart';
import 'custom_icons.dart';

class AnimatedQuickActions extends StatefulWidget {
  final Function(String) onActionTap;

  const AnimatedQuickActions({super.key, required this.onActionTap});

  @override
  State<AnimatedQuickActions> createState() => _AnimatedQuickActionsState();
}

class _AnimatedQuickActionsState extends State<AnimatedQuickActions>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _opacityAnimations;

  final List<QuickActionItem> _actions = [
    QuickActionItem(
      id: 'kundli',
      title: 'Generate Kundli',
      subtitle: 'Create birth chart',
      icon: CustomIcons.kundliIcon(),
      primaryColor: const Color(0xFFFF6B6B),
      secondaryColor: const Color(0xFFFFE0E0),
    ),
    QuickActionItem(
      id: 'matching',
      title: 'Kundli Matching',
      subtitle: 'Check compatibility',
      icon: CustomIcons.compatibilityIcon(),
      primaryColor: const Color(0xFF6C5CE7),
      secondaryColor: const Color(0xFFE8E5FF),
      badge: 'POPULAR',
    ),
    QuickActionItem(
      id: 'ai_chat',
      title: 'AI Astrologer',
      subtitle: 'Ask questions',
      icon: CustomIcons.aiChatIcon(),
      primaryColor: const Color(0xFF00B894),
      secondaryColor: const Color(0xFFD1F2EB),
      isNew: true,
    ),
    QuickActionItem(
      id: 'festivals',
      title: 'Festivals',
      subtitle: 'Upcoming events',
      icon: CustomIcons.festivalIcon(),
      primaryColor: const Color(0xFFFDAB3D),
      secondaryColor: const Color(0xFFFFF4E0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimations = List.generate(
      _actions.length,
      (index) => Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.5 + index * 0.15,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );

    _opacityAnimations = List.generate(
      _actions.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.4 + index * 0.1,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-20 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _buildSectionHeader(context),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        // Actions Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemCount: _actions.length,
          itemBuilder: (context, index) {
            final action = _actions[index];
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: Opacity(
                    opacity: _opacityAnimations[index].value,
                    child: ModernFeatureCard(
                      icon: action.icon,
                      title: action.title,
                      subtitle: action.subtitle,
                      primaryColor: action.primaryColor,
                      secondaryColor: action.secondaryColor,
                      badge: action.badge,
                      isNew: action.isNew,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onActionTap(action.id);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6B6B), Color(0xFF6C5CE7)],
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
        const Spacer(),
        // Optional: View All button
        TextButton(
          onPressed: () {
            // Handle view all
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuickActionItem {
  final String id;
  final String title;
  final String subtitle;
  final Widget icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String? badge;
  final bool isNew;

  QuickActionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.badge,
    this.isNew = false,
  });
}


