import 'package:flutter/material.dart';

class RideHistoryWidget extends StatefulWidget {
  const RideHistoryWidget({super.key});

  @override
  State<RideHistoryWidget> createState() => _RideHistoryWidgetState();
}

class _RideHistoryWidgetState extends State<RideHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ride History'),
        ),
        body: Center(
          child: Column(
            children: [],
          ),
        ));
  }
}
