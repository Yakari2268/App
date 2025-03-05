import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DataPushScreen extends StatefulWidget {
  @override
  _DataPushScreenState createState() => _DataPushScreenState();
}

class _DataPushScreenState extends State<DataPushScreen> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  // Method to push data to Firebase RTDB
  void pushData() {
    // Create some data to push
    final newData = {
      'name': 'John Doe',
      'age': 30,
      'email': 'johndoe@example.com'
    };

    // Pushing data to Firebase RTDB under a specific reference (node)
    database.child('users').push().set(newData).then((_) {
      print('Data pushed successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data pushed successfully!')),
      );
    }).catchError((error) {
      print('Failed to push data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to push data $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Data to Firebase RTDB'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: pushData,
          child: Text('Push Data to Firebase RTDB'),
        ),
      ),
    );
  }
}