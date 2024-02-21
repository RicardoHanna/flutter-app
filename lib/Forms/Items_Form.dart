import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Catalog_Form.dart';
import 'package:project/Forms/Items_Info_Form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/DataSearch.dart';
import 'package:project/classes/UserPreferences.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemuom_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
import 'package:project/hive/salesemployeesitems_hive.dart';
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


class ItemsForm extends StatefulWidget {
 
  final AppNotifier appNotifier;
  final String userCode;
  final String defltCompanyCode;
  ItemsForm({required this.appNotifier,required this.userCode,required this.defltCompanyCode});
  @override
  State<ItemsForm> createState() => _itemsFormState();
}

class _itemsFormState extends State<ItemsForm> {
  UserPreferences userPreferences = UserPreferences();

 String? itemCode;
 String? itemName;
 bool? active;
 late List<Items> items;
  late List<Items> filteredItems=[];
late List<String> groupList = [];
  late List<String> brandList = [];
  late List<String> categoryList = [];
  late List<String> selectedGroups = [];
  late List<String> selectedBrands = [];
  late List<String> selectedCategories = [];
   late String selectedSortingOption = 'Alphabetic';
  late Box<Items> itemBox;
final TextEditingController codeFilterController = TextEditingController();
  final TextEditingController groupFilterController = TextEditingController();
  final TextEditingController brandFilterController = TextEditingController();
  final TextEditingController itemNameFilterController = TextEditingController();
  final TextEditingController categoryFilterController = TextEditingController();
 TextEditingController searchController = TextEditingController();
    TextStyle   _appTextStyleNormal = TextStyle();
  @override
@override
void initState() {
  super.initState();
  // Call async method within initState
  itemBox = Hive.box<Items>('items');
  initializeData();
  loadCheckboxPreferences();
  printUserDataTranslations();
}

Future<void> loadCheckboxPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  setState(() {
    userPreferences.showActive = prefs.getBool('showActive') ?? false;
    userPreferences.showWeight = prefs.getBool('showWeight') ?? false;
    userPreferences.showItemType = prefs.getBool('showItemType') ?? false;
   // userPreferences.showItemName = prefs.getBool('showItemName') ?? false;
    userPreferences.showGroupCode = prefs.getBool('showGroupCode') ?? false;
  });
}


 Future<void> initializeData() async {
    items = await _getItems();
    filteredItems = List.from(items);

    groupList = await getDistinctValuesFromBox('groupCode', itemBox);
    brandList = await getDistinctValuesFromBox('brandCode', itemBox);
    categoryList = await getDistinctValuesFromBox('categCode', itemBox);
  }

  Future<List<String>> getDistinctValuesFromBox(String fieldName, Box<Items> box) async {
    var distinctValues = <String>[];
    var distinctSet = <String>{};

    for (var item in box.values) {
      var value = getField(item, fieldName);
      if (value != null && distinctSet.add(value)) {
        distinctValues.add(value);
      }
    }

    return distinctValues;
  }
dynamic getField(Items item, String fieldName) {
    switch (fieldName) {
      case 'groupCode':
        return item.groupCode;
      case 'brandCode':
        return item.brandCode;
      case 'categCode':
        return item.categCode;
      // Add cases for other fields as needed
      default:
        return null;
    }
  }

  


Future<void> printUserDataTranslations() async {
 var itemsBox = await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');

    print('Printing Users:');
    for (var item in itemsBox.values) {
      print('Username: ${item.cmpCode}');
      print('Email: ${item.userCode}');
      print('Email: ${item.authoGroup}');
      print('-------------------------');
    }
  // Open 'translationsBox' for Translations

  print('Printed all data');


}
Future<List<Items>> _getItems() async {
  var usersSalesEmployeesBox = await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');
  var salesEmployeesItemsBox = await Hive.openBox<SalesEmployeesItems>('salesEmployeesItemsBox');
  var itemsBox = await Hive.openBox<Items>('items');
 List<Items> allItems = [];
  /*try {
    // Find the UserSalesEmployees objects with matching userCode
    var userSalesEmployees = usersSalesEmployeesBox.values.where((userSalesEmployee) => userSalesEmployee.userCode == widget.userCode && userSalesEmployee.cmpCode == widget.defltCompanyCode);

    List<Items> allItems = [];

    // Iterate through each userSalesEmployee object
    for (var userSalesEmployee in userSalesEmployees) {
      var cmpCode = userSalesEmployee.cmpCode;
      var seCode = userSalesEmployee.seCode;

      // Find all SalesEmployeesItems with matching cmpCode and seCode
      var salesEmployeeItems = salesEmployeesItemsBox.values.where((salesEmployeeItem) => 
        salesEmployeeItem.cmpCode == cmpCode && salesEmployeeItem.seCode == seCode);

      // Iterate through each SalesEmployeesItem for the current userSalesEmployee
      for (var salesEmployeeItem in salesEmployeeItems) {
        var itemCode = salesEmployeeItem.itemCode;

        // Retrieve items from the items box based on itemCode and cmpCode
        var items = itemsBox.values.where((item) => item.cmpCode == cmpCode && item.itemCode == itemCode).toList();
        
        // Add the retrieved items to the list
        allItems.addAll(items);
      }
    }
*/
allItems=itemsBox.values.toList();

    return allItems;
 /* } catch (e) {
    print("Error: $e");

    // Close the boxes if an error occurs
    

    return []; // Return an empty list if an error occurs
  }*/
}




  @override
  Widget build(BuildContext context) {
      TextStyle   _appTextStyleLead = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
           TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-6);
