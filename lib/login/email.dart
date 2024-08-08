import 'package:flutter/material.dart';

class EmailEdit extends StatefulWidget {
  const EmailEdit({super.key});

  @override
  State<EmailEdit> createState() => _EmailEditState();
}

class _EmailEditState extends State<EmailEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Add your code here
          },
          child: const Text('Edit Email'),
        ),
      ),
    );
  }
}
