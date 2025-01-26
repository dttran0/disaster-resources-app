import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'hospital.dart';
import 'food_bank.dart';
import 'named_marker.dart';
import 'user_location.dart';

class ResourceListScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  ResourceListScreen({required this.latitude, required this.longitude});

  @override
  _ResourceListScreenState createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen>
    with SingleTickerProviderStateMixin {
  List<NamedMarker> hospitals = [];
  List<NamedMarker> foodBanks = [];
  bool isLoading = true;
  late TabController _tabController;
  LatLng _center = LatLng(34.0549, -118.2426);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Update the state when the tab index changes
      if (_tabController.indexIsChanging || !_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final hospitalService = HospitalService();
      final foodBankService = FoodBankService();


      var location = await LocationService().getLocation();
      if (location != null) {
        setState(() {
          _center = location;
        });
      }


        final fetchedHospitals = await hospitalService.fetchNearbyHospitals(
        widget.latitude,
        widget.longitude,
      );

      final fetchedFoodBanks = await foodBankService.fetchNearbyFoodBanks(
        widget.latitude,
        widget.longitude,
      );

      setState(() {
        hospitals = fetchedHospitals;

        foodBanks = fetchedFoodBanks;

        isLoading = false;
      });
    } catch (e) {
      print('Error fetching resources: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildList(LatLng _center, List<NamedMarker> items, IconData icon, Color iconColor) {
    return items.isEmpty
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
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: Icon(
              icon,
              color: iconColor,
            ),
            title: Text(
              item.name!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(item.address ?? "No address available"), // Handle null safety
            Text(
            "${Distance().as(LengthUnit.Kilometer, _center, item.point).toStringAsFixed(2)} km",
            style: TextStyle(color: Colors.grey), // Optional styling
            ),
            ],
            ),)
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTabIndex = _tabController.index;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Resources"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: activeTabIndex == 0 ? Colors.red : Colors.blue,
          labelColor: activeTabIndex == 0 ? Colors.red : Colors.blue,
          unselectedLabelColor: Color(0xFF333333),
          tabs: [
            Tab(
              icon: Icon(Icons.local_hospital),
              text: "Hospitals",
            ),
            Tab(
              icon: Icon(Icons.restaurant),
              text: "Food Banks",
            ),
          ],
        ),
      ),
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
          : TabBarView(
        controller: _tabController,
        children: [
          buildList(_center, hospitals, Icons.local_hospital, Colors.red),
          buildList(_center, foodBanks, Icons.restaurant, Colors.blue),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}