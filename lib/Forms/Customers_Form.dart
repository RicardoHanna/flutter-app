import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Customers_Info_Form.dart';
import 'package:project/Forms/Customers_Map_Screen_Form.dart';
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/DataSearch.dart';
import 'package:project/classes/DataSearchCustomers.dart';
import 'package:project/classes/UserPreferences.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/customeraddresses_hive.dart';
import 'package:project/hive/customerbrandsspecialprice_hive.dart';
import 'package:project/hive/customercontacts_hive.dart';
import 'package:project/hive/customergroupitemsspecialprice_hive.dart';
import 'package:project/hive/customergroupsspecialprice_hive.dart';
import 'package:project/hive/customerpropgroupspecialprice_hive.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
import 'package:project/hive/salesemployees_hive.dart';
import 'package:project/hive/salesemployeescustomers_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/userssalesemployees_hive.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/utils.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/resources/add_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/Synchronize/DataSynchronizer.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';


class CustomersForm extends StatefulWidget {
 
  final AppNotifier appNotifier;
  final String userCode;
  final String defltCompanyCode;
  CustomersForm({required this.appNotifier,required this.userCode,required this.defltCompanyCode});
  @override
  State<CustomersForm> createState() => _customersFormState();
}

class _customersFormState extends State<CustomersForm> {
  UserPreferences userPreferences = UserPreferences();

bool _showSubMenu = false;
 bool? active;
 late List<Customers> customers;
  late List<Customers> filteredCustomers=[];
late List<String> groupList = [];
  late List<String> cmpCodeList = [];
  late List<String> cmpList = [];
  late List<String> selectedGroups = [];
  late List<String> selectedCmpCode = [];
  late List<String> selectedCategories = [];
   late String selectedSortingOption = 'Alphabetic';
  late Box<Customers> customerBox;
final TextEditingController codeFilterController = TextEditingController();
  final TextEditingController groupFilterController = TextEditingController();
  final TextEditingController custNameFilterController = TextEditingController();
  final TextEditingController categoryFilterController = TextEditingController();
 TextEditingController searchController = TextEditingController();
    TextStyle   _appTextStyleNormal = TextStyle();
    late Position _currentPosition;
     Position? userPosition;

late Box<CustomerAddresses> customerAddressesBox;
late List<Customers> allCustomers = [];
  @override
@override
void initState() {
  super.initState();
  // Call async method within initState
  customerBox = Hive.box<Customers>('customersBox');
    customerAddressesBox = Hive.box<CustomerAddresses>('customerAddressesBox');

  initializeData();
  loadCheckboxPreferences();
  printUserDataTranslations();
    _getCurrentLocation();

}

Future<void> loadCheckboxPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  setState(() {
    userPreferences.showActiveCustomers = prefs.getBool('showActive') ?? false;
    userPreferences.showCurCodeCustomers = prefs.getBool('showCurCode') ?? false;
    userPreferences.showDiscTypeCustomers = prefs.getBool('showItemType') ?? false;
   // userPreferences.showItemName = prefs.getBool('showItemName') ?? false;
    userPreferences.showMOFNumCustomers = prefs.getBool('showMOFNum') ?? false;

    userPreferences.showAddressIdCustMap= prefs.getBool('showAddressId') ?? false;
    userPreferences.showAddressCustMap= prefs.getBool('showAddress') ?? false;
      userPreferences.showregCodeCustMap= prefs.getBool('showregCode') ?? false;

  });
}


 Future<void> initializeData() async {
    customers = await _getCustomers();
    filteredCustomers = List.from(customers);
  allCustomers = customerBox.values.toList();

    groupList = await getDistinctValuesFromBox('groupCode', customerBox);
   cmpCodeList= await getDistinctValuesFromBox('cmpCode', customerBox);
   
  }

  Future<double> calculateDistance(String cmpCode,String addressId,String custCode, Position userPosition) async {

  var address = customerAddressesBox.get('$cmpCode$addressId$custCode');
  print(address?.custCode);
  if (address != null) {
    // Retrieve GPS coordinates for customer
    double gpsLat = double.tryParse(address.gpslat ?? '') ?? 0.0;
    double gpsLong = double.tryParse(address.gpslong ?? '') ?? 0.0;
    // Calculate distance between customer and user's location
    double distance = Geolocator.distanceBetween(
        userPosition.latitude, userPosition.longitude, gpsLat, gpsLong);
    return distance;
  } else {
    return double.infinity; // Indicate that GPS coordinates are not available
  }
}


  Future<List<String>> getDistinctValuesFromBox(String fieldName, Box<Customers> box) async {
    var distinctValues = <String>[];
    var distinctSet = <String>{};

    for (var customer in box.values) {
      var value = getField(customer, fieldName);
      if (value != null && distinctSet.add(value)) {
        distinctValues.add(value);
      }
    }

    return distinctValues;
  }
