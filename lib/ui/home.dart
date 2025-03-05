import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    loadFoodItems();
  }

  void loadFoodItems() {
    _database.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          foodItems = data.entries.map((e) => {
                'id': e.key,
                'name': e.value['name'],
                'expiryDate': e.value['expiryDate'],
              }).toList();
        });
      }
    });
  }

  void addFoodItem(String name, DateTime expiryDate) {
    final newItem = {
      'name': name,
      'expiryDate': expiryDate.toIso8601String(),
    };
    _database.push().set(newItem);
  }

  void scanBarcode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Barcode'),
        content: SizedBox(
          height: 300,
          child: Text("Barcode scanning logic here"), // Replace with scanner logic
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Expiry Tracker')),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          final item = foodItems[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('Expires on: ${item['expiryDate']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scanBarcode,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}