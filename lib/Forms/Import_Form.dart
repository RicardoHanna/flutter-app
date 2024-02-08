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
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
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
  String companyCode='';
  String connectionID='';

@override
void initState() {
  super.initState();
  waitingGetCmpCode();

}

Future <void> waitingGetCmpCode() async{
await getCompaniesConnectionId(widget.usercode);
print(connectionID);
}
  



Future<String?> getCompaniesConnectionId(String usercode) async {
  try {
    var companiesUsersBox = await Hive.openBox<CompaniesUsers>('companiesUsersBox');

    // Look for a translation with the specified usercode
    var companyUser = companiesUsersBox.values.firstWhere(
      (t) => t.userCode == usercode,
      orElse: () => CompaniesUsers(userCode: '', cmpCode: '',defaultcmpCode: ''), // Default translation when not found
    );



    if (companyUser.cmpCode.isNotEmpty) {
      // If cmpCode is not empty, open the companies box and retrieve connectionID
      var companiesBox = await Hive.openBox<Companies>('companiesBox');

      // Look for a company with the specified cmpCode
      var company = companiesBox.values.firstWhere(
        (c) => c.cmpCode == companyUser.defaultcmpCode,
        orElse: () => Companies(cmpCode: '', cmpFName: '', tel: '', mobile: '', fAddress: '', mainCurCode: '', prFooter: '', prFFooter: '', prHeader: '', notes: '', cmpName: '', address: '', prFHeader: '', secCurCode: '', rateType: '', issueBatchMethod: '', systemAdminID: ''), // Default company when not found
      );

   

      // Retrieve the connectionID from the company
      return connectionID=company.systemAdminID;
    } else {
      return null;
    }
  } catch (e) {
    print('Error retrieving connectionID: $e');
    return null; // or throw an exception if appropriate
  }
}


final String serverUrl = 'https://hicd.onrender.com';

Future<void> importData() async {
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  
  // Create a Map to hold the data you want to send in the body
  Map<String, dynamic> requestBody = {
    'connectionID': connectionID,
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
  TextStyle _appTextStyle =
      TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Column(
      children: [
        Expanded(
          child: Padding(
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
                        _importCustomers = _selectAll;
                        if (_selectAll == true)
                          selectAllTables = 'selectall';
                        else
                          selectAllTables = '';
                      });
                    },
                  );
                } else {
                  return _buildSwitchList()[index - 1];
                }
              },
            ),
          ),
        ),
        SizedBox(height: 10),
        Column(

            children: [
              _buildImportButton(),
            ],
          ),
        
      ],
    ),
  );
}

