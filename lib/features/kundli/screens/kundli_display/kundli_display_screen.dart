import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/kundli_provider.dart';
import '../modern_kundli_display/modern_kundli_display_screen.dart';

class KundliDisplayScreen extends StatelessWidget {
  const KundliDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KundliProvider>(
      builder: (context, provider, child) {
        if (provider.currentKundali != null) {
          return ModernKundliDisplayScreen(
            kundaliData: provider.currentKundali!,
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Kundali Display')),
          body: const Center(child: Text('No Kundali generated yet')),
        );
      },
    );
  }
}
