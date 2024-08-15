import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:greenware/colorextensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookCycle extends StatefulWidget {
  final int? price;
  final String? startingPoint;
  final String? finalPoint;
  final int? distance;
  const BookCycle(
      {super.key,
      required this.price,
      required this.startingPoint,
      required this.finalPoint,
      required this.distance});

  @override
  State<BookCycle> createState() => _BookCycleState();
}

class _BookCycleState extends State<BookCycle> {
  @override
  void initState() {
    super.initState();
    requestBluetoothPermission();
  }

  String _scanResult = '';
  BluetoothConnection? _connection;

  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;

  var _isGranted = 'Unknown';
  bool _isConnected = false;

  List<BluetoothDevice> _devices = [];

  Future<void> requestBluetoothPermission() async {
    PermissionStatus permissionStatus =
        await Permission.bluetoothScan.request();

    PermissionStatus permissionStatus2 =
        await Permission.bluetoothConnect.request();

    if (permissionStatus.isGranted && permissionStatus2.isGranted) {
      setState(() {
        _isGranted = 'Bluetooth permission granted';
      });
    } else {
      setState(() {
        _isGranted = 'Bluetooth permission denied';
      });
    }
  }

  Future<void> scanCode() async {
    String? barCodeScanRes;
    PermissionStatus permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      try {
        print("Scanning");
        barCodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", "Cancel", true, ScanMode.QR);
      } on PlatformException {
        barCodeScanRes = 'Failed to get platform version.';
      }
      setState(() {
        _scanResult = barCodeScanRes ?? '';
      });

      if (_scanResult.isNotEmpty) {
        connect(_scanResult);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Camera permission denied"),
      ));
    }
  }

  void startScan() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    _devices.clear();
    await _connection?.close();

    if (await FlutterBluetoothSerial.instance.state ==
        BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
      setState(() {
        _devices.add(event.device);
      });
    });
  }

  void connect(String address) async {
    if (_isGranted == 'Bluetooth permission granted') {
      _devices.clear();
      await _connection?.close();

      if (await FlutterBluetoothSerial.instance.state ==
          BluetoothState.STATE_OFF) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }
      try {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Connecting"),
        ));
        await BluetoothConnection.toAddress(address).then((value) {
          _connection = value;
        });
        setState(() {
          _isConnected = true;
        });

        _connection!.input!.listen(null).onDone(() {
          if (_isConnected) {
            print("Disconnected by remote request");
            setState(() {
              _isConnected = false;
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Connected"),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to connect"),
        ));
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Bluetooth permission denied"),
      ));
    }
  }

  void checkConnection() async {
    if (_connection != null) {
      if (_connection!.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Connected"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Not connected"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Not connected"),
      ));
    }
  }

  Future<void> sendData(String text) async {
    if (_connection != null) {
      if (_connection!.isConnected) {
        _connection!.output.add(utf8.encode(text));
        await _connection!.output.allSent.then((_) => {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Data sent"),
              )),
            });
      }
    }
  }

  void disconnect() async {
    if (_connection != null) {
      if (_connection!.isConnected) {
        await _connection!.close();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Disconnected"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Not connected"),
      ));
    }
  }

  void updateFirebase() async {
    num distance = widget.distance ?? 0;
    var user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentReference =
        firestore.collection('users').doc(user!.uid);

    var doc = await documentReference.get();
    int currentDistance = (doc['totalDistance'] as num).toInt();
    int currentRides = (doc['totalRides'] as num).toInt();
    int currentAmount = (doc['totalSpent'] as num).toInt();

    var data = {
      'rides': {
        'ride${Random().nextInt(100)}': {
          'endTime': Timestamp.now(),
          'price': widget.price,
          'review': 4,
          'startPoint': widget.startingPoint,
          'finalPoint': widget.finalPoint,
          'startTime': Timestamp.now(),
          'distance': widget.distance
        }
      },
      'totalSpent': (currentAmount.toInt()) + (widget.price!).toInt(),
      'totalDistance': (currentDistance).toInt() + distance.toInt(),
      'totalRides': (currentRides).toInt() + 1
    };

    documentReference.set(data, SetOptions(merge: true)).then((value) {
      print("data updated");
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
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
                          "Book an e-cycle",
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
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: TColor.white,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            "Select to unlock an e-cycle",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                onPressed: () {
                                  scanCode();
                                },
                                child: Text("Scan QR"))),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Pay and unlock"),
                                          content: Container(
                                            height: 130,
                                            width: 150,
                                            child: Column(
                                              children: [
                                                Text(
                                                    "Pay Rs. ${widget.price?.toStringAsFixed(2)} to unlock the cycle"),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      sendData("YES");
                                                      Navigator.of(context)
                                                          .pop();
                                                      updateFirebase();
                                                    },
                                                    child:
                                                        Text("Pay and unlock")),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Text("Open Lock"))),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
}