dynamic getField(Customers customers, String fieldName) {
    switch (fieldName) {
      case 'groupCode':
        return customers.groupCode;
      case 'cmpCode':
        return customers.cmpCode;
      // Add cases for other fields as needed
      default:
        return null;
    }
  }

  
void _showCustomerMap() {
  // Retrieve GPS coordinates from CustomerAddresses box
  // based on the cmpCode and display the map screen
  List<String> selectedFields = userPreferences.getSelectedFieldsCustMap();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CustomerMapScreen(
        customers: filteredCustomers,
        selectedFields: selectedFields,
        userPosition: userPosition,
      
      ),
    ),
  );
}
Future<void> _getCurrentLocation() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, throw error
      throw Exception('Location services are disabled.');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Location permission denied, throw error
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied, throw error
      throw Exception('Location permissions are permanently denied.');
    }

    // Location permissions are granted, get current position
    Position position = await Geolocator.getCurrentPosition();
    
    setState(() {
      userPosition = position; // Assign user's position
      print('ric');
      print(userPosition);
    });
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> printUserDataTranslations() async {
 var custBox = await Hive.openBox<Companies>('companiesBox');

    print('Printinggg Users:');
    for (var cust in custBox.values) {
      print('CmpCode: ${cust.cmpCode}');
      print('Name: ${cust.cmpFName}');
      print(cust.address);

      print('-------------------------');
    }
  // Open 'translationsBox' for Translations
  List<String> selectedFields = userPreferences.getSelectedFieldsCustMap();
print(selectedFields);
  for(var field in selectedFields){
print(field);
  }
  print('Printed all data');


}

