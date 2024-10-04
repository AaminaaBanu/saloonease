import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonease1/main_layout.dart';
import 'package:salonease1/models/auth_model.dart';
import 'package:salonease1/screens/auth_page.dart';
import 'package:salonease1/screens/profile.dart';
import 'package:salonease1/utils/config.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  // thid is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //define theme data here
    return ChangeNotifierProvider<AuthModel>(
      create: (context) => AuthModel(),
      child: MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        title: 'Salon Ease',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          //pre-define input decoration
          inputDecorationTheme: const InputDecorationTheme(
            focusColor: Config.primaryColor,
            border: Config.outlineBorder,
            focusedBorder: Config.focusBorder,
            errorBorder: Config.errorBorder,
            enabledBorder: Config.outlineBorder,
            floatingLabelStyle: TextStyle(color: Config.primaryColor),
            prefixIconColor: Colors.black38,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            bodyMedium: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            labelLarge: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Config.primaryColor,
            selectedItemColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            unselectedItemColor: Colors.grey.shade700,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        initialRoute: '/',
        routes: {
          //this is the initial route of the app
          //which is auth page(login and sign up)
          '/': (context) => const AuthPage(),
          //this is for main layout after login
          'main': (context) => const MainLayout(),
        },
      ),
    );
  }


}
