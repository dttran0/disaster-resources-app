import 'package:flutter/material.dart';
import 'hospital.dart';
import 'food_bank.dart';

class ResourceListScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  ResourceListScreen({required this.latitude, required this.longitude});

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
    try {
      // Use the latitude and longitude passed to the screen
      final hospitalService = HospitalService();
      final foodBankService = FoodBankService();

      final hospitals = await hospitalService.fetchNearbyHospitals(
        widget.latitude,
        widget.longitude,
      );

      final foodBanks = await foodBankService.fetchNearbyFoodBanks(
        widget.latitude,
        widget.longitude,
      );

      // Combine hospitals and food banks into a unified list
      final formattedItems = [
        ...hospitals.map((hospital) => {
          'name': hospital.name,
          'address': hospital.address,
          'type': 'hospital',
        }),
        ...foodBanks.map((foodBank) => {
          'name': foodBank.name,
          'address': foodBank.address,
          'type': 'food_bank',
        }),
      ];

      setState(() {
        items = formattedItems;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching resources: $e');
      setState(() {
        isLoading = false;
      });
    }
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
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
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
          ),
        ],
      ),
    );
  }
}
