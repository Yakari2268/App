import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Expiry Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    loadFoodItems();
  }

  void loadFoodItems() async {
    var box = await Hive.openBox<Map>('food_expiry');
    if (box.isEmpty) {
      // Add initial test data
      await box.add({'name': 'Milk', 'expiryDate': DateTime.now().add(Duration(days: 5)).toIso8601String()});
      await box.add({'name': 'Bread', 'expiryDate': DateTime.now().add(Duration(days: 3)).toIso8601String()});
      await box.add({'name': 'Eggs', 'expiryDate': DateTime.now().add(Duration(days: 10)).toIso8601String()});
    }
    setState(() {
      foodItems = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  void addFoodItem(String name, DateTime expiryDate) async {
    var box = await Hive.openBox<Map>('food_expiry');
    box.add({'name': name, 'expiryDate': expiryDate.toIso8601String()});
    loadFoodItems();
  }

  void scanBarcode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Barcode'),
        content: SizedBox(
          height: 300,
          child: MobileScanner(
            onDetect: (BarcodeCapture barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              if (barcode.rawValue != null) {
                Navigator.pop(context);
                addFoodItem(barcode.rawValue!, DateTime.now().add(Duration(days: 7)));
              }
            },
          ),
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