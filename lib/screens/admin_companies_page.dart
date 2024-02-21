import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/CompaniesClass.dart';
import 'package:project/classes/TranslationsClass.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesconnection_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/syncronizesubmenu_hive.dart';
import 'package:project/hive/systemadmin_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompaniesSettings extends StatefulWidget {
    final AppNotifier appNotifier;

   CompaniesSettings({required this.appNotifier});

  @override
  _CompaniesSettingsState createState() => _CompaniesSettingsState();
}

class _CompaniesSettingsState extends State<CompaniesSettings> {
TextStyle _appTextStyle=TextStyle();
 TextEditingController _searchController = TextEditingController();
 TimeOfDay noTime = TimeOfDay(hour: 0, minute: 0);

 // late Stream<List<UserClass>> _usersStream;
  late List<CompaniesClass> users = [];
  late List<CompaniesClass> filteredUsers = [];
List<CompaniesClass> additionalCompanies = []; // Define additionalCompanies

  late StreamController<List<CompaniesClass>> _userStreamController;
  Stream<List<CompaniesClass>> get _usersStream => _userStreamController.stream;
  late List<CompaniesClass> offlineUsers = []; // Add this line
String searchUsersGroup='';
 bool autoExport= false;
 bool importFromErpToMobile=false;
 bool importFromBackendToMobile=false;

String connectionId='';
   TextEditingController _connDatabaseController = TextEditingController();
  TextEditingController _connServerController = TextEditingController();
   TextEditingController _connPasswordController = TextEditingController();
      TextEditingController _connUserController = TextEditingController();
  TextEditingController _connPortController = TextEditingController();
  TextEditingController _typeDatabaseController = TextEditingController();
 
      bool _formChanged = false; // Added to track changes

bool _obscureText = true;
 @override
  void initState() {
    super.initState();
    _userStreamController = StreamController<List<CompaniesClass>>.broadcast();
    _initUserStream();
    Hive.openBox<CompaniesConnection>('companiesConnectionBox');
    //_loadAdditionalCompanies();
  }
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateOfflineUsers();
  printUserDataTranslations();
  }

  Future<void> printUserDataTranslations() async {
 var itemsBox = await Hive.openBox<CompaniesConnection>('companiesConnectionBox');

    print('Printing Users:');
    for (var item in itemsBox.values) {
      print('Menu Code: ${item.connectionID}');
      print('Grp Code: ${item.connPort}');
      print(item.connServer);

      print('-------------------------');
    }
  // Open 'translationsBox' for Translations
//itemsBox.clear();
  print('Printed all data');


}


Future<void> _updateOfflineUsers() async {
  Stream<List<CompaniesClass>>? userStream = await _getUserStream();
  List<CompaniesClass> updatedUsers = await userStream?.first ?? [];

  setState(() {
    offlineUsers = updatedUsers;
    filteredUsers = updatedUsers ; // Combine existing companies and additional companies
  });
}

void _testConnection(String cmpCode) async {

  var companiesConnectionBox = Hive.box<CompaniesConnection>('companiesConnectionBox');
  CompaniesConnection? companyConnection = companiesConnectionBox.get(cmpCode);
print(companyConnection?.connServer);
  if (companyConnection != null) {
    // Perform the connection testing logic
    bool connectionValid = await _performConnectionTest(companyConnection);

    // Show a ScaffoldMessenger indicating the result of the connection test
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(connectionValid ? "Connection is valid" : "Connection is not valid"),
      ),
    );
  } else {
    // Show a ScaffoldMessenger indicating that the connection details are not found
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Connection details not found"),
      ),
    );
  }
}
Future<bool> _performConnectionTest(CompaniesConnection connection) async {
  try {
    String server = connection.connServer;
    int port = connection.connPort;
    String user = connection.connUser;
    String password = connection.connPassword;
    String database = connection.connDatabase;

    // Construct the connection string
    String connectionString = "server=$server;port=$port;user=$user;password=$password;database=$database;";

    print('Attempting to establish connection to: $server:$port');

    // Attempt to establish a socket connection to the server
    final socket = await Socket.connect(server, port, timeout: Duration(seconds: 5));

    print('Socket connected successfully.');

    // Close the socket connection
    await socket.close();

    // If the socket connection succeeds, attempt to execute a query to verify database connectivity
    print('Attempting to connect to database...');

    // Create a temporary connection to the database to check its connectivity
;

    // Return true indicating a successful connection
    return true;
  } catch (e) {
    // Handle any errors that occur during the connection test
    print('Error during connection test: $e');
    return false; // Return false indicating an invalid connection
  }
}

