import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
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

  ImportForm(
      {required this.appNotifier, required this.usercode, required this.title});

  @override
  _ImportFormState createState() => _ImportFormState();
}

class _ImportFormState extends State<ImportForm> {
  // Track the selected checkboxes
  String companyCode = '';
  String connectionID = '';
  List<Map<String, dynamic>> companies = [];
  TimeOfDay noTime = TimeOfDay(hour: 0, minute: 0);
  String baseUrl = 'http://5.189.188.139:8080/api';
  String selectedCompany = "";
  Map<int, bool> checkedCompanies = {};
  @override
  void initState() {
    waitinggetCompanies();
    super.initState();
    waitingGetCmpCode();
    print(isThereData());
  }

  Future<void> waitinggetCompanies() async {
    List<Map<String, dynamic>> cmps = await getCompanies();

    setState(() {
      this.companies = cmps;
      Map<int, bool> cCompanies = Map.fromIterable(
        companies,
        key: (item) => companies.indexOf(item),
        value: (item) => false,
      );
    this.checkedCompanies = cCompanies;
    print(cCompanies);
    });
    print(companies);
    print(checkedCompanies);
  }

  Future<void> waitingGetCmpCode() async {
    await getCompaniesConnectionId(widget.usercode);
    print(connectionID);
  }

