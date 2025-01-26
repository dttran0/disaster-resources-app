import 'package:flutter/material.dart';
import 'dart:math'; // For random data generation

class ResourceListScreen extends StatefulWidget {
  @override
  _ResourceListScreenState createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  List<Map<String, String>> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    // Simulate a delay to mimic an API call
    await Future.delayed(Duration(seconds: 2));

    // Generate mock data for hospitals and food banks
    final random = Random();
    final mockItems = List.generate(10, (index) {
      final isHospital =
      random.nextBool(); // Randomly decide if it's a hospital
      return {
        'name': isHospital
            ? 'Hospital ${random.nextInt(100)}'
            : 'Food Bank ${random.nextInt(100)}',
        'address':
        '${random.nextInt(9999)} Main St, City ${random.nextInt(50)}',
        'type': isHospital ? 'hospital' : 'food_bank', // Type field
      };
    });

    // Update the state with mock data
    setState(() {
      items = mockItems;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Resources"), centerTitle: true),
      backgroundColor: Color(0xFF333333),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Fetching data...",
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
          : items.isEmpty
          ? Center(
        child: Text(
          "No resources available.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isHospital = item['type'] == 'hospital';

          return Card(
            margin: EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(
                isHospital
                    ? Icons.local_hospital
                    : Icons.restaurant,
                color: isHospital ? Colors.red : Colors.blue,
              ),
              title: Text(
                item['name']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item['address']!),
            ),
          );
        },
      ),
    );
  }
}