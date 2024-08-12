import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greenware/colorextensions.dart';
import 'package:greenware/home/home.dart';
import 'package:greenware/login/phone.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      showToast("Location permission granted",
          context: context, animation: StyledToastAnimation.slideFromTopFade);
    } else {
      showToast("Location permission denied",
          context: context, animation: StyledToastAnimation.slideFromTopFade);
    }
  }

  Future<void> checkInternetConnection() async {
    bool hasInternet = await InternetConnectionChecker().hasConnection;

    if (hasInternet) {
    } else {
      showToast("No internet connection",
          context: context, animation: StyledToastAnimation.slideFromTopFade);
    }
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.purple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 110,
                ),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(75)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(75),
                    child: Image.asset(
                      "assets/logo diminished.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Text(
                  "Go green with",
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontFamily: "San Fransisco"),
                ),
                SizedBox(
                  height: 5,
                ),
                const Text(
                  "Mobilitas",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Monaco",
                      fontSize: 40,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Eco-friendly, convenient, real-time tracking.',
                  style: TextStyle(
                      fontFamily: "San Fransisco",
                      color: Colors.white,
                      fontSize: 16),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SlideAction(
                    height: 70,
                    text: "Log in with Google",
                    textColor: Colors.white,
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: "San Fransisco"),
                    sliderButtonIcon: Image.asset("assets/google.png"),
                    outerColor: TColor.white,
                    innerColor: TColor.white50,
                    onSubmit: () {
                      return _signInWithGoogle();
                    },
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: SlideAction(
                //     height: 70,
                //     text: "Log in with Github",
                //     textColor: Colors.white,
                //     textStyle: TextStyle(
                //         color: Colors.white,
                //         fontSize: 20,
                //         fontFamily: "San Fransisco"),
                //     sliderButtonIcon: Image.asset(
                //       "assets/github.png",
                //       height: 20,
                //       width: 20,
                //       fit: BoxFit.cover,
                //     ),
                //     outerColor: TColor.black,
                //     innerColor: TColor.white50,
                //     onSubmit: () {
                //       singInWIthGithub();
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      FirebaseAuth auth = FirebaseAuth.instance;
      auth.signInWithProvider(googleProvider).then((value) {
        // get the user
        User? user = value.user;
        if (user != null) {
          if (user.uid != null) {
            DocumentReference ref = firestore.collection('users').doc(user.uid);

            if (ref != null) {
              ref.get().then((DocumentSnapshot snapshot) {
                if (snapshot.exists) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PhoneLogin()));
                }
              });
            }
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const PhoneLogin()));
          }
        }
      });
    } catch (e) {
      showToast(e.toString(),
          context: context, animation: StyledToastAnimation.slideFromTopFade);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // requesting location permission

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? gAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth?.accessToken,
      idToken: gAuth?.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const PhoneLogin()));

    return userCredential;
  }

  // Future<UserCredential> singInWIthGithub() async {
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   final GithubAuthProvider githubProvider = GithubAuthProvider();
  //   return await auth.signInWithProvider(githubProvider);
  // }
}
