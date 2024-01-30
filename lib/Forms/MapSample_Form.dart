import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:project/classes/UserPreferences.dart';
import 'package:project/hive/customeraddresses_hive.dart';
import 'package:project/hive/customers_hive.dart';

class MapSample extends StatefulWidget {
    final List<String> selectedFields; // Add selectedFields parameter
      final List<Customers> filteredCustomers;
     final Position?  userPosition;

  const MapSample({Key? key, required this.selectedFields,required this.filteredCustomers,required this.userPosition}) : super(key: key);

  @override
  _MapSampleState createState() => _MapSampleState();
}
class _MapSampleState extends State<MapSample> {
  late final Completer<GoogleMapController> _controller = Completer();
  late List<CustomerAddresses> customerAddresses = [];
    UserPreferences userPreferences = UserPreferences();
  Map<String, String> custNames = {}; // Store custNames temporarily

  static final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(33.8547, 35.8623),
    zoom: 10.0,
  );

  @override
  void initState() {
    super.initState();
    loadCustomerAddresses();
  }

Future<void> loadCustomerAddresses() async {
  var customerAddressesBox = await Hive.openBox<CustomerAddresses>('customerAddressesBox');
  var customersBox = await Hive.openBox<Customers>('customersBox');

  setState(() {
    customerAddresses = customerAddressesBox.values.toList();
    // Filter customerAddresses based on the custCode from filteredCustomers
    customerAddresses = customerAddresses.where((address) =>
        widget.filteredCustomers.any((customer) => customer.custCode == address.custCode)).toList();

    // Iterate through the customer addresses and update custCode, custName
    customerAddresses.forEach((address) {
      // Retrieve customer information based on custCode
      Customers? customer = customersBox.get(address.cmpCode + address.custCode);

      // If customer information exists, update the custNames map with custCode and custName
      if (customer != null) {
        custNames[address.custCode] = customer.custName ?? '';
      }
    });
  });

  print(widget.selectedFields);
  for (var field in widget.selectedFields) {
    print(field);
  }
}

void _showEditDialog(String custCode, String currentAdditionalInfo) {
  TextEditingController additionalInfoController = TextEditingController(text: currentAdditionalInfo);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Additional Information'),
        content: TextField(
          controller: additionalInfoController,
          decoration: InputDecoration(labelText: 'Additional Information'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Save the additional information to your data model or storage
              String additionalInfo = additionalInfoController.text;
              // Perform the necessary actions with the additional information
              // For example, you can update your data model or send it to a database
              _saveAdditionalInfo(custCode, additionalInfo);
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


void _saveAdditionalInfo(String custCode, String additionalInfo) {
  var customerAddressesBox = Hive.box<CustomerAddresses>('customerAddressesBox');

  // Find the CustomerAddresses object with the matching custCode
  int index = customerAddresses.indexWhere((address) => address.custCode == custCode);

  if (index != -1) {
    // Update the additionalInfo field
    customerAddresses[index].notes = additionalInfo;

    // Save the updated CustomerAddresses object back to the box
    customerAddressesBox.putAt(index, customerAddresses[index]);

    // Update the state to reflect the changes immediately
    setState(() {
      customerAddresses = customerAddressesBox.values.toList();
    });
  }
}


Set<Marker> _getMarkers() {
  Set<Marker> markers = {};

  // Add markers for customer addresses
  markers.addAll(customerAddresses.map((address) {
    double gpsLat = double.tryParse(address.gpslat) ?? 0.0;
    double gpsLong = double.tryParse(address.gpslong) ?? 0.0;
    String custName = custNames[address.custCode] ?? ''; // Get custName from the custNames map
    return Marker(
      markerId: MarkerId(address.custCode),
      position: LatLng(gpsLat, gpsLong),
      infoWindow: InfoWindow(
        title: '${address.custCode} - $custName',
        snippet: () {
          String snippet = '${address.notes}' ?? 'Tap to edit additional info'; // Include notes in the snippet
          // Check if selectedFields is not null and contains fields
          if (widget.selectedFields != null && widget.selectedFields.isNotEmpty) {
            // Include selected fields next to custCode
            String fieldsSnippet = widget.selectedFields.map((field) {
              switch (field) {
                case 'AddressId':
                  return '${address.addressID}';
                case 'Address':
                  return '${address.address}';
                case 'RegCode':
                  return '${address.regCode}';
                default:
                  return ''; // Handle unknown fields
              }
            }).where((fieldValue) => fieldValue.isNotEmpty).join(', '); // Join non-empty field values with a comma
            if (fieldsSnippet.isNotEmpty) {
              snippet += ' - $fieldsSnippet'; // Concatenate selected fields to the snippet
            }
          }
          return snippet; // Return the final snippet
        }(),
        onTap: () {
          _showEditDialog(address.custCode, address.notes);
        },
      ),
    );
  }));

  // Add marker for user's position
  if (widget.userPosition != null) {
    markers.add(
      Marker(
        markerId: MarkerId('userPosition'),
        position: LatLng(widget.userPosition!.latitude, widget.userPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan), // Change marker color to cyan
      ),
    );
  }

  return markers;
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
  mapType: MapType.hybrid,
  initialCameraPosition: _kGooglePlex,
  onMapCreated: (GoogleMapController controller) {
    _controller.complete(controller);
  },
  markers: _getMarkers(), // Pass user's position to the _getMarkers function
),

    );
  }
}