void _deleteSpecificCompany(String cmpCode, String connId) {
  var companiesBox = Hive.box<Companies>('companiesBox');
    var companiesConnectionBox = Hive.box<CompaniesConnection>('companiesConnectionBox');

  Companies? company = companiesBox.values.firstWhere((element) => element.systemAdminID==connId);
    CompaniesConnection? companyConnection = companiesConnectionBox.get(connId);

   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  // Show the confirmation dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this company?",style:_appTextStyle),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("No",style: _appTextStyle,),
          ),
          TextButton(
            onPressed: () {
              // Check the condition before deleting the company
              if (company?.cmpFName == '' && company?.mainCurCode == '') {
                // Delete the company if the condition is met
                companiesBox.delete(cmpCode);
                companiesConnectionBox.delete(connId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Company deleted successfully",style: _appTextStyle,),
                  ),
                );
              } else {
                // Show a snackbar indicating that the company cannot be deleted
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("You cannot delete this company",style: _appTextStyle,),
                  ),
                );
              }
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Yes",style: _appTextStyle,),
          ),
        ],
      );
    },
  );
}



void _toggleAssignMenuExpansion(String cmpCode) {
  print('Before Toggle: expandedUsercode=$expandedUsercode, cmpCode=$cmpCode');
  
  setState(() {
    expandedUsercode = (expandedUsercode == cmpCode) ? '-1' : cmpCode;
    // Fill in the form data when a user is selected
    if (expandedUsercode != '-1') {
      _fillFormDataForUser(expandedUsercode);
    }
  });
print(connectionId);
  print('After Toggle: expandedUsercode=$expandedUsercode, cmpCode=$cmpCode');
}

void _fillFormDataForUser(String cmpCode) {
  // Retrieve the SystemAdmin data from the systemAdminBox
  var companiesBox = Hive.box<Companies>('companiesBox');
  Companies? company = companiesBox.get(cmpCode);

  if (company != null) {
    // Make sure systemAdminID is stored as String
    String systemAdminID = company.systemAdminID ?? '';

    var companiesConnectionBox = Hive.box<CompaniesConnection>('companiesConnectionBox');

    CompaniesConnection? companyConnection = companiesConnectionBox.get(company?.systemAdminID);

    print(cmpCode);
    // Update connectionId outside of setState
    connectionId = systemAdminID;
    print(connectionId);

    // Add debug prints
    print('systemAdminID: $systemAdminID');
    print('Keys in companiesConnectionBox: ${companiesConnectionBox.keys}');
    print('companyConnection: $companyConnection');

    // Fill in the data if available
    if (companyConnection != null && connectionId.isNotEmpty) {
      setState(() {
        _connDatabaseController.text = companyConnection.connDatabase;
        _connServerController.text = companyConnection.connServer;
        _connPasswordController.text = companyConnection.connPassword;
        _connUserController.text = companyConnection.connUser;
        _connPortController.text = companyConnection.connPort.toString();
        _typeDatabaseController.text = companyConnection.typeDatabase;
      });
    } else {
      _clearFormData();
      // Print a message if companyConnection is null
      print('No CompaniesConnection found for systemAdminID: $systemAdminID');
    }
  }
}

