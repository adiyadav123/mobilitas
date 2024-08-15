import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenware/colorextensions.dart';
import 'package:greenware/ride.dart';
import 'package:intl/intl.dart';

class RideHistoryWidget extends StatefulWidget {
  const RideHistoryWidget({super.key});

  @override
  State<RideHistoryWidget> createState() => _RideHistoryWidgetState();
}

class _RideHistoryWidgetState extends State<RideHistoryWidget> {
  Future<List<Ride>> getRidesFromFirebase() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<Ride> rides = [];
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> ridesData = data['rides'];

      ridesData.forEach((key, value) {
        rides.add(Ride.fromMap(value));
      });
    }

    return rides;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.purple,
      body: SafeArea(
        child: Column(
          children: [
            nav("Ride History"),
            Expanded(
              child: FutureBuilder<List<Ride>>(
                future: getRidesFromFirebase(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Ride> rides = snapshot.data ?? [];
                    if (rides.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "No rides yet",
                            style: TextStyle(
                              fontSize: 20,
                              color: TColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: rides.length,
                        itemBuilder: (BuildContext context, int index) {
                          String startTimeString = DateFormat('kk:mm')
                              .format(rides[index].startTime.toDate());
                          String endTimeString = DateFormat('kk:mm')
                              .format(rides[index].endTime.toDate());
                          return ListTile(
                            subtitle: rideItem(
                                rides[index], startTimeString, endTimeString),
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nav(page) {
    return Container(
      height: 120,
      color: TColor.purple,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  "$page",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
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
    );
  }

  Widget rideItem(Ride ride, String startTime, String endTime) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: TColor.borderStroke),
        borderRadius: BorderRadius.circular(20),
      ),
      height: 220,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: TColor.rideContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: TColor.borderStroke,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  points(
                      ride.startPoint, startTime, Icons.circle, TColor.purple),
                  SizedBox(height: 30),
                  points(ride.finalPoint, endTime, Icons.pin_drop,
                      TColor.locationPinColor),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: disTime(ride.distance.toString(), ride.price.toString()),
          ),
        ],
      ),
    );
  }

  Widget points(location, time, icon, color) {
    return Row(
      children: [
        Container(
          child: Row(
            children: [
              Icon(icon, color: color, size: 25),
              SizedBox(width: 10),
              Text(
                location,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Spacer(),
        Container(
          child: Row(
            children: [
              Text(
                time.toString(),
                style: TextStyle(
                  fontSize: 15,
                  color: TColor.rideTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget disTime(distance, price) {
    return Container(
      child: Row(
        children: [
          Container(
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Distance",
                    style: TextStyle(fontSize: 15, color: TColor.rideTextColor),
                  ),
                  Text(
                    "$distance km",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Container(
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Price",
                    style: TextStyle(fontSize: 15, color: TColor.rideTextColor),
                  ),
                  Text(
                    "₹$price",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
