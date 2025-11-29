import 'package:flutter/material.dart';
import '../modern_kundli_input/modern_kundli_input_screen.dart';

class KundliInputScreen extends StatelessWidget {
  const KundliInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('KundliInputScreen loaded - Navigation successful!');
    return const ModernKundliInputScreen();
  }
}
