import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salonease1/screens/home_page.dart'; // Import HomePage
import 'package:salonease1/screens/screenbuilder.dart';
import 'package:salonease1/utils/config.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/register'); // Adjusted URL for the registration API
    final data = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'password_confirmation': passwordController.text, // Added password confirmation
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final registerResponse = json.decode(response.body);
        print('Registration successful: $registerResponse');
        _showSuccessDialog('Registration successful!');
        
        // Navigate to the home page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  Screenbuild()),
        );
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        _showErrorDialog('Registration failed. Please try again.');
      }
    } catch (e) {
      print('Exception: $e');
      _showErrorDialog('An error occurred. Please check your connection and try again.');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Stack(
              children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedOpacity(
                          opacity: _fadeAnimation.value,
                          duration: Duration(seconds: 1),
                          child: Text(
                            'Welcome! Create an account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildTextField('Username', nameController, isDarkMode),
                        SizedBox(height: 20),
                        _buildTextField('Email', emailController, isDarkMode, inputType: TextInputType.emailAddress),
                        SizedBox(height: 20),
                        _buildTextField('Password', passwordController, isDarkMode, isPassword: true),
                        SizedBox(height: 110),
                      ],
                    ),
                  ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                        child: Text('Sign Up', style: TextStyle(fontSize: 18)),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Config.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Config.primaryColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build a text field
  Widget _buildTextField(String label, TextEditingController controller, bool isDarkMode,
      {bool isPassword = false, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Config.primaryColor),
      ),
      obscureText: isPassword,
      keyboardType: inputType,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
    );
  }
}
