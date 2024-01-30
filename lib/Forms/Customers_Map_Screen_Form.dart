import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/Forms/MapSample_Form.dart';
import 'package:project/hive/customers_hive.dart';

class CustomerMapScreen extends StatelessWidget {
  final List<Customers> customers;
  final List<String> selectedFields;
  Position? userPosition;


  CustomerMapScreen({required this.customers,required this.selectedFields,required this.userPosition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: MapSample(selectedFields: selectedFields,filteredCustomers: customers,userPosition: userPosition,), // Include the MapSample widget here
    );
  }
}
