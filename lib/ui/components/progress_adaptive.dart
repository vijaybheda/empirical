import 'package:flutter/material.dart';

class ProgressAdaptive extends StatelessWidget {
  const ProgressAdaptive({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 2,
      child: const CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        backgroundColor: Colors.white,
      ),
    );
  }
}