void _clearFormData() {
  setState(() {

    _connDatabaseController.text = ''; // Clear text controllers
    _connServerController.text = '';
    _connPasswordController.text = '';
    _connUserController.text = '';
    _connPortController.text = '';
    _typeDatabaseController.text = '';
  });
}

   Future<void> _initUserStream() async {
    Stream<List<CompaniesClass>>? userStream = await _getUserStream();
    _userStreamController.addStream(userStream!);
  }
void _searchUsers(String query) {
  setState(() {
    if (query.isEmpty) {
      // If the query is empty, show all users including the additional companies
      filteredUsers = offlineUsers ; // Combine existing companies and additional companies
    } else {
      var userName;
      // If there is a query, filter offlineUsers and additionalCompanies based on the search query
      filteredUsers = (offlineUsers ).where((user) {
        if (AppLocalizations.of(context)!.language == 'English') {
          userName = user.cmpName?.toLowerCase();
          searchUsersGroup = user.cmpName;
        } else {
          searchUsersGroup = user.cmpFName;
          userName = user.cmpFName?.toLowerCase();
        }

        final input = query.toLowerCase();
        return userName!.contains(input);
      }).toList();
    }
  });
}
Future<Stream<List<CompaniesClass>>> _getUserStream() async {
  try {
    // Offline: Retrieve data from Hive
    var companiesBox = await Hive.openBox<Companies>('companiesBox');

    if (companiesBox == null) {
      // Handle the case where opening the box failed
      print('Error: companiesBox is null');
      return Stream.error('Error opening companiesBox');
    }

    // Get all keys in the userBox
    List<String> allKeys = companiesBox.keys.cast<String>().toList();

    // List to store offline users
    List<CompaniesClass> offlineUsers = [];

    // Loop through each key and retrieve user data
    for (String key in allKeys) {
      try {
        // Retrieve user data from Hive
        Companies? company = companiesBox.get(key);

        // Check if user is not null
        if (company != null) {
          offlineUsers.add(CompaniesClass(
            cmpCode: company.cmpCode ??'empty',
            cmpName: company.cmpName  ??'empty',
            cmpFName: company.cmpFName ??'empty', tel: company.tel ??'empty', mobile: company.mobile ??'empty', 
            address: company.address ??'empty', fAddress:company.fAddress ??'empty', prHeader: company.prHeader ??'empty',
             prFHeader: company.prFHeader ??'empty', prFFooter:company.prFFooter ??'empty', 
             mainCurCode:company.mainCurCode ??'empty', secCurCode: company.secCurCode ??'empty', issueBatchMethod:company.issueBatchMethod ??'empty'
             , systemAdminID: company.systemAdminID ??'empty', notes: company.notes ??'empty', priceDec: company.priceDec ??0, amntDec: company.amntDec??0, qtyDec: company.qtyDec??0, rounding: company.roundMethod??'', importMethod: company.importMethod??'', time: company.time??noTime
            
          ));
        }
      } catch (e) {
        // Handle any errors that might occur during data retrieval
        print('Error retrieving user data for key $key: $e');
      }
    }

    // Return the list of users as a stream
    return Stream.value(offlineUsers);
  } catch (e) {
    // Handle any errors that might occur during box opening
    print('Error opening translationsBox: $e');
    return Stream.error('Error opening translationsBox');
  }
}




// ... (your imports and other code)



String _generateConnectionID() {
  // Implement your logic to generate a unique connectionID
  // For example, you can use a combination of timestamp and a random number
  return DateTime.now().millisecondsSinceEpoch.toString() +
      '_' +
      Random().nextInt(1000).toString();
}

String _generateCompanyCode() {
  // Implement your logic to generate a unique connectionID
  // For example, you can use a combination of timestamp and a random number
  return DateTime.now().millisecondsSinceEpoch.toString() +
      '_' +
      Random().nextInt(10).toString();
}


// Function to generate a composite key
int _generateCompositeKey(int menucode, int groupcode) {
  // Use any logic that ensures uniqueness for your composite key
  return int.parse('$menucode$groupcode');
}

