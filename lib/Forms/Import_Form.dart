import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Synchronize/DataSynchronizerFromFirebaseToHive.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/LoadingHelper.dart';
import 'package:project/classes/TranslationsClass.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/syncronizesubmenu_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:process/process.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ImportForm extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final String title;

  ImportForm({required this.appNotifier, required this.usercode, required this.title});

  @override
  _ImportFormState createState() => _ImportFormState();
}

class _ImportFormState extends State<ImportForm> {
  // Track the selected checkboxes
  



final String serverUrl = 'https://webappapi-8xaa.onrender.com';
final int userGroupCode = 1;
Future<void> importData() async {
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  
  // Create a Map to hold the data you want to send in the body
  Map<String, dynamic> requestBody = {
    'userGroupCode': userGroupCode,
    'itemTable': itemTable,
    'priceListsTable': priceListsTable,
    'selectAllTables': selectAllTables,
    'customersTable': customersTables,
    'systemTables': systemTables,
  };

  final response = await http.post(
    Uri.parse('$serverUrl/importData'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    print('Data migration complete');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data synchronized successfully', style: _appTextStyle),
      ),
    );
  } else {
    print('Failed to import data. Status code: ${response.statusCode}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to import data. Status code: ${response.statusCode}', style: _appTextStyle),
      ),
    );
  }
}





  bool _importItems = false;
  bool _importPriceLists = false;
  bool _importSystem = false;
  bool _importCustomers= false;
  String itemTable='';
  String priceListsTable='';
  String selectAllTables='';
  String customersTables='';
  String systemTables='';

  bool _selectAll = false;
