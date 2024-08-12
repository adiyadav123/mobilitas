import 'dart:developer';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greenware/colorextensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


class BookCycle extends StatefulWidget {
  const BookCycle({super.key});

  @override
  State<BookCycle> createState() => _BookCycleState();
}

class _BookCycleState extends State<BookCycle> {
  @override
  void initState() {
    super.initState();
    requestBluetoothPermission();
  }

  

  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;

  var _isGranted = 'Unknown';

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

  void startScan() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    _devices.clear();

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
                          "Book a cycle",
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
                color: TColor.white,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Select a cycle",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 20,
                              fontFamily: "Sans Fransisco",
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        _devices.length == 0
                            ? Text("No devices found")
                            : SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: _devices.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          (_devices[index].name.toString())),
                                      subtitle: Text(_devices[index].address),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BookCycle()));
                                      },
                                    );
                                  },
                                ),
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: startScan,
                            child: Text("Scan for devices"),
                          ),
                        ),
                        Text(
                          "OR",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                onPressed: () {}, child: Text("Scan QR")))
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
