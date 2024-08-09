import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenware/colorextensions.dart';
import 'package:greenware/home/home.dart';
import 'package:greenware/login/login.dart';
import 'package:greenware/profile/profile.dart';
import 'package:pinput/pinput.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String userName;
  const OTPScreen(
      {super.key,
      required this.verificationId,
      required this.phoneNumber,
      required this.userName});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  var otpValue = "";
  final RoundedLoadingButtonController controller =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
  }

  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TColor.purple,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 120,
                  color: TColor.purple,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: Navigator.of(context).pop,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset('assets/cancel.png'),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Verify your number",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: [
                  Container(
                    height: MediaQuery.of(context).size.height - 120,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Enter the OTP sent to your number",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 19,
                                fontFamily: "Google Sans",
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Pinput(
                            length: 6,
                            onChanged: (value) => {
                              setState(() {
                                otpValue = value;
                              })
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          RoundedLoadingButton(
                              color: TColor.purple,
                              animateOnTap: true,
                              width: MediaQuery.of(context).size.width - 40,
                              controller: controller,
                              onPressed: () {
                                _verifyOTP();
                              },
                              child: Text(
                                "Verify",
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ));
  }

  _verifyOTP() async {
    if (otpValue.length == 6) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: widget.verificationId, smsCode: otpValue);

        if (auth.currentUser != null) {
          await auth.currentUser!.updatePhoneNumber(credential);

          final Map<String, dynamic> data = {
            'email': user!.email,
            'name': widget.userName,
            'pendingAmount': 0,
            'photo': user!.photoURL,
            'phone': widget.phoneNumber,
            'totalDistance': 0,
            'credits': 100,
            'totalRides': 0,
            'totalSpent': 0,
            'rides': {
              'ride1': {
                'endTime': Timestamp.now(), // Replace with actual endTime
                'price': 0,
                'review': 0,
                'startPoint': 'Demo Data',
                'finalPoint': 'Demo Data',
                'startTime': Timestamp.now() // Replace with actual startTime
              }
            }
          };

          await firestore
              .collection('users')
              .doc(user!.uid)
              .set(data, SetOptions(merge: true));
        }

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomePage();
        }));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "An error occurred"),
            backgroundColor: TColor.purple,
          ),
        );

        controller.reset();

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return Login();
        }));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid OTP"),
          backgroundColor: TColor.purple,
        ),
      );
      controller.reset();
    }
  }
}
