import 'package:flutter/material.dart';

class AppointemetsScreen extends StatefulWidget {
  const AppointemetsScreen({super.key});

  @override
  State<AppointemetsScreen> createState() => _AppointemetsScreenState();
}

class _AppointemetsScreenState extends State<AppointemetsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Appointments Screen')),
    );
  }
}
