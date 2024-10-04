import 'package:flutter/material.dart';
import 'package:salonease1/screens/screenbuilder.dart';
import 'package:salonease1/utils/config.dart';
import 'package:salonease1/screens/home_page.dart'; // Import HomePage
import 'package:salonease1/components/sign_up_form.dart';
import 'package:salonease1/api/api_service.dart'; // Import ApiService

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passController.text;

    // Call the login method from ApiService
    final token = await ApiService.login(email, password);

    if (token != null) {
      // If login is successful, navigate to the Screenbuilder page
      print('Login successful, Token: $token');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Screenbuild()),
      );
    } else {
      _showErrorDialog('Invalid credentials. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Config.primaryColor,
              decoration: const InputDecoration(
                hintText: 'Email Address',
                labelText: 'Email',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16), // Spacing
            TextFormField(
              controller: _passController,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: Config.primaryColor,
              obscureText: obsecurePass,
              decoration: InputDecoration(
                hintText: 'Password',
                labelText: 'Password',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obsecurePass = !obsecurePass;
                    });
                  },
                  icon: obsecurePass
                      ? const Icon(Icons.visibility_off_outlined)
                      : const Icon(Icons.visibility_outlined),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16), // Spacing
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Config.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login(); // Call the login function
                  }
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Spacing for the Sign Up button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpForm()),
                );
              },
              child: const Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