_appTextStyleNormal= TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.items,style: _appTextStyleLead,),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(itemsList: items,appNotifier: widget.appNotifier));
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
                value: 'Brand',
                child: Text(AppLocalizations.of(context)!.sortbybrand,style: _appTextStyleLead,),
              ),
              PopupMenuItem<String>(
                value: 'ItemGroup',
                child: Text(AppLocalizations.of(context)!.sortbyitemgroup,style: _appTextStyleLead,),
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
                var scannedItem = items.firstWhere((item) => item.barCode == barcode, orElse: null);
                if (scannedItem != null) {
                  // Show item details for the scanned item
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemsInfoForm(item: scannedItem,appNotifier: widget.appNotifier,),
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
        child: FutureBuilder<List<Items>>(
  future: _getItems(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('No data found');
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('No items found');
    } else {
      return ListView.builder(
        itemCount: filteredItems.length, // Use filteredItems.length
        itemBuilder: (context, index) {
          var item = filteredItems[index]; // Use filteredItems[index] instead of snapshot.data![index]
          return Card(
            child: ListTile(
              leading: Text(item.itemCode ?? '',style: _appTextStyleLead,),
                    subtitle: buildTrailingWidget(item),
    title:Text(item.itemName ?? '',style:_appTextStyle,),
              

              onTap: () {
                // Navigate to the ItemsInfoForm page and pass the selected item
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsInfoForm(item: item,appNotifier: widget.appNotifier,),
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

  
Widget _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22),
      backgroundColor: Color(0xFF2196F3),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.image),
          backgroundColor: Color(0xFF2196F3),
          onTap: () {
          _showCatalogItems();
          },
          label: 'Items Catalog',
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
          label:'Add Fields Items',
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

void _showCatalogItems(){
    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CatalogForm(appNotifier:widget.appNotifier, usercode: widget.userCode, items: filteredItems,),
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
 Widget buildTrailingWidget(Items item) {
               TextStyle   _appTextStylewidgets = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble()-7);
  List<Widget> widgets = [];
  List<String> selectedFields = userPreferences.getSelectedFields();

  for (var field in selectedFields) {
    switch (field) {
      case 'Weight':
        widgets.add(Text(item.weight.toString(),style: _appTextStylewidgets,));
        break;
      case 'ItemType':
        widgets.add(Text(item.itemType ?? '',style: _appTextStylewidgets,),);
        break;
  /*    case 'ItemName':
        widgets.add(Text(item.itemName ?? '',style: _appTextStylewidgets,));
        break;*/
      case 'GroupCode':
        widgets.add(Text(item.groupCode ?? '',style: _appTextStylewidgets,));
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
    userPreferences.showActive ? 'Active' : null,
    userPreferences.showWeight ? 'Weight' : null,
    userPreferences.showItemType ? 'ItemType' : null,
    //userPreferences.showItemName ? 'ItemName' : null,
    userPreferences.showGroupCode ? 'GroupCode' : null,
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
                  userPreferences.showActive = selectedOptions.contains('Active');
                  userPreferences.showWeight = selectedOptions.contains('Weight');
                  userPreferences.showItemType = selectedOptions.contains('ItemType');
                 // userPreferences.showItemName = selectedOptions.contains('ItemName');
                  userPreferences.showGroupCode = selectedOptions.contains('GroupCode');

                  // Save dropdown preferences to shared preferences
                  await prefs.setBool('showActive', userPreferences.showActive);
                  await prefs.setBool('showWeight', userPreferences.showWeight);
                  await prefs.setBool('showItemType', userPreferences.showItemType);
               //   await prefs.setBool('showItemName', userPreferences.showItemName);
                  await prefs.setBool('showGroupCode', userPreferences.showGroupCode);

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
            value: 'Weight',
            child: Text(AppLocalizations.of(context)!.weight),
          ),
          DropdownMenuItem<String>(
            value: 'ItemType',
            child: Text(AppLocalizations.of(context)!.itemtype),
          ),
          /*  DropdownMenuItem<String>(
            value: 'ItemName',
            child: Text(AppLocalizations.of(context)!.itemname),
          ),*/
           DropdownMenuItem<String>(
            value: 'GroupCode',
            child: Text(AppLocalizations.of(context)!.groupcode),
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
      case 'Brand':
        filteredItems.sort((a, b) => a.brandCode!.compareTo(b.brandCode!));
        break;
      case 'ItemGroup':
        filteredItems.sort((a, b) => a.groupCode!.compareTo(b.groupCode!));
        break;
      case 'Alphabetic':
        filteredItems.sort((a, b) => a.itemName!.compareTo(b.itemName!));
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
            title: Text(
              AppLocalizations.of(context)!.filteritems,
              style: _appTextStyleNormal,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMultiSelectChip(
                    AppLocalizations.of(context)!.groupcode,
                    groupList,
                    selectedGroups,
                    setState,
                  ),
                  _buildMultiSelectChip(
                    AppLocalizations.of(context)!.brand,
                    brandList,
                    selectedBrands,
                    setState,
                  ),
                  _buildMultiSelectChip(
                    AppLocalizations.of(context)!.categcode,
                    categoryList,
                    selectedCategories,
                    setState,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: _appTextStyleNormal,
                ),
              ),
              TextButton(
                onPressed: () {
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.apply,
                  style: _appTextStyleNormal,
                ),
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
    filteredItems = items.where((item) {
      var codeMatch = item.itemCode.contains(codeFilterController.text);
      var itemNameMatch = item.itemName.contains(itemNameFilterController.text);
      var groupMatch = selectedGroups.isEmpty || selectedGroups.contains(item.groupCode);
      var brandMatch = selectedBrands.isEmpty || selectedBrands.contains(item.brandCode);
      var categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(item.categCode);

      return codeMatch && itemNameMatch && groupMatch && brandMatch && categoryMatch;
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

