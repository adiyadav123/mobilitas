import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenware/colorextensions.dart';
import 'package:greenware/login/login.dart';
import 'package:greenware/profile/profile.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var lat = 26.84096545294521;
  var lon = 80.93316410056923;

  String? _selectedLocation;
  List<String> _suggestions = [
    'Tarna',
    'Nadesar',
    'Pandeypur',
    'Chandmari',
    'Bhojubeer',
    "Shivpur"
  ];

  var nadesar = [25.34234866289763, 82.98052125134613];
  var tarna = [25.37336088740846, 82.91946307380431];
  var chandmari = [25.379155524365572, 82.97050556177106];
  var pandeypur = [25.349647850467502, 82.99348364256039];
  var bhojubeer = [25.35299080123028, 82.97566495370323];
  var shivpur = [25.354283670824657, 82.9657647888067];

  String? _selectedDestination;

  User? auth;
  String? userPhoto;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    fetchData();
  }

  Future<void> fetchData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        auth = user;
        userPhoto = user.photoURL;
      });
    }
  }

  // get photo url

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude;
      lon = position.longitude;
    });

    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lon), zoom: 19)));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  height: media.width / 5,
                  width: media.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: TColor.purple,
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(25)),
                          child: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      child: Wrap(
                                        children: <Widget>[
                                          ListTile(
                                            leading: Icon(Icons.music_note),
                                            title: Text('About'),
                                            onTap: () => showAboutDialog(
                                                context: context),
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.logout),
                                            title: Text('Logout'),
                                            onTap: () => {
                                              Navigator.pop(context),
                                              _firebaseLogout()
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.white,
                              )),
                        ),
                        Image.asset('assets/namee.png'),
                        GestureDetector(
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfilePage()))
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: TColor.black,
                                border:
                                    Border.all(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(25)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                userPhoto!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: media.height - 400,
                  width: media.width,
                  child: GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    ].toSet(),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition:
                        CameraPosition(target: LatLng(lat, lon), zoom: 10),
                    myLocationEnabled: true,
                    rotateGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                  ),
                ),
                Container(
                  width: media.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Where are you going today?",
                                style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 20,
                                    fontFamily: "San Fransisco",
                                    fontWeight: FontWeight.bold)),
                            Container(
                              height: 10,
                              width: 10,
                            ),
                            _startingPoint(),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _pickUpPoint(),
                        SizedBox(
                          height: 10,
                        ),
                        _dropPoint(),
                        SizedBox(
                          height: 10,
                        ),
                        _bookButton(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _firebaseLogout() {
    FirebaseAuth.instance.signOut().then((value) => {
          showToast('Logged out successfully',
              context: context, animation: StyledToastAnimation.slideFromTop),
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return Login();
          }))
        });
  }

  Widget _startingPoint() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          color: TColor.purple,
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(25)),
      child: IconButton(
          onPressed: () {
            _getCurrentLocation();
          },
          icon: const Icon(
            Icons.my_location,
            color: Colors.white,
          )),
    );
  }

  Widget _pickUpPoint() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: TColor.textFill,
          border: Border.all(color: TColor.borderStroke, width: 1),
          borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: DropdownButton<String>(
          isExpanded: true,
          icon: Icon(Icons.circle, color: TColor.purple),
          value: _selectedLocation,
          hint: Text('Choose your pick up point',
              style: TextStyle(color: TColor.textColor)),
          dropdownColor: TColor.textFill,
          iconEnabledColor: TColor.textColor,
          iconDisabledColor: Colors.white,
          underline: Container(),
          items: _suggestions.map((String suggestion) {
            return DropdownMenuItem<String>(
              value: suggestion,
              child:
                  Text(suggestion, style: TextStyle(color: TColor.textColor)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLocation = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _dropPoint() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: TColor.textFill,
          border: Border.all(color: TColor.borderStroke, width: 1),
          borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: DropdownButton<String>(
          isExpanded: true,
          icon: Icon(Icons.pin_drop, color: Colors.red),
          value: _selectedDestination,
          hint: Text('Choose your destination',
              style: TextStyle(color: TColor.textColor)),
          dropdownColor: TColor.textFill,
          iconEnabledColor: TColor.textColor,
          iconDisabledColor: Colors.white,
          underline: Container(),
          items: _suggestions.map((String suggestion) {
            return DropdownMenuItem<String>(
              value: suggestion,
              child:
                  Text(suggestion, style: TextStyle(color: TColor.textColor)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDestination = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _bookButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: TColor.black, borderRadius: BorderRadius.circular(40)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Book Now',
                  style: TextStyle(
                      color: TColor.white,
                      fontSize: 20,
                      fontFamily: "San Fransisco",
                      fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(
                    "Rs. 9",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: TColor.purple,
                        borderRadius: BorderRadius.circular(20)),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: TColor.white,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
