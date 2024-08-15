import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenware/booking/RideHistory.dart';
import 'package:greenware/booking/book.dart';
import 'package:greenware/colorextensions.dart';
import 'package:greenware/firebase_options.dart';
import 'package:greenware/home/home.dart';
import 'package:greenware/login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:greenware/login/optscreen.dart';
import 'package:greenware/login/phone.dart';
import 'package:greenware/profile/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // checking if user is logged in

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return MaterialApp(
              theme: ThemeData(useMaterial3: true, primaryColor: TColor.purple),
              debugShowCheckedModeBanner: false,
              title: 'Mobilitas',
              home: const RideHistoryWidget(),
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme(
                    primary: TColor.purple,
                    secondary: TColor.black,
                    onPrimary: TColor.white,
                    onSecondary: TColor.white,
                    surface: TColor.white,
                    onSurface: TColor.black,
                    background: TColor.white,
                    onBackground: TColor.black,
                    error: Colors.red,
                    onError: Colors.white,
                    brightness: Brightness.dark),
              ),
              title: 'Mobilitas',
              home: const Login(),
            );
          }
        });
  }
}
