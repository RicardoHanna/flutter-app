import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/Forms/MapSample_Form.dart';
import 'package:project/hive/customers_hive.dart';

class CustomerMapScreen extends StatelessWidget {
  final List<Customers> customers;

  CustomerMapScreen({required this.customers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Map'),
      ),
      body: MapSample(), // Include the MapSample widget here
    );
  }
}
