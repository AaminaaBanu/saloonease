import 'package:flutter/material.dart';
import 'package:salonease1/components/login_form.dart';
import 'package:salonease1/components/sign_up_form.dart';
import 'package:salonease1/components/social_button.dart';
import 'package:salonease1/utils/text.dart';
import 'package:salonease1/utils/config.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isSignIn = true;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    // build login text field
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppText.enText['welcome_text']!,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Config.spaceSmall,
                  Text(
                    isSignIn
                        ? AppText.enText['signIn_text']!
                        : AppText.enText['register_text']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Config.spaceSmall,
                  //login components here
                  isSignIn ? const LoginForm() : const SignUpForm(),
                  Config.spaceSmall,
                  isSignIn
                      ? Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        AppText.enText['forgot-password']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      : Container(),
                  Config.spaceSmall,
                  Center(
                    child: Text(
                      AppText.enText['social-login']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Config.spaceSmall,
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SocialButton(social: 'google'),
                      SocialButton(social: 'facebook'),
                    ],
                  ),
                  Config.spaceSmall,

                ],
              ),
            ),
          ),
        )
    );
  }
}
