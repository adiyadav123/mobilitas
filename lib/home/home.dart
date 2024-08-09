import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenware/booking/book.dart';
import 'package:greenware/colorextensions.dart';
import 'package:greenware/login/login.dart';
import 'package:greenware/profile/profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var lat = 26.84096545294521;
  var lon = 80.93316410056923;

  final Map<String, List<double>> _places = {
    'Tarna': [25.37336088740846, 82.91946307380431],
    'Nadesar': [25.34234866289763, 82.98052125134613],
    'Pandeypur': [25.349647850467502, 82.99348364256039],
    'Chandmari': [25.379155524365572, 82.97050556177106],
    'Bhojubeer': [25.35299080123028, 82.97566495370323],
    'Shivpur': [25.354283670824657, 82.9657647888067],
  };

  // var nadesar = [25.34234866289763, 82.98052125134613];
  // var tarna = [25.37336088740846, 82.91946307380431];
  // var chandmari = [25.379155524365572, 82.97050556177106];
  // var pandeypur = [25.349647850467502, 82.99348364256039];
  // var bhojubeer = [25.35299080123028, 82.97566495370323];
  // var shivpur = [25.354283670824657, 82.9657647888067];
  String? _selectedLocation;
  List<double>? _selectedLocationCoords;

  String? _selectedDestination;
  List<double>? _selectedDestinationCoords;

  final fixedCharge = 5;
  final perKmCharge = 2;
  double? distanceInKm;
  double? totalFare;

  String googleApiKey = "AIzaSyAebh-ZBqHRXAKHJhLr_ztwBkfLZPZr_hM";

  User? auth;
  String? userPhoto;

  Set<Marker> _markers = {};

  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};

  void getPolylines() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(_selectedLocationCoords![0], _selectedLocationCoords![1]),
        PointLatLng(
            _selectedDestinationCoords![0], _selectedDestinationCoords![1]));

    if (result.points.isNotEmpty) {
      setState(() {
        _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            color: TColor.purple,
            points: result.points
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList()));
      });
    }
  }

  var chandmari = LatLng(25.379155524365572, 82.97050556177106);
  var bhojubeer = LatLng(35.299080123028, 82.97566495370323);

  void getDistance() {
    double distanceInMeters = Geolocator.distanceBetween(
        _selectedLocationCoords![0],
        _selectedLocationCoords![1],
        _selectedDestinationCoords![0],
        _selectedDestinationCoords![1]);

    if (distanceInMeters != null) {
      if (distanceInMeters <= 3000) {
        setState(() {
          distanceInKm = distanceInMeters / 1000;
          totalFare = fixedCharge.toDouble();
        });
      } else {
        setState(() {
          distanceInKm = distanceInMeters / 1000;
          totalFare = distanceInKm! * perKmCharge;
        });
      }
    } else {
      setState(() {
        totalFare = 0;
      });
    }
  }

  void onPlaceSelected(String? place, bool isDestination) {
    if (place != null && _places.containsKey(place)) {
      List<double> location = _places[place]!;

      if (isDestination) {
        _markers.add(Marker(
          markerId: MarkerId('destination'),
          position: LatLng(location[0], location[1]),
        ));
        setState(() {
          _selectedDestinationCoords = location;
        });

        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(location[0], location[1]), zoom: 12)));
      } else {
        _markers.add(Marker(
          markerId: MarkerId('startpoint'),
          position: LatLng(location[0], location[1]),
        ));
        setState(() {
          _selectedLocationCoords = location;
        });

        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(location[0], location[1]), zoom: 12)));
      }
    }

    if (_selectedLocationCoords != null && _selectedDestinationCoords != null) {
      getDistance();
      getPolylines();

      print('Distance: $distanceInKm');
      print('Total Fare: $totalFare');
    }
  }

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
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // setState(() {
    //   lat = position.latitude;
    //   lon = position.longitude;
    // });

    // _mapController?.animateCamera(CameraUpdate.newCameraPosition(
    //     CameraPosition(target: LatLng(lat, lon), zoom: 19)));
    Location location = Location();
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    if (permission == PermissionStatus.granted) {
      LocationData locationData = await location.getLocation();
      setState(() {
        lat = locationData.latitude!;
        lon = locationData.longitude!;
      });
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lon), zoom: 19)));
    }
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
                        Image.asset('assets/name.png'),
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
                    markers: _markers,
                    polylines: _polylines,
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
            print(_selectedDestination);
            print(_selectedLocation);
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
          items: _places.keys.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: TColor.textColor)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLocation = newValue;
            });
            onPlaceSelected(newValue, false);
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
          items: _places.keys.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: TColor.textColor)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDestination = newValue;
            });
            onPlaceSelected(newValue, true);
          },
        ),
      ),
    );
  }

  Widget _bookButton() {
    return GestureDetector(
      onTap: () {
        _directToBook();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: TColor.black, borderRadius: BorderRadius.circular(40)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 11.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Text('Book Now',
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 20,
                            fontFamily: "San Fransisco",
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹ ${totalFare?.toStringAsFixed(2) ?? '0.00'}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: TColor.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: TColor.black,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _directToBook() {
    if (_selectedDestinationCoords == null || _selectedLocationCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location')));
      return;
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const BookCycle()));
  }
}