Future<List<Customers>> _getCustomers() async {
  // Retrieve changes from the local database
  var customersBox = await Hive.openBox<Customers>('customersBox');
  var usersSalesEmployeesBox = await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');
  var salesEmployeesCustomersBox = await Hive.openBox<SalesEmployeesCustomers>('salesEmployeesCustomersBox');


  try {

    // Find the UserSalesEmployees objects with matching userCode
   // var userSalesEmployees = usersSalesEmployeesBox.values.where((userSalesEmployee) => userSalesEmployee.userCode == widget.userCode && userSalesEmployee.cmpCode==widget.defltCompanyCode);

    List<Customers> allCustomers = [];
    allCustomers=customersBox.values.toList();

    // Iterate through each userSalesEmployee object
   /* for (var userSalesEmployee in userSalesEmployees) {
      var cmpCode = userSalesEmployee.cmpCode;
      var seCode = userSalesEmployee.seCode;

      // Find all SalesEmployeesItems with matching cmpCode and seCode
      var salesEmployeeCustomers = salesEmployeesCustomersBox.values.where((salesEmployeeCustomer) => 
        salesEmployeeCustomer.cmpCode == cmpCode && salesEmployeeCustomer.seCode == seCode);

      // Iterate through each SalesEmployeesItem for the current userSalesEmployee
      for (var salesEmployeeCustomer in salesEmployeeCustomers) {
        var custCode = salesEmployeeCustomer.custCode;

        // Retrieve items from the items box based on itemCode and cmpCode
        var customers = customersBox.values.where((customer) => customer.cmpCode == cmpCode && customer.custCode == custCode).toList();
        
        // Add the retrieved items to the list
        allCustomers.addAll(customers);
      }
    }


*/
    return allCustomers;
  } catch (e) {
    print("Error: $e");

 

    return []; // Return an empty list if an error occurs
  }
}

 Widget _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22),
      backgroundColor: Color(0xFF2196F3),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // Main button
        SpeedDialChild(
          child: Icon(Icons.map),
          backgroundColor: Color(0xFF2196F3),
          onTap: () {
            _showCustomerMap();
          },
          label: AppLocalizations.of(context)!.map,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 16.0,
          ),
          labelBackgroundColor: Color(0xFF2196F3),
        ),
        // Sub button 1
        SpeedDialChild(
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF2196F3),
          onTap: () {
          _showSettingsDialogMaps();
          },
          label: AppLocalizations.of(context)!.addFieldsMap,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 16.0,
          ),
          labelBackgroundColor: Color(0xFF2196F3),
        ),
        // Sub button 2
        SpeedDialChild(
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF2196F3),
          onTap: () {
         _showSettingsDialog();
          },
          label: AppLocalizations.of(context)!.addFieldsCustomers,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 16.0,
          ),
          labelBackgroundColor: Color(0xFF2196F3),
        ),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  TextStyle _appTextStyleLead = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 2);
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble() - 6);

  return Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.customers, style: _appTextStyleLead),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: DataSearchCustomers(customersList: customers, appNotifier: widget.appNotifier));
          },
        ),
        PopupMenuButton<String>(
          onSelected: (String value) {
            setState(() {
              selectedSortingOption = value;
              _applySorting();
            });
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'GroupCode',
              child: Text(AppLocalizations.of(context)!.sortbygroupcode, style: _appTextStyleLead),
            ),
            PopupMenuItem<String>(
              value: 'Alphabetic',
              child: Text(AppLocalizations.of(context)!.sortalphabetic, style: _appTextStyleLead),
            ),
            PopupMenuItem<String>(
              value: 'GPS',
              child: Text(AppLocalizations.of(context)!.sortbygps, style: _appTextStyleLead),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            _showFilterDialog(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.camera),
          onPressed: () async {
            String barcode = await scanBarcode();
            if (barcode.isNotEmpty) {
              var scannedCust = customers.firstWhere((customer) => customer.barcode == barcode, orElse: null);
              if (scannedCust != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomersInfoForm(customer: scannedCust, appNotifier: widget.appNotifier),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Scanned Customer not found'),
                  ),
                );
              }
            }
          },
        ),
      ], // Closing parenthesis for actions
    ), // Closing parenthesis for AppBar
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Customers>>(
          future: _getCustomers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No Customers found');
            } else {
              return ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  var customer = filteredCustomers[index];
                  return Card(
                    child: ListTile(
                      leading: Text(customer.custCode ?? '', style: _appTextStyleLead),
                      subtitle: buildTrailingWidget(customer),
                      title: Text(customer.custName ?? '', style: _appTextStyle),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomersInfoForm(customer: customer, appNotifier: widget.appNotifier),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    ),
    floatingActionButton: Align(
  alignment: Directionality.of(context) == TextDirection.rtl
      ? Alignment.bottomRight
      : Alignment.bottomRight,
  child: Padding(
    padding: EdgeInsets.only(
      right: Directionality.of(context) == TextDirection.rtl ? 23.0 : 0.0,
      left: Directionality.of(context) == TextDirection.ltr ? 23.0 : 0.0,
    ),
    child: _getFAB(),
  ),
),

  );
}



 Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
  return CheckboxListTile(
    title: Text(label),
    value: value,
    onChanged: onChanged,
  );
}
// Helper method to build the trailing widget based on user preferences
 Widget buildTrailingWidget(Customers customer) {
               TextStyle   _appTextStylewidgets = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-7);
  List<Widget> widgets = [];
  List<String> selectedFields = userPreferences.getSelectedFieldsCust();

  for (var field in selectedFields) {
    switch (field) {
      case 'Active':
        widgets.add(Text(customer.active.toString(),style: _appTextStylewidgets,));
        break;
      case 'CurCode':
        widgets.add(Text(customer.curCode.toString(),style: _appTextStylewidgets,));
        break;
      case 'DiscType':
        widgets.add(Text(customer.discType ?? '',style: _appTextStylewidgets,),);

      case 'MOFNum':
        widgets.add(Text(customer.mofNum ?? '',style: _appTextStylewidgets,));
        break;
    }
  }

