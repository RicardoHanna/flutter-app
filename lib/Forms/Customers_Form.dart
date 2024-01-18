import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Customers_Info_Form.dart';
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/DataSearch.dart';
import 'package:project/classes/DataSearchCustomers.dart';
import 'package:project/classes/UserPreferences.dart';
import 'package:project/hive/customeraddresses_hive.dart';
import 'package:project/hive/customerbrandsspecialprice_hive.dart';
import 'package:project/hive/customercontacts_hive.dart';
import 'package:project/hive/customergroupitemsspecialprice_hive.dart';
import 'package:project/hive/customergroupsspecialprice_hive.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/translations_hive.dart';
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


class CustomersForm extends StatefulWidget {
 
  final AppNotifier appNotifier;
  CustomersForm({required this.appNotifier});
  @override
  State<CustomersForm> createState() => _customersFormState();
}

class _customersFormState extends State<CustomersForm> {
  UserPreferences userPreferences = UserPreferences();


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
  @override
@override
void initState() {
  super.initState();
  // Call async method within initState
  customerBox = Hive.box<Customers>('customersBox');
  initializeData();
  loadCheckboxPreferences();
  printUserDataTranslations();
}

Future<void> loadCheckboxPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  setState(() {
    userPreferences.showActiveCustomers = prefs.getBool('showActive') ?? false;
    userPreferences.showCurCodeCustomers = prefs.getBool('showCurCode') ?? false;
    userPreferences.showDiscTypeCustomers = prefs.getBool('showItemType') ?? false;
   // userPreferences.showItemName = prefs.getBool('showItemName') ?? false;
    userPreferences.showMOFNumCustomers = prefs.getBool('showMOFNum') ?? false;
  });
}


 Future<void> initializeData() async {
    customers = await _getCustomers();
    filteredCustomers = List.from(customers);

    groupList = await getDistinctValuesFromBox('groupCode', customerBox);
   cmpList = await getDistinctValuesFromBox('cmpCode', customerBox);
   cmpCodeList= await getDistinctValuesFromBox('cmpCode', customerBox);
   
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

  


Future<void> printUserDataTranslations() async {
 var custBox = await Hive.openBox<CustomerGroupItemsSpecialPrice>('customerGroupItemsSpecialPriceBox');

    print('Printinggg Users:');
    for (var cust in custBox.values) {
      print('CmpCode: ${cust.cmpCode}');
      print('Name: ${cust.disc}');

      print('-------------------------');
    }
  // Open 'translationsBox' for Translations

  print('Printed all data');


}

Future<List<Customers>> _getCustomers() async {
  // Retrieve changes from the local database
  var customersBox = await Hive.openBox<Customers>('customersBox');
  
  // Assuming 'Items' class has properties itemCode, itemName, and active
  var allCustomers = customersBox.values.toList();
  
  for (var customer in allCustomers) {
    // Access properties of each item
    var cmpCode = customer.cmpCode;
    var custName = customer.custCode;
    var custCode = customer.custCode;

    // Now you can use itemCode, itemName, and active as needed
    print('Cust Code: $custCode, Cust Name: $custName, CmpCode: $cmpCode');
    
    // Perform your synchronization with Firestore or any other logic here
  }

  // Close the box when done
  return allCustomers;
  
}


  @override
  Widget build(BuildContext context) {
      TextStyle   _appTextStyleLead = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-2);
           TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-6);
_appTextStyleNormal= TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.items,style: _appTextStyleLead,),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearchCustomers(customersList: customers,appNotifier: widget.appNotifier));
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
                child: Text('Sort By Group Code',style: _appTextStyleLead,),
              ),
              PopupMenuItem<String>(
                value: 'Alphabetic',
                child: Text(AppLocalizations.of(context)!.sortalphabetic,style: _appTextStyleLead,),
              ),
            ],
          ),
      
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          // Add the barcode scan icon here
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: () async {
              String barcode = await scanBarcode();
              if (barcode.isNotEmpty) {
                // Perform logic to check if the scanned barcode exists in the items
                // and display the corresponding item details.
                // You can use a method similar to how you display items in the list.
                // For example:
                var scannedCust = customers.firstWhere((customer) => customer.barcode == barcode, orElse: null);
                if (scannedCust != null) {
                  // Show item details for the scanned item
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomersInfoForm(customer: scannedCust,appNotifier: widget.appNotifier,),
                    ),
                  );
                } else {
                  // Display a message indicating that the scanned item was not found
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Scanned item not found'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
  body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Customers>>(
  future: _getCustomers(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('No items found');
    } else {
      return ListView.builder(
        itemCount: filteredCustomers.length, // Use filteredItems.length
        itemBuilder: (context, index) {
          var customer = filteredCustomers[index]; // Use filteredItems[index] instead of snapshot.data![index]
          return Card(
            child: ListTile(
              leading: Text(customer.custCode ?? '',style: _appTextStyleLead,),
                    subtitle: buildTrailingWidget(customer),
    title:Text(customer.custName ?? '',style:_appTextStyle,),
              

              onTap: () {
                // Navigate to the ItemsInfoForm page and pass the selected item
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomersInfoForm(customer: customer,appNotifier: widget.appNotifier,),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSettingsDialog();
        },
        child: Icon(Icons.add),
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
Future<void> _showSettingsDialog() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String?> selectedOptions = [
    userPreferences.showActiveCustomers ? 'Active' : null,
    userPreferences.showCurCodeCustomers ? 'CurCode' : null,
  userPreferences.showDiscTypeCustomers ? 'DiscType' : null,

    userPreferences.showMOFNumCustomers ? 'MOFNum' : null,
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
                child: Text(AppLocalizations.of(context)!.save,style: _appTextStyleNormal,),
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
      Text(label),
      SizedBox(width: 10),
      DropdownButton<String>(
        value: selectedValue,
        onChanged: onChanged,
        items: [
          DropdownMenuItem<String>(
            value: 'Active',
            child: Text(AppLocalizations.of(context)!.active),
          ),
          DropdownMenuItem<String>(
            value: 'CurCode',
            child: Text('CurCode'),
          ),
          DropdownMenuItem<String>(
            value: 'DiscType',
            child: Text('DiscType'),
          ),
          /*  DropdownMenuItem<String>(
            value: 'ItemName',
            child: Text(AppLocalizations.of(context)!.itemname),
          ),*/
           DropdownMenuItem<String>(
            value: 'MOFNum',
            child: Text('MofNum'),
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


   void _applySorting() {
    switch (selectedSortingOption) {
      case 'GroupCode':
        filteredCustomers.sort((a, b) => a.groupCode!.compareTo(b.groupCode!));
        break;
      case 'Alphabetic':
        filteredCustomers.sort((a, b) => a.custName!.compareTo(b.custName!));
        break;
    }

    setState(() {
      // Update the UI with the sorted items
    });
  }

   void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Customers',style: _appTextStyleNormal,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMultiSelectChip(AppLocalizations.of(context)!.groupcode, groupList, selectedGroups, setState),
                  _buildMultiSelectChip('Disc Type', cmpCodeList, selectedCmpCode, setState),
                 
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
      var cmpCodeMatch = selectedCmpCode.isEmpty || selectedCmpCode.contains(customer.discType);
   

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

