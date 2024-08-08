import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenware/colorextensions.dart';
import 'package:greenware/login/phone.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var photoUrl =
      'https://lh3.googleusercontent.com/a/ACg8ocJyYD_vzdfEeunnkwA6T5A2UWm-TwYjMQrSbqUEqJ-mV_U6nEEZ=s360-c-no';
  var name = 'example';
  var email = 'example.com';
  var phone = "7880558969";

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<void> getData() async {
    var user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference ref = firestore.collection('users').doc(user!.uid);
    final DocumentSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        name = snapshot['name'];
        photoUrl = snapshot['photo'];
        email = snapshot['email'];
        phone = snapshot['phone'];
      });
    }
  }

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
                              "Profile",
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
                Container(
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
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: TColor.purple,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          name,
                          style: TextStyle(
                              fontFamily: "Sans Fransisco",
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        editOptions("Email", email, updateEmail),
                        SizedBox(
                          height: 20,
                        ),
                        editOptions(
                            "Phone", phone ?? "Add Phone Number", updatePhone),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget editOptions(String title, String value, onTap) {
    return Container(
      child: Column(
        children: [
          Row(children: [
            SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: TextStyle(
                  fontFamily: "Sans Fransisco",
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                decoration: BoxDecoration(
                  color: TColor.textFill,
                  border: Border.all(color: TColor.borderStroke),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Text(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  updatePhone() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return PhoneLogin();
    }));
  }

  updateEmail() {}
}