bool _loading = false; // Track loading state
 @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _buildSwitchList().length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return SwitchListTile(
                title: Text('Select All', style: _appTextStyle),
                value: _selectAll,
                onChanged: (value) {
                  setState(() {
                    _selectAll = value ?? false;
                    _importItems = _selectAll;
                    _importPriceLists = _selectAll;
                    _importSystem = _selectAll;
                    _importCustomers=_selectAll;
                    if(_selectAll==true) selectAllTables='selectall'; else selectAllTables='';
                  });
                },
              );
            } else {
              return _buildSwitchList()[index - 1];
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildSwitchList() {
  TextStyle _appTextStyle =
      TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  if (widget.title == 'Import from ERP To Mobile') {
    return [
      SwitchListTile(
        title: Text('System', style: _appTextStyle),
        value: _importSystem,
        onChanged: (value) {
          setState(() {
            _importSystem = value ?? false;
            if(_importSystem==true) systemTables='System'; else systemTables='';
            print(systemTables);
          });
        },
      ),
      SwitchListTile(
        title: Text('Items', style: _appTextStyle),
        value: _importItems,
        onChanged: (value) {
          setState(() {
            _importItems = value ?? false;
            if(_importItems==true) itemTable='Items'; else itemTable='';
            print(itemTable);
          });
        },
      ),
      SwitchListTile(
        title: Text('PriceLists', style: _appTextStyle),
        value: _importPriceLists,
        onChanged: (value) {
          setState(() {
            _importPriceLists = value ?? false;
            if(_importPriceLists==true) priceListsTable='PriceList'; else priceListsTable='';
            print(priceListsTable);
          });
        },
      ),

       SwitchListTile(
        title: Text('Customers', style: _appTextStyle),
        value: _importCustomers,
        onChanged: (value) {
          setState(() {
            _importCustomers = value ?? false;
            if(_importCustomers==true) customersTables='Customers'; else customersTables='';
            print(customersTables);
          });
        },
      ),
      SizedBox(height: 10),
      Center(
          child: Stack(
            children: [
              ElevatedButton(
               onPressed: () async {
  LoadingHelper.configureLoading();
  LoadingHelper.showLoading(); // Show loading indicator
  await importData();
  LoadingHelper.dismissLoading(); // Dismiss loading indicator
},
child: Text('Import', style: _appTextStyle),

              ),
            ],
          ),
        ),
      
    ];
  } else if (widget.title == 'Import from Backend to Mobile') {
    return [
         SwitchListTile(
        title: Text('System', style: _appTextStyle),
        value: _importSystem,
        onChanged: (value) {
          setState(() {
            _importSystem = value ?? false;
          });
        },
      ),
      SwitchListTile(
        title: Text('Items', style: _appTextStyle),
        value: _importItems,
        onChanged: (value) {
          setState(() {
            _importItems = value ?? false;
          });
        },
      ),
      SwitchListTile(
        title: Text('PriceLists', style: _appTextStyle),
        value: _importPriceLists,
        onChanged: (value) {
          setState(() {
            _importPriceLists = value ?? false;
          });
        },
      ),
   
         SwitchListTile(
        title: Text('Customers', style: _appTextStyle),
        value: _importCustomers,
        onChanged: (value) {
          setState(() {
            _importCustomers = value ?? false;
          });
        },
      ),
      SizedBox(height:10),
           Center(
          child: Stack(
            children: [
              ElevatedButton(
                onPressed: () async {
  LoadingHelper.configureLoading();
  LoadingHelper.showLoading(); // Show loading indicator
  await _synchronizeAll();
  LoadingHelper.dismissLoading(); // Dismiss loading indicator
},
child: Text('Import', style: _appTextStyle),

              ),
            ],
          ),
        ),

    ];
  }
  return [];
}

   Future<void> _synchronizeAll() async {

     if(_selectAll){
      await _synchronizeDatatoHive();
    }else{
    // Synchronize all selected options
    if (_importItems) {
      await _synchronizeItems();
    }

    if (_importPriceLists) {
      await _synchronizePriceLists();
    }

    if (_importSystem) {
      await _synchronizeSystem();
    }

    if(_importCustomers){
      await _synchronizeCustomers();
    }

    }
    
  }
 Future<void> _synchronizeItems() async {
    TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
   DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
    await synchronizer.synchronizeData();
    await synchronizer.synchronizeDataItemAttach();
    await synchronizer.synchronizeDataItemBrand();
    await synchronizer.synchronizeDataItemCateg();
    await synchronizer.synchronizeDataItemGroup();
    await synchronizer.synchronizeDataItemPrice();
    await synchronizer.synchronizeDataItemUOM();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Items synchronized successfully',style: _appTextStyle,),
      ),
    );
    print('Items synchronized successfully');
  }

  Future<void> _synchronizePriceLists() async {
      TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
    await synchronizer.synchronizeDataPriceLists();
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PriceLists synchronized successfully',style: _appTextStyle,),
      ),
    );
    print('PriceLists synchronized successfully');
  }

  Future<void> _synchronizeSystem() async {
      TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
     DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
    await synchronizer.synchronizeDataUser();
    await synchronizer.synchronizeDataUserGroup();
    await synchronizer.synchronizeDataUserGroupTranslations();
    await synchronizer.synchronizeDataAuthorization();
    await synchronizer.synchronizeDataMenu();
    await synchronizer.synchronizeDataGeneralSettings();
    await synchronizer.synchronizeCompanies();
    await synchronizer.synchronizeDepartements();
    await synchronizer.synchronizeExchangeRates();
    await synchronizer.synchronizeCurrencies();
     await synchronizer.synchronizeVATGroups();
      await synchronizer.synchronizeCustGroups();

    await synchronizer.synchronizeCustProperties();
    await synchronizer.synchronizeRegions();
    await synchronizer.synchronizeWarehouses();
    await synchronizer.synchronizePaymentTerms();
     await synchronizer.synchronizeSalesEmployees();
      await synchronizer.synchronizeSalesEmployeesCustomers();

          await synchronizer.synchronizeSalesEmployeesDepartements();
    await synchronizer.synchronizeSalesEmployeesItemsBrands();
    await synchronizer.synchronizeSalesEmployeesItemsCategories();
    await synchronizer.synchronizeSalesEmployeesItemsGroups();
     await synchronizer.synchronizeSalesEmployeesItems();

      await synchronizer.synchronizeUserSalesEmployees();
      

        
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('System synchronized successfully',style: _appTextStyle,),
      ),
    );
    print('System synchronized successfully');
  }

 Future<void> _synchronizeCustomers() async {
      TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
     DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
    await synchronizer.synchronizeCustomers();
    await synchronizer.synchronizeCustomerAddresses();
    await synchronizer.synchronizeCustomerContacts();
    await synchronizer.synchronizeCustomerProperties();
    await synchronizer.synchronizeCustomerAttachments();
    await synchronizer.synchronizeCustomerItemsSpecialPrice();
    await synchronizer.synchronizeCustomerBrandsSpecialPrice();
    await synchronizer.synchronizeCustomerGroupsSpecialPrice();
    await synchronizer.synchronizeCustomerCategSpecialPrice();
    await synchronizer.synchronizeCustomerGroupItemsSpecialPrice();
    await synchronizer.synchronizeCustomerGroupBrandSpecialPrice();
    await synchronizer.synchronizeCustomerGroupGroupSpecialPrice();

    await synchronizer.synchronizeCustomerGroupCategSpecialPrice();
    await synchronizer.synchronizeCustomerPropItemsSpecialPrice();
    await synchronizer.synchronizeCustomerPropBrandSpecialPrice();
    await synchronizer.synchronizeCustomerPropGroupSpecialPrice();
     await synchronizer.synchronizeCustomerPropCategSpecialPrice();


      
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Customers synchronized successfully',style: _appTextStyle,),
      ),
    );
    print('Customers synchronized successfully');
  }

