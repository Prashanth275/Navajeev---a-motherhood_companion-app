import 'package:flutter/material.dart';

class WellbeingPage extends StatelessWidget {
  const WellbeingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Wellbeing Content\n(Nutrition & Exercise)',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
