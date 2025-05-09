import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 80), // Adjust the padding as needed
      child: AnimatedScale(
        scale: 1.2,  // Scale effect for animation
        duration: Duration(seconds: 1),
        curve: Curves.elasticOut,
        child: Text(
          'Instagram',
          style: GoogleFonts.pacifico(
            fontSize: 25, // Adjust font size as needed
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient( // Instagram-like gradient
                colors: [Colors.pink, Colors.purple, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ),
    );
  }
}

