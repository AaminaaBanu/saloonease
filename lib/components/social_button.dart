import 'package:flutter/material.dart';
import 'package:salonease1/utils/config.dart';

class SocialButton extends StatelessWidget {
  final String social;

  const SocialButton({
    super.key,
    required this.social, // Make sure social is passed as a parameter
  });

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return GestureDetector(
      onTap: () {
        // Define your button action here
        print('$social button pressed');
      },
      child: Image.asset(
        'assets/$social.png',
        height: 40,
        width: 40,
      ),
    );

  }
}
