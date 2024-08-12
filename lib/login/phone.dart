import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:greenware/colorextensions.dart';
import 'package:greenware/login/optscreen.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;
  final RoundedLoadingButtonController controller =
      RoundedLoadingButtonController();

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
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Add Phone Number",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontFamily: "Sans Fransisco",
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
                          Row(
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Enter your phone number and name",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: "Sans Fransisco",
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: TColor.textFill,
                                  borderRadius: BorderRadius.circular(25),
                                  border:
                                      Border.all(color: TColor.borderStroke)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, left: 10),
                                      child: Text("🇮🇳 +91"),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(10)
                                        ],
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                            hintText: "Phone Number",
                                            hintStyle: TextStyle(
                                                color: TColor.textColor,
                                                fontSize: 16,
                                                fontFamily: "Sans Fransisco",
                                                fontWeight: FontWeight.bold),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 9)),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: TColor.textFill,
                                  borderRadius: BorderRadius.circular(25),
                                  border:
                                      Border.all(color: TColor.borderStroke)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _nameController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            hintText: "Name",
                                            hintStyle: TextStyle(
                                                color: TColor.textColor,
                                                fontSize: 16,
                                                fontFamily: "Sans Fransisco",
                                                fontWeight: FontWeight.bold),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 9)),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          RoundedLoadingButton(
                              color: TColor.purple,
                              animateOnTap: true,
                              width: MediaQuery.of(context).size.width - 40,
                              controller: controller,
                              onPressed: () {
                                // _updatePhone();
                                _updatePhone();
                              },
                              child: Text(
                                "Continue",
                                style: TextStyle(color: Colors.white),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
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

  _updatePhone() async {
    var auth = FirebaseAuth.instance;
    if (_phoneController.text.length < 10) {
      controller.stop();
      controller.reset();
      showToast("Please enter a valid phone number", context: context);
      return;
    }
    if (_phoneController.text.isNotEmpty) {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      _auth.verifyPhoneNumber(
          phoneNumber: '+91${_phoneController.text}',
          verificationCompleted: (PhoneAuthCredential credential) async {
            final User? currentUser = _auth.currentUser;
            if (currentUser != null) {
              await currentUser.linkWithCredential(credential);

              await _firestore.collection('users').doc(currentUser.uid).set({
                'phone': _phoneController.text,
              }, SetOptions(merge: true));

              print("Phone number added");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Phone number added.'),
                ),
              );
            }
          },
          verificationFailed: (error) {
            controller.stop();
            controller.reset();
            showToast(error.message, context: context);
          },
          codeSent: (verificationId, forceResendingToken) {
            controller.success();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return OTPScreen(
                verificationId: verificationId,
                phoneNumber: _phoneController.text,
                userName: _nameController.text,
              );
            }));
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    }
  }
}
