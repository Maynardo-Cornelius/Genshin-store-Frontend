import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
          ),
        ),

        // Dark overlay supaya tidak pusing
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.65),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}