Future<void> _synchronizeDatatoHive() async {
    TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  try {
    // Set loading state to true before starting synchronization
    setState(() {
      _loading = true;
    });

    // Your existing synchronization logic
    DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();

    // Run the synchronization process
    await synchronizer.synchronizeData();
    await synchronizer.synchronizeDataPriceLists();
    await synchronizer.synchronizeDataItemPrice();
    await synchronizer.synchronizeDataItemAttach();
    await synchronizer.synchronizeDataItemBrand();
    await synchronizer.synchronizeDataItemCateg();
    await synchronizer.synchronizeDataItemUOM();
    await synchronizer.synchronizeDataItemGroup();
    await synchronizer.synchronizeDataUserPL();
    await synchronizer.synchronizeDataUser();
    await synchronizer.synchronizeDataMenu();
    await synchronizer.synchronizeDataAuthorization();
    await synchronizer.synchronizeDataUserGroup();
    await synchronizer.synchronizeDataUserGroupTranslations();

      await synchronizer.synchronizeDataGeneralSettings();
    await synchronizer.synchronizeDepartements();
    await synchronizer.synchronizeExchangeRates();
    await synchronizer.synchronizeCurrencies();
     await synchronizer.synchronizeVATGroups();
      await synchronizer.synchronizeCustGroups();

    await synchronizer.synchronizeCustProperties();
    await synchronizer.synchronizeRegions();
    await synchronizer.synchronizeWarehouses();
    await synchronizer.synchronizePaymentTerms();
     await synchronizer.synchronizeSalesEmployees();
      await synchronizer.synchronizeSalesEmployeesCustomers();

          await synchronizer.synchronizeSalesEmployeesDepartements();
    await synchronizer.synchronizeSalesEmployeesItemsBrands();
    await synchronizer.synchronizeSalesEmployeesItemsCategories();
    await synchronizer.synchronizeSalesEmployeesItemsGroups();
     await synchronizer.synchronizeSalesEmployeesItems();

      await synchronizer.synchronizeUserSalesEmployees();

await _synchronizeCustomers();
    // Simulate a delay for demonstration purposes (remove in production)
    await Future.delayed(Duration(seconds: 3));

    // Display a success message or update UI as needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data synchronized successfully',style: _appTextStyle,),
      ),
    );
  } catch (e) {
    // Handle errors and display an error message or update UI accordingly
    print('Error synchronizing data: $e');
  } finally {
    // Set loading state to false after synchronization
    setState(() {
      _loading = false;
    });
  }
}

// Add this function to show a loading indicator using FutureBuilder
Widget _buildLoadingIndicator() {
  if (_loading) {
    EasyLoading.show(status: 'Loading...');
  } else {
    EasyLoading.dismiss();
  }

  return Container();
}

}