void _showAddDialog() {
    String name = '';
    String company = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Company'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name of the company'),
                onChanged: (value) {
                  name = value;
                },
              ),
            
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate name and company
                if (name.isNotEmpty) {
                  // Add the new user to the list
                  _addUserToList(name);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  // Show an error message or handle validation as needed
                }
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }

void _addUserToList(String name) {
  // Add logic to add the new user to the filteredUsers list
  // and update the additionalCompanies list
  setState(() {
    CompaniesClass newCompany = CompaniesClass(
      cmpCode: '', // Add your logic to generate a code
      cmpName: name,
      cmpFName: '',
      tel: '',
      mobile: '',
      address: '',
      fAddress: '',
      prHeader: '',
      prFHeader: '',
      prFFooter: '',
      mainCurCode: '',
      secCurCode: '',
      issueBatchMethod: '',
      systemAdminID: '',
      notes: '', priceDec: 0, amntDec: 0, qtyDec: 0, rounding: '', importMethod: '', time: noTime,
      // Add other fields as needed
    );

    // Update both filteredUsers and additionalCompanies
    filteredUsers.add(newCompany);
    
  });

  // Save the data to Hive immediately
  _saveDataToHive(name);
}

// Save generated ID and name to SharedPreferences
Future<void> _saveToSharedPreferences(String id, String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('generatedId', id);
  prefs.setString('generatedName', name);
}



Future<void> _saveDataToHive(String name) async {
  try {
    // Save companiesConnec
    //tion data to Hive
     // Save companies data to Hive
    var companiesBox = await Hive.openBox<Companies>('companiesBox');
    
String  compCode=_generateCompanyCode();
    String connectionID = _generateConnectionID(); // You may need to adjust this based on your logic
    Companies companies =  Companies(
  cmpCode: compCode,
        cmpName: name, cmpFName: '', tel: '', mobile: '', address: '', fAddress: '',
         prHeader: '', prFHeader: '', prFooter: '', prFFooter: '', mainCurCode: '', secCurCode: '',
          rateType: '', issueBatchMethod: '', systemAdminID: connectionID, notes: '', priceDec: null, amntDec: null, qtyDec: null, roundMethod: '', importMethod: '', time: noTime,

    );

    companiesBox.put(compCode,companies);
    var companiesConnectionBox = await Hive.openBox<CompaniesConnection>('companiesConnectionBox');

    // Retrieve connection details from the UI controllers

    String connDatabase = '';
    String connServer = '';
    String connUser = '';
    String connPassword = '';
    int connPort = 0;
    String typeDatabase = '';

    // Create a new CompaniesConnection object
    CompaniesConnection updatedCompaniesConnection = CompaniesConnection(
      connectionID: connectionID,
      connDatabase: connDatabase,
      connServer: connServer,
      connUser: connUser,
      connPassword: connPassword,
      connPort: connPort,
      typeDatabase: typeDatabase,
    );

    // Save the updated connection details to Hive
    companiesConnectionBox.put(connectionID, updatedCompaniesConnection);

    // Save generated ID and name to SharedPreferences
   

  } catch (e) {
    // Handle errors appropriately
    print('Error saving data to Hive and SharedPreferences: $e');
  }
}





  bool isAssignMenuExpanded = false; // New variable to control expansion


  String expandedUsercode = '-1'; // Variable to track expanded user

 