return Container(
  padding: EdgeInsets.all(8.0),

  child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: _buildSeparatedWidgets(widgets),
  ),
);



}

List<Widget> _buildSeparatedWidgets(List<Widget> widgets) {
  List<Widget> separatedWidgets = [];

  for (int i = 0; i < widgets.length; i++) {
    separatedWidgets.add(widgets[i]);

    if (i < widgets.length - 1) {
      // Add "|" only between items, not after the last item
      separatedWidgets.add(Text("|"));
    }
  }

  return separatedWidgets;
}

  Future<void> _showSettingsDialogMaps() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String?> selectedOptions = [
    userPreferences.showAddressIdCustMap ? 'AddressId' : null,
    userPreferences.showAddressCustMap ? 'Address' : null,
  userPreferences.showregCodeCustMap ? 'RegCode' : null,
  ];


  // ignore: use_build_context_synchronously
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.choosefields,style: _appTextStyleNormal,),
            content: Column(
              children: <Widget>[
                
                for (int i = 0; i < 3; i++)
                  _buildDropdownMaps(
                    AppLocalizations.of(context)!.field+'${i + 1}',
                    selectedOptions[i],
                    (String? newValue) {
                      setState(() {
                        selectedOptions[i] = newValue;
                      });
                    },
                    
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.save,style: _appTextStyleNormal,),
                onPressed: () async {
                  userPreferences.showAddressIdCustMap = selectedOptions.contains('AddressId');
                  userPreferences.showAddressCustMap = selectedOptions.contains('Address');
                  userPreferences.showregCodeCustMap = selectedOptions.contains('RegCode');
             

                  // Save dropdown preferences to shared preferences
                  await prefs.setBool('showAddressId', userPreferences.showAddressIdCustMap);
                  await prefs.setBool('showAddress', userPreferences.showAddressCustMap);
                  await prefs.setBool('showregCode', userPreferences.showregCodeCustMap);


                  _applySorting(); // Call the method to update items
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildDropdownMaps(String label, String? selectedValue, Function(String?) onChanged) {
  return Row(
    children: [             
      Text(label),
      SizedBox(width: 10),
      DropdownButton<String>(
        value: selectedValue,
        onChanged: onChanged,
        items: [
          DropdownMenuItem<String>(
            value: 'AddressId',
            child: Text(AppLocalizations.of(context)!.addressId),
          ),
          DropdownMenuItem<String>(
            value: 'Address',
            child: Text(AppLocalizations.of(context)!.address),
          ),
          DropdownMenuItem<String>(
            value: 'RegCode',
            child: Text(AppLocalizations.of(context)!.regCode),
          ),
       
           DropdownMenuItem<String>(
            value: '',
            child: Text(''),
          ),
          // Add other options as needed
        ],
      ),
    ],
  );
}

Future<void> _showSettingsDialog() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String?> selectedOptions = [
    userPreferences.showActiveCustomers ? 'Active' : null,
    userPreferences.showCurCodeCustomers ? 'CurCode' : null,
    userPreferences.showDiscTypeCustomers ? 'DiscType' : null,
    userPreferences.showMOFNumCustomers ? 'MOFNum' : null,
  ];

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.choosefields, style: _appTextStyleNormal,),
            content: Column(
              children: <Widget>[
                for (int i = 0; i < 4; i++)
                  _buildDropdown(
                    AppLocalizations.of(context)!.field+'${i + 1}',
                    selectedOptions[i],
                    (String? newValue) {
                      setState(() {
                        selectedOptions[i] = newValue;
                      });
                    },
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.save, style: _appTextStyleNormal,),
                onPressed: () async {
                  userPreferences.showActiveCustomers = selectedOptions.contains('Active');
                  userPreferences.showCurCodeCustomers = selectedOptions.contains('CurCode');
                  userPreferences.showDiscTypeCustomers = selectedOptions.contains('DiscType');
                  userPreferences.showMOFNumCustomers = selectedOptions.contains('MOFNum');

                  // Save dropdown preferences to shared preferences
                  await prefs.setBool('showActive', userPreferences.showActiveCustomers);
                  await prefs.setBool('showCurCode', userPreferences.showCurCodeCustomers);
                  await prefs.setBool('showDiscType', userPreferences.showDiscTypeCustomers);
                  await prefs.setBool('showMOFNum', userPreferences.showMOFNumCustomers);

                  _applySorting(); // Call the method to update items
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildDropdown(String label, String? selectedValue, Function(String?) onChanged) {
  return Row(
    children: [             
      Flexible(
        child: Text(label),
      ),
      SizedBox(width: 10),
      Flexible(
        flex: 4, // Adjust the flex factor as needed
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String>(
              value: 'Active',
              child: Text(AppLocalizations.of(context)!.active),
            ),
            DropdownMenuItem<String>(
              value: 'CurCode',
              child: Text(AppLocalizations.of(context)!.curCode),
            ),
            DropdownMenuItem<String>(
              value: 'DiscType',
              child: Text(AppLocalizations.of(context)!.discountType),
            ),
            DropdownMenuItem<String>(
              value: 'MOFNum',
              child: Text(AppLocalizations.of(context)!.mofNum),
            ),
            DropdownMenuItem<String>(
              value: '',
              child: Text(''),
            ),
            // Add other options as needed
          ],
        ),
      ),
    ],
  );
}


void _applySorting() async {
  switch (selectedSortingOption) {
    case 'GroupCode':
      filteredCustomers.sort((a, b) => a.groupCode!.compareTo(b.groupCode!));
      break;
    case 'Alphabetic':
      filteredCustomers.sort((a, b) => a.custName!.compareTo(b.custName!));
      break;
   case 'GPS':
        // Check if userPosition is not null before calling _sortByGPS
        print(userPosition);
        if (userPosition != null) {
          await _sortByGPS(userPosition!);
        }
        break;
    }

    setState(() {
      // Update the UI with the sorted items
    });
  }


Future<void> _sortByGPS(Position userPosition) async {
  // Create a map to store customer codes and their distances
  Map<String, double> distances = {};

  // Calculate distance for each customer
  for (var customer in filteredCustomers) {
    double distance = await calculateDistance(customer.cmpCode!,customer.dfltAddressID!,customer.custCode!, userPosition);
    distances[customer.custCode!] = distance;
  }

  // Sort customers based on distances
  filteredCustomers.sort((a, b) {
    double distanceToA = distances[a.custCode!]!;
    double distanceToB = distances[b.custCode!]!;
    print(distanceToA);
    print(distanceToB);
    return distanceToA.compareTo(distanceToB);
  });
}


   void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.filtersByCustomers,style: _appTextStyleNormal,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMultiSelectChip(AppLocalizations.of(context)!.groupcode, groupList, selectedGroups, setState),
                  _buildMultiSelectChip(AppLocalizations.of(context)!.cmpCode, cmpCodeList, selectedCmpCode, setState),
                 
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel,style: _appTextStyleNormal,),
                ),
                TextButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.apply,style: _appTextStyleNormal,),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMultiSelectChip(
    String label,
    List<String> options,
    List<String> selectedValues,
    Function(void Function()) setStateCallback,
  ) {
            TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,style: _appTextStyle,),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option,style: _appTextStyle,),
              selected: isSelected,
              onSelected: (bool selected) {
                setStateCallback(() {
                  if (selected) {
                    selectedValues.add(option);
                  } else {
                    selectedValues.remove(option);
                  }
                });
              },
              backgroundColor: isSelected ? Colors.blue : null,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

 void _applyFilters() {
    filteredCustomers = customers.where((customer) {
      var codeMatch = customer.custCode.contains(codeFilterController.text);
      var groupMatch = selectedGroups.isEmpty || selectedGroups.contains(customer.groupCode);
      var cmpCodeMatch = selectedCmpCode.isEmpty || selectedCmpCode.contains(customer.cmpCode);
   

      return codeMatch  && groupMatch && cmpCodeMatch;
    }).toList();

    setState(() {
      // Update the UI with the filtered items
    });
  }

Future<String> scanBarcode() async {
  try {
    ScanResult result = await BarcodeScanner.scan();
    String barcode = result.rawContent;
    return barcode;
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.cameraAccessDenied) {
      // Handle camera permission denied
      print('Camera permission denied');
    } else {
      // Handle other exceptions
      print('Error: $e');
    }
    return '';
  }
}


}