Widget _buildImportButton() {
  TextStyle _appTextStyle =
      TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  if (widget.title == AppLocalizations.of(context)!.importFromErpToMobile) {
    return ElevatedButton(
      onPressed: () async {
        LoadingHelper.configureLoading();
        LoadingHelper.showLoading(); // Show loading indicator
        await importData();
        LoadingHelper.dismissLoading(); // Dismiss loading indicator
      },
       style: ButtonStyle(
       fixedSize: MaterialStateProperty.all(Size(280, 10)), // Set the width and height
  ),
      child: Text(AppLocalizations.of(context)!.import, style: _appTextStyle),
    );
  } else if (widget.title == AppLocalizations.of(context)!.importFromBackendToMobile) {
    return ElevatedButton(
      onPressed: () async {
        LoadingHelper.configureLoading();
        LoadingHelper.showLoading(); // Show loading indicator
        await _synchronizeAll();
        LoadingHelper.dismissLoading(); // Dismiss loading indicator
      },
      style: ButtonStyle(
    fixedSize: MaterialStateProperty.all(Size(280, 10)), // Set the width and height
  ),
      child: Text(AppLocalizations.of(context)!.import, style: _appTextStyle),
    );
  } else {
    return Container(); // Placeholder for other scenarios
  }
}
  List<Widget> _buildSwitchList() {
  TextStyle _appTextStyle =
      TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  if (widget.title == AppLocalizations.of(context)!.importFromErpToMobile) {
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
       SizedBox(height:200),
      Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
               onPressed: () async {
  LoadingHelper.configureLoading();
  LoadingHelper.showLoading(); // Show loading indicator
  await importData();
  LoadingHelper.dismissLoading(); // Dismiss loading indicator
},
child: Text(AppLocalizations.of(context)!.import, style: _appTextStyle),

              ),
            ],
          
        ),
      
    ];
  } else if (widget.title == AppLocalizations.of(context)!.importFromBackendToMobile) {
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
      SizedBox(height:200),
         Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () async {
  LoadingHelper.configureLoading();
  LoadingHelper.showLoading(); // Show loading indicator
  await _synchronizeAll();
  LoadingHelper.dismissLoading(); // Dismiss loading indicator
},
child: Text(AppLocalizations.of(context)!.import, style: _appTextStyle),

              ),
            ],
          
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
  TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
  
  // Step 1: Retrieve seCodes based on widget.usercode from UserSalesEmployees
  List<String> seCodes = await synchronizer.retrieveSeCodes(widget.usercode);
  
  // Step 2: Retrieve itemCodes based on seCodes from SalesEmployeesItems
  List<String> itemCodes = await synchronizer.retrieveItemCodes(seCodes);
   List<String> brandCode = await synchronizer.retrieveItemBrand(seCodes);
    List<String> categCode = await synchronizer.retrieveItemCateg(seCodes);
     List<String> groupCode = await synchronizer.retrieveItemGroupCodes(seCodes);
   List<String> priceListsCodes = await synchronizer.retrievePriceList(itemCodes);

  
  // Step 3: Synchronize items based on the retrieved itemCodes
  await synchronizer.synchronizeData(itemCodes);
    await synchronizer.synchronizeDataItemPrice(itemCodes);
    
  /*await synchronizer.synchronizeDataItemAttach(itemCodes);
    await synchronizer.synchronizeDataItemBrand(brandCode);
    await synchronizer.synchronizeDataItemCateg(categCode);
    await synchronizer.synchronizeDataItemGroup(groupCode);
  
    await synchronizer.synchronizeDataItemUOM(itemCodes);*/
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context)!.itemssynchronizedsuccessfully, style: _appTextStyle,),
    ),
  );
  print('Items synchronized successfully');
}


  Future<void> _synchronizePriceLists() async {
      TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
      List<String> seCodes = await synchronizer.retrieveSeCodes(widget.usercode);
  
  // Step 2: Retrieve itemCodes based on seCodes from SalesEmployeesItems
  List<String> itemCodes = await synchronizer.retrieveItemCodes(seCodes);
  print(itemCodes.toList());
    List<String> priceListsCodes = await synchronizer.retrievePriceList(itemCodes);
    print(priceListsCodes.toList());
    await synchronizer.synchronizeDataPriceLists(priceListsCodes);
          await synchronizer.synchronizeDataPriceListsAutho();
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.pricelistsynchronizedsuccessfully,style: _appTextStyle,),
      ),
    );
    print('PriceLists synchronized successfully');
  }

  Future<void> _synchronizeSystem() async {
      TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
     DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
      List<String> seCodes = await synchronizer.retrieveSeCodes(widget.usercode);
  
  // Step 2: Retrieve itemCodes based on seCodes from SalesEmployeesItems
  List<String> itemCodes = await synchronizer.retrieveItemCodes(seCodes);
   List<String> brandCode = await synchronizer.retrieveItemBrand(seCodes);
    List<String> categCode = await synchronizer.retrieveItemCateg(seCodes);
     List<String> groupCode = await synchronizer.retrieveItemGroupCodes(seCodes);
  
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
     await synchronizer.synchronizeSalesEmployees(seCodes);
      await synchronizer.synchronizeSalesEmployeesCustomers(seCodes);

          await synchronizer.synchronizeSalesEmployeesDepartements(seCodes);
    await synchronizer.synchronizeSalesEmployeesItemsBrands(seCodes);
    await synchronizer.synchronizeSalesEmployeesItemsCategories(seCodes);
    await synchronizer.synchronizeSalesEmployeesItemsGroups(seCodes);
     await synchronizer.synchronizeSalesEmployeesItems(seCodes);

      await synchronizer.synchronizeUserSalesEmployees();


      await synchronizer.synchronizeDataCompaniesConnection();
      await synchronizer.synchronizeDataCompaniesUsers();
      

        
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.systemsynchronizedsuccessfully,style: _appTextStyle,),
      ),
    );
    print('System synchronized successfully');
  }

 Future<void> _synchronizeCustomers() async {
      TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
     DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
         List<String> seCodes = await synchronizer.retrieveSeCodes(widget.usercode);
  
  // Step 2: Retrieve itemCodes based on seCodes from SalesEmployeesItems
  List<String> itemCodes = await synchronizer.retrieveItemCodes(seCodes);
   List<String> brandCode = await synchronizer.retrieveItemBrand(seCodes);
    List<String> categCode = await synchronizer.retrieveItemCateg(seCodes);
     List<String> groupCode = await synchronizer.retrieveItemGroupCodes(seCodes);
      List<String> custCode = await synchronizer.retrieveCustCodes(seCodes);
 List<String> itemCode = await synchronizer.retrieveItemCodes(seCodes);
  List<String> custGroupCodes = await synchronizer.retrieveItemCodes(custCode);

  
    await synchronizer.synchronizeCustomers(custCode);
    await synchronizer.synchronizeCustomerAddresses(custCode);
    await synchronizer.synchronizeCustomerContacts(custCode);
    await synchronizer.synchronizeCustomerProperties(custCode);
    await synchronizer.synchronizeCustomerAttachments(custCode);

    await synchronizer.synchronizeCustomerItemsSpecialPrice(custCode,itemCode);
    await synchronizer.synchronizeCustomerBrandsSpecialPrice(custCode,brandCode);
    await synchronizer.synchronizeCustomerGroupsSpecialPrice(custCode,groupCode);
    await synchronizer.synchronizeCustomerCategSpecialPrice(custCode,categCode);

    await synchronizer.synchronizeCustomerGroupItemsSpecialPrice(itemCode,custGroupCodes);
    await synchronizer.synchronizeCustomerGroupBrandSpecialPrice(brandCode,custGroupCodes);
    await synchronizer.synchronizeCustomerGroupGroupSpecialPrice(groupCode,custGroupCodes);
    await synchronizer.synchronizeCustomerGroupCategSpecialPrice(categCode,custGroupCodes);

    await synchronizer.synchronizeCustomerPropItemsSpecialPrice(itemCode,custCode);
    await synchronizer.synchronizeCustomerPropBrandSpecialPrice(brandCode,custCode);
    await synchronizer.synchronizeCustomerPropGroupSpecialPrice(custGroupCodes,custCode);
     await synchronizer.synchronizeCustomerPropCategSpecialPrice(categCode,custCode);


      
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.customerssynchronizedsuccessfully,style: _appTextStyle,),
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
  await _synchronizeSystem();
  await _synchronizeItems();
  await _synchronizePriceLists();

await _synchronizeCustomers();
    // Simulate a delay for demonstration purposes (remove in production)
    await Future.delayed(Duration(seconds: 3));

    // Display a success message or update UI as needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.dataissynchronized,style: _appTextStyle,),
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