  Future<String?> getCompaniesConnectionId(String usercode) async {
    try {
      var companiesUsersBox =
          await Hive.openBox<CompaniesUsers>('companiesUsersBox');

      // Look for a translation with the specified usercode
      var companyUser = companiesUsersBox.values.firstWhere(
        (t) => t.userCode == usercode,
        orElse: () => CompaniesUsers(
            userCode: '',
            cmpCode: '',
            defaultcmpCode: ''), // Default translation when not found
      );

      if (companyUser.cmpCode.isNotEmpty) {
        // If cmpCode is not empty, open the companies box and retrieve connectionID
        var companiesBox = await Hive.openBox<Companies>('companiesBox');

        // Look for a company with the specified cmpCode
        var company = companiesBox.values.firstWhere(
          (c) => c.cmpCode == companyUser.cmpCode,
          orElse: () => Companies(
              cmpCode: '',
              cmpFName: '',
              tel: '',
              mobile: '',
              fAddress: '',
              mainCurCode: '',
              prFooter: '',
              prFFooter: '',
              prHeader: '',
              notes: '',
              cmpName: '',
              address: '',
              prFHeader: '',
              secCurCode: '',
              rateType: '',
              issueBatchMethod: '',
              systemAdminID: '',
              priceDec: null,
              amntDec: null,
              qtyDec: null,
              roundMethod: '',
              importMethod: '',
              time: noTime), // Default company when not found
        );

        // Retrieve the connectionID from the company
        return connectionID = company.systemAdminID;
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
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());

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
          content: Text(
              'Failed to import data. Status code: ${response.statusCode}',
              style: _appTextStyle),
        ),
      );
    }
  }

  Future<void> importSystemFromERP(String cmpCode, String connectionID) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());

    // defaul cmpcode from cmpuser
    // system admin id companies
    // configuration companiesconnection

    // await getCompaniesConnectionId(widget.usercode);
    // print(companyCode);
    // String cmpCode = 'AlBina_Qatar';
    // String connectionID = '1708605295476_901';

    try {
      final response = await http.post(
          Uri.parse('$baseUrl/ImportSystemDataFromERP'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'connectionID': connectionID, 'cmpCode': cmpCode}));

      if (response.statusCode == 200) {
        print('Data migration complete');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('System synchronized successfully for ${cmpCode}', style: _appTextStyle),
          ),
        );
      } else {
        print('Failed to import data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to import data. Status code: ${response.statusCode}',
                style: _appTextStyle),
          ),
        );
      }
    } catch (e) {
      print('Error during data import: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during data import: $e', style: _appTextStyle),
        ),
      );
    }
  }

  Future<void> importCustomersData(String cmpCode, String connectionID) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());

    // defaul cmpcode from cmpuser
    // system admin id companies
    // configuration companiesconnection

    // await getCompaniesConnectionId(widget.usercode);
    // print(companyCode);
    // String cmpCode = 'AlBina_Qatar';
    // String connectionID = '1708605295476_901';

    try {
      final response = await http.post(
          Uri.parse('$baseUrl/ImportCustomersDataFromERP'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'connectionID': connectionID, 'cmpCode': cmpCode}));

      if (response.statusCode == 200) {
        print('Data migration complete');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Customers synchronized successfully for ${cmpCode}', style: _appTextStyle),
          ),
        );
      } else {
        print('Failed to import data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to import data. Status code: ${response.statusCode}',
                style: _appTextStyle),
          ),
        );
      }
    } catch (e) {
      print('Error during data import: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during data import: $e', style: _appTextStyle),
        ),
      );
    }
  }

  Future<void> importItemsDataFromERP(
      String cmpCode, String connectionID) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());

    // defaul cmpcode from cmpuser
    // system admin id companies
    // configuration companiesconnection

    // await getCompaniesConnectionId(widget.usercode);
    // print(companyCode);
    // String cmpCode = 'AlBina_Qatar';
    // String connectionID = '1708605295476_901';

    try {
      final response = await http.post(
          Uri.parse('$baseUrl/ImportItemsDataFromERP'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'connectionID': connectionID, 'cmpCode': cmpCode}));

      if (response.statusCode == 200) {
        print('Data migration complete');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Items synchronized successfully for ${cmpCode}', style: _appTextStyle),
          ),
        );
      } else {
        print('Failed to import data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to import data. Status code: ${response.statusCode}',
                style: _appTextStyle),
          ),
        );
      }
    } catch (e) {
      print('Error during data import: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during data import: $e', style: _appTextStyle),
        ),
      );
    }
  }

  Future<void> importPriceListsDataFromErp(
      String cmpCode, String connectionID) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());

    // defaul cmpcode from cmpuser
    // system admin id companies
    // configuration companiesconnection

    // await getCompaniesConnectionId(widget.usercode);
    // print(companyCode);
    // String cmpCode = 'AlBina_Qatar';
    // String connectionID = '1708605295476_901';

    try {
      final response = await http.post(
          Uri.parse('$baseUrl/ImportPriceListDataFromERP'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'connectionID': connectionID, 'cmpCode': cmpCode}));

      if (response.statusCode == 200) {
        print('Data migration complete');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Price Lists synchronized successfully for ${cmpCode}', style: _appTextStyle),
          ),
        );
      } else {
        print('Failed to import data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to import data. Status code: ${response.statusCode}',
                style: _appTextStyle),
          ),
        );
      }
    } catch (e) {
      print('Error during data import: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during data import: $e', style: _appTextStyle),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCompanies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getCompanies'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  bool _importItems = false;
  bool _importPriceLists = false;
  bool _importSystem = false;
  bool _importCustomers = false;

  String itemTable = '';
  String priceListsTable = '';
  String selectAllTables = '';
  String customersTables = '';
  String systemTables = '';

  bool _selectAll = false;
  bool _loading = false; // Track loading state

  bool isThereData() {
    if (_importCustomers == false &&
        _importSystem == false &&
        _importPriceLists == false &&
        _importItems == false) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Companies:'),
                DropdownButton(
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                  iconSize: 24,
                  elevation: 16,
                  isExpanded: true,
                  underline: Container(
                    height: 2,
                    color: Colors.blue,
                  ),
                  items: companies.map((company) {
                    int index = companies.indexOf(company);
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Row(
                        children: [
                          Text(company['cmpName'] ?? ''),
                          StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Checkbox(
                                value: checkedCompanies[index],
                                onChanged: (value) {
                                  setState(() {
                                    print(checkedCompanies);
                                    checkedCompanies[index] = value ?? false;
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {},
                ),
              ],
            ),
          ),
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
  return isThereData()
      ? ElevatedButton(
          onPressed: () async {
            _showLoadingOverlay(context); // Show loading overlay

            try {
              // Your existing synchronization logic goes here
              LoadingHelper.configureLoading();
              LoadingHelper.showLoading(); // Show loading indicator
              print("################################################");
              print(checkedCompanies);
              for (var c in checkedCompanies.keys) {
                if (checkedCompanies[c] == true) {
                  if (_importCustomers) {
                    await importCustomersData(
                      companies[c]['cmpCode'],
                      companies[c]['systemAdminID'],
                    );
                  }
                  if (_importSystem) {
                    await importSystemFromERP(
                      companies[c]['cmpCode'],
                      companies[c]['systemAdminID'],
                    );
                  }
                  if (_importItems) {
                    await importItemsDataFromERP(
                      companies[c]['cmpCode'],
                      companies[c]['systemAdminID'],
                    );
                  }
                  if (_importPriceLists) {
                    await importPriceListsDataFromErp(
                      companies[c]['cmpCode'],
                      companies[c]['systemAdminID'],
                    );
                  }
                  print("######################################################################");
                  print(companies[c]['cmpCode']);
                  print(companies[c]['systemAdminID']);
                }
              }
              print(checkedCompanies);
            } catch (e) {
              // Handle errors and display an error message or update UI accordingly
              print('Error synchronizing data: $e');
            } finally {
              // Hide loading overlay
              _hideLoadingOverlay(context);
              LoadingHelper.dismissLoading(); // Dismiss loading indicator
            }
          },
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(
              Size(280, 10)), // Set the width and height
          ),
          child: Text(
            AppLocalizations.of(context)!.import,
            style: _appTextStyle,
          ),
        )
      : SizedBox(
          width: 0,
          height: 0,
        );
} 
 else if (widget.title ==
        AppLocalizations.of(context)!.importFromBackendToMobile) {
     return isThereData()
    ? ElevatedButton(
        onPressed: () async {
          _showLoadingOverlay(context); // Show loading overlay

          try {
            // Your existing synchronization logic goes here
            LoadingHelper.configureLoading();
            LoadingHelper.showLoading(); // Show loading indicator
            await _synchronizeAll();
            LoadingHelper.dismissLoading(); // Dismiss loading indicator
          } catch (e) {
            // Handle errors and display an error message or update UI accordingly
            print('Error synchronizing data: $e');
          } finally {
            // Hide loading overlay
            _hideLoadingOverlay(context);
          }
        },
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(
              Size(280, 10)), // Set the width and height
        ),
        child: Text(
          AppLocalizations.of(context)!.import,
          style: _appTextStyle,
        ),
      )
    : SizedBox(
        width: 0,
        height: 0,
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
              if (_importSystem == true)
                systemTables = 'System';
              else
                systemTables = '';
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
              if (_importItems == true)
                itemTable = 'Items';
              else
                itemTable = '';
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
              if (_importPriceLists == true)
                priceListsTable = 'PriceList';
              else
                priceListsTable = '';
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
              if (_importCustomers == true)
                customersTables = 'Customers';
              else
                customersTables = '';
              print(customersTables);
            });
          },
        ),
      ];
    } else if (widget.title ==
        AppLocalizations.of(context)!.importFromBackendToMobile) {
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
      ];
    }
    return [];
  }

 Future<void> _synchronizeAll() async {
    for (var c in checkedCompanies.keys) {
      if (checkedCompanies[c] == true) {
        if (_selectAll) {
          await _synchronizeDatatoHive(companies[c]['cmpCode']);
        } else {
          // Synchronize all selected options
          if (_importItems) {
            await _synchronizeItems(companies[c]['cmpCode']);
          }

          if (_importPriceLists) {
            await _synchronizePriceLists(companies[c]['cmpCode']);
          }

          if (_importSystem) {
            await _synchronizeSystem(companies[c]['cmpCode']);
          }

          if (_importCustomers) {
            await _synchronizeCustomers(companies[c]['cmpCode']);
          }
        }
      }
    }
  }


  Future<void> _synchronizeItems(String cmpCode) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    DataSynchronizerFromFirebaseToHive synchronizer =
        DataSynchronizerFromFirebaseToHive();

    // Step 1: Retrieve seCodes based on widget.usercode from UserSalesEmployees
    List<String> seCodes = await synchronizer.retrieveSeCodes(widget.usercode,cmpCode);

    // Step 2: Retrieve itemCodes based on seCodes from SalesEmployeesItems
    List<String> itemCodes =
        await synchronizer.retrieveItemCodes(seCodes, cmpCode);
    List<String> brandCode =
        await synchronizer.retrieveItemBrand(seCodes, cmpCode);
    List<String> categCode =
        await synchronizer.retrieveItemCateg(seCodes, cmpCode);
    List<String> groupCode =
        await synchronizer.retrieveItemGroupCodes(seCodes, cmpCode);

    // Step 3: Synchronize items based on the retrieved itemCodes
    await synchronizer.synchronizeData(itemCodes,cmpCode);
    await synchronizer.synchronizeDataItemAttach(itemCodes,cmpCode);
    await synchronizer.synchronizeDataItemBrand(brandCode,cmpCode);
    await synchronizer.synchronizeDataItemCateg(categCode,cmpCode);
    await synchronizer.synchronizeDataItemGroup(groupCode,cmpCode);
await synchronizer.synchronizeDataItemPrice(itemCodes, cmpCode);
    await synchronizer.synchronizeDataItemUOM(itemCodes,cmpCode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.itemssynchronizedsuccessfully+' for ${cmpCode}',
          style: _appTextStyle,
        ),
      ),
    );
    print('Items synchronized successfully for ${cmpCode}');
  }

  Future<void> _synchronizePriceLists(String cmpCode) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    DataSynchronizerFromFirebaseToHive synchronizer =
        DataSynchronizerFromFirebaseToHive();
    List<String> seCodes = await synchronizer.retrieveSeCodes(widget.usercode,cmpCode);

    // Step 2: Retrieve itemCodes based on seCodes from SalesEmployeesItems
    List<String> itemCodes =
        await synchronizer.retrieveItemCodes(seCodes, cmpCode);
    print(itemCodes.toList());
    List<String> priceListsCodes =
        await synchronizer.retrievePriceList(itemCodes, cmpCode);
    print(priceListsCodes.toList());
    await synchronizer.synchronizeDataPriceLists(priceListsCodes,cmpCode);
    await synchronizer.synchronizeDataPriceListsAutho();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.pricelistsynchronizedsuccessfully+' for ${cmpCode}' ,
          style: _appTextStyle,
        ),
      ),
    );
    print('PriceLists synchronized successfully for ${cmpCode}');
  }

  Future<void> _synchronizeSystem(String cmpCode) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    DataSynchronizerFromFirebaseToHive synchronizer =
        DataSynchronizerFromFirebaseToHive();
    List<String> seCodes = await synchronizer.retrieveSeCodes(widget.usercode,cmpCode);

    // Step 2: Retrieve itemCodes based on seCodes from SalesEmployeesItems
    List<String> itemCodes =
        await synchronizer.retrieveItemCodes(seCodes, cmpCode);
    List<String> brandCode =
        await synchronizer.retrieveItemBrand(seCodes, cmpCode);
    List<String> categCode =
        await synchronizer.retrieveItemCateg(seCodes, cmpCode);
    List<String> groupCode =
        await synchronizer.retrieveItemGroupCodes(seCodes, cmpCode);

    await synchronizer.synchronizeDataUser();
    await synchronizer.synchronizeDataUserGroup();
    await synchronizer.synchronizeDataUserGroupTranslations();
    await synchronizer.synchronizeDataAuthorization();
    await synchronizer.synchronizeDataMenu();
    await synchronizer.synchronizeDataGeneralSettings();
    await synchronizer.synchronizeCompanies();
    await synchronizer.synchronizeDepartments(cmpCode);
    await synchronizer.synchronizeExchangeRates(cmpCode);
    await synchronizer.synchronizeCurrencies(cmpCode);
    await synchronizer.synchronizeVATGroups(cmpCode);
    await synchronizer.synchronizeCustGroups(cmpCode);

    await synchronizer.synchronizeCustProperties(cmpCode);
    await synchronizer.synchronizeRegions(cmpCode);
    await synchronizer.synchronizeWarehouses(cmpCode);
    await synchronizer.synchronizePaymentTerms(cmpCode);
    await synchronizer.synchronizeSalesEmployees(cmpCode);
    await synchronizer.synchronizeSalesEmployeesCustomers(seCodes,cmpCode);

    await synchronizer.synchronizeSalesEmployeesDepartments(seCodes,cmpCode);
    await synchronizer.synchronizeSalesEmployeesItemsBrands(seCodes,cmpCode);
    await synchronizer.synchronizeSalesEmployeesItemsCategories(seCodes,cmpCode);
    await synchronizer.synchronizeSalesEmployeesItemsGroups(seCodes,cmpCode);
    await synchronizer.synchronizeSalesEmployeesItems(seCodes,cmpCode);

    await synchronizer.synchronizeUserSalesEmployees(cmpCode);

    await synchronizer.synchronizeDataCompaniesConnection();
    await synchronizer.synchronizeDataCompaniesUsers();
    await synchronizer.synchronizeDataWarehousesUsers();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.systemsynchronizedsuccessfully+' for ${cmpCode}',
          style: _appTextStyle,
        ),
      ),
    );
    print('System synchronized successfully for ${cmpCode}');
  }

  Future<void> _synchronizeCustomers(String cmpCode) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    DataSynchronizerFromFirebaseToHive synchronizer =
        DataSynchronizerFromFirebaseToHive();
    List<String> seCodes = await synchronizer.retrieveSeCodes(widget.usercode,cmpCode);

    // Step 2: Retrieve itemCodes based on seCodes from SalesEmployeesItems
  /*  List<String> itemCodes =
        await synchronizer.retrieveItemCodes(seCodes, cmpCode);
    List<String> brandCode =
        await synchronizer.retrieveItemBrand(seCodes, cmpCode);*/
    /*List<String> categCode =
        await synchronizer.retrieveItemCateg(seCodes, cmpCode);*/
  /*  List<String> groupCode =
        await synchronizer.retrieveItemGroupCodes(seCodes, cmpCode);*/
    List<String> custCode =
        await synchronizer.retrieveCustCodes(seCodes, cmpCode);
   /* List<String> itemCode =
        await synchronizer.retrieveItemCodes(seCodes, cmpCode);*/
    /*List<String> custGroupCodes =
        await synchronizer.retrieveItemCodes(custCode, cmpCode);*/
    print('lo');
    await synchronizer.synchronizeCustomers(custCode,cmpCode);
    print('l');
    await synchronizer.synchronizeCustomerAddresses(custCode,cmpCode);
    await synchronizer.synchronizeCustomerContacts(custCode,cmpCode);
    await synchronizer.synchronizeCustomerProperties(custCode,cmpCode);
    await synchronizer.synchronizeCustomerAttachments(custCode,cmpCode);

   /* await synchronizer.synchronizeCustomerItemsSpecialPrice(custCode, itemCode);
    await synchronizer.synchronizeCustomerBrandsSpecialPrice(
        custCode, brandCode);
    await synchronizer.synchronizeCustomerGroupsSpecialPrice(
        custCode, groupCode);
    await synchronizer.synchronizeCustomerCategSpecialPrice(
        custCode, categCode);

    await synchronizer.synchronizeCustomerGroupItemsSpecialPrice(
        itemCode, custGroupCodes);
    await synchronizer.synchronizeCustomerGroupBrandSpecialPrice(
        brandCode, custGroupCodes);
    await synchronizer.synchronizeCustomerGroupGroupSpecialPrice(
        groupCode, custGroupCodes);
    await synchronizer.synchronizeCustomerGroupCategSpecialPrice(
        categCode, custGroupCodes);

    await synchronizer.synchronizeCustomerPropItemsSpecialPrice(
        itemCode, custCode);
    await synchronizer.synchronizeCustomerPropBrandSpecialPrice(
        brandCode, custCode);
    await synchronizer.synchronizeCustomerPropGroupSpecialPrice(
        custGroupCodes, custCode);
    await synchronizer.synchronizeCustomerPropCategSpecialPrice(
        categCode, custCode);
*/
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.customerssynchronizedsuccessfully+' for ${cmpCode}',
          style: _appTextStyle,
        ),
      ),
    );
    print('Customers synchronized successfully for ${cmpCode}');
  }

Future<void> _synchronizeDatatoHive(String cmpCode) async {
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    try {
      // Set loading state to true before starting synchronization
      setState(() {
        _loading = true;
      });

      // Your existing synchronization logic
      DataSynchronizerFromFirebaseToHive synchronizer =
          DataSynchronizerFromFirebaseToHive();

      // Run the synchronization process
      await _synchronizeSystem(cmpCode);
      await _synchronizeItems(cmpCode);
      await _synchronizePriceLists(cmpCode);

      await _synchronizeCustomers(cmpCode);
      // Simulate a delay for demonstration purposes (remove in production)
      await Future.delayed(Duration(seconds: 3));

      // Display a success message or update UI as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.dataissynchronized+' for ${cmpCode}',
            style: _appTextStyle,
          ),
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
  void _showLoadingOverlay(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        //content: CircularProgressIndicator(),
      );
    },
  );
}

void _hideLoadingOverlay(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
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

class DropDownCompanies extends StatefulWidget {
  const DropDownCompanies({
    super.key,
    required this.companies,
    required this.checkedCompanies,
  });

  final List<Map<String, dynamic>> companies;
  final List<bool> checkedCompanies;

  @override
  State<DropDownCompanies> createState() => _DropDownCompaniesState();
}

class _DropDownCompaniesState extends State<DropDownCompanies> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Companies:'),
          DropdownButton(
            style: TextStyle(color: Colors.blue, fontSize: 18),
            icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
            iconSize: 24,
            elevation: 16,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Colors.blue,
            ),
            items: widget.companies.map((company) {
              int index = widget.companies.indexOf(company);
              return DropdownMenuItem<int>(
                value: index,
                child: Row(
                  children: [
                    Text(company['cmpName'] ?? ''),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Checkbox(
                          value: widget.checkedCompanies[index],
                          onChanged: (value) {
                            setState(() {
                              widget.checkedCompanies[index] = value ?? false;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newValue) {},
          ),
        ],
      ),
    );
  }
}