int selectedImportSource = 1; // 1 for 'Import from ERP to Mobile', 2 for 'Import from Backend to Mobile'

  @override
  Widget build(BuildContext context) {
    _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.companiesSettings, style: _appTextStyle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: _appTextStyle,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchByName,
                prefixIcon: Icon(Icons.search,),
              ),
              onChanged: (value) {
                _searchUsers(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                String languageUser = (AppLocalizations.of(context)!.language == 'English')
                    ? user.cmpName
                    : user.cmpFName!;
                return Column(
                  children: [
                    ListTile(
                      title: Text(languageUser, style: _appTextStyle),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.expand_circle_down),
                            color: Colors.blue,
                            onPressed: () {
                              
                              _toggleAssignMenuExpansion(user.cmpCode);
                            },
                          ),
                           IconButton(
                            icon: Icon(Icons.cast_connected_outlined),
                            color: Colors.green,
                            onPressed: () {
                              
                        _testConnection(user.systemAdminID);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              
                             _deleteSpecificCompany(user.cmpCode,user.systemAdminID);
                            },
                          ),
                        ],
                      ),
                    ),
                    if (expandedUsercode == user.cmpCode)
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                           
                            TextField(
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.connectionDatabase),
                            controller: _connDatabaseController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                     
                            ),
                            TextField(
                              decoration: InputDecoration(labelText:  AppLocalizations.of(context)!.connectionServer),
                           controller: _connServerController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                            ),
                             TextField(
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.connectionUserName),
                           controller: _connUserController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                     
                            ),
                 
                          TextField(
                           controller: _connPasswordController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText:  AppLocalizations.of(context)!.connectionPassword,
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
                          ),
                            TextField(
                              keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
            controller: _connPortController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.connectionPort),
                            
                            ),
                             DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.typeDatabase,
      ),
      value: 'Sql Server', // Set the initial value to 'Sql Server'
      onChanged: (newValue) {
        setState(() {
          _typeDatabaseController.text = newValue!;
        });
      },
      items: <String>['Sql Server'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ),
                     
                          
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _toggleAssignMenuExpansion(user.cmpCode);
                                  },
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                ),
                        ElevatedButton(
  onPressed: () async {

 CompaniesConnection updatedCompaniesConnection;

if (connectionId == '') {
  // Create a new SystemAdmin object with the updated values
  updatedCompaniesConnection = CompaniesConnection(
    connectionID: _generateConnectionID(),
    connDatabase: _connDatabaseController.text,
    connServer: _connServerController.text,
    connUser: _connUserController.text,
    connPassword: _connPasswordController.text,
    connPort: int.tryParse(_connPortController.text) ?? 0,
    typeDatabase: _typeDatabaseController.text,
  );
} else {
  updatedCompaniesConnection = CompaniesConnection(
    connectionID: connectionId,
    connDatabase: _connDatabaseController.text,
    connServer: _connServerController.text,
    connUser: _connUserController.text,
    connPassword: _connPasswordController.text,
    connPort: int.tryParse(_connPortController.text) ?? 0,
    typeDatabase: _typeDatabaseController.text,
  );
}
    // Open the systemAdminBox
    var systemAdminBox = await Hive.openBox<CompaniesConnection>('companiesConnectionBox');

    // Check if the user already exists in the box
    if (systemAdminBox.containsKey(user.systemAdminID)) {
      // Update the existing SystemAdmin object
      systemAdminBox.put(user.systemAdminID, updatedCompaniesConnection);
    } else {
      // Insert the new SystemAdmin object
      systemAdminBox.put(user.systemAdminID, updatedCompaniesConnection);
    }

    // Retrieve the connectionID
    String connectionID = updatedCompaniesConnection.connectionID;

    // Open the companiesBox
    var companiesBox = await Hive.openBox<Companies>('companiesBox');

    // Check if the user exists in the box
    if (companiesBox.containsKey(user.cmpCode)) {
      // Retrieve the existing Companies object
      Companies? company = companiesBox.get(user.cmpCode);

      // Update the systemAdminID field with the new connectionID
      company?.systemAdminID = connectionID;

      // Put the updated Companies object back into the box
      companiesBox.put(user.cmpCode, company!);
    }

    // Optionally, you can close the current screen or perform other actions
    _toggleAssignMenuExpansion(user.cmpCode);
  },
  child: Text(AppLocalizations.of(context)!.update),
),


                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showAddDialog();
            },
            style: ButtonStyle(
       fixedSize: MaterialStateProperty.all(Size(280, 10)), // Set the width and height
  ),
            child: Text(AppLocalizations.of(context)!.add,style: _appTextStyle),
          ),
        ],
      ),
    );
  }
}
