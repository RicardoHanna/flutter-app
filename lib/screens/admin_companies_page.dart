import 'dart:async';
import 'dart:math';

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

class CompaniesSettings extends StatefulWidget {
    final AppNotifier appNotifier;

   CompaniesSettings({required this.appNotifier});

  @override
  _CompaniesSettingsState createState() => _CompaniesSettingsState();
}

class _CompaniesSettingsState extends State<CompaniesSettings> {
TextStyle _appTextStyle=TextStyle();
 TextEditingController _searchController = TextEditingController();
 // late Stream<List<UserClass>> _usersStream;
  late List<CompaniesClass> users = [];
  late List<CompaniesClass> filteredUsers = [];

  late StreamController<List<CompaniesClass>> _userStreamController;
  Stream<List<CompaniesClass>> get _usersStream => _userStreamController.stream;
  late List<CompaniesClass> offlineUsers = []; // Add this line
String searchUsersGroup='';
 bool autoExport= false;
 bool importFromErpToMobile=false;
 bool importFromBackendToMobile=false;


   TextEditingController _connDatabaseController = TextEditingController();
  TextEditingController _connServerController = TextEditingController();
   TextEditingController _connPasswordController = TextEditingController();
      TextEditingController _connUserController = TextEditingController();
  TextEditingController _connPortController = TextEditingController();
  TextEditingController _typeDatabaseController = TextEditingController();
 
      bool _formChanged = false; // Added to track changes


 @override
  void initState() {
    super.initState();
    _userStreamController = StreamController<List<CompaniesClass>>.broadcast();
    _initUserStream();
    Hive.openBox<CompaniesConnection>('companiesConnectionBox');
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
    // Ensure that filteredUsers is initialized with offlineUsers
    filteredUsers = updatedUsers;

    // Automatically fill in data for the first user if available
    
  });
 
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


    // Add debug prints
    print('systemAdminID: $systemAdminID');
    print('Keys in companiesConnectionBox: ${companiesConnectionBox.keys}');
    print('companyConnection: $companyConnection');

    // Fill in the data if available
    if (companyConnection != null) {
      setState(() {
        _connDatabaseController.text = companyConnection.connDatabase;
        _connServerController.text = companyConnection.connServer;
        _connPasswordController.text = companyConnection.connPassword;
        _connUserController.text = companyConnection.connUser;
        _connPortController.text = companyConnection.connPort.toString();
        _typeDatabaseController.text = companyConnection.typeDatabase;
      });
    } else {
      // Print a message if companyConnection is null
      print('No CompaniesConnection found for systemAdminID: $systemAdminID');
    }
  }
}



   Future<void> _initUserStream() async {
    Stream<List<CompaniesClass>>? userStream = await _getUserStream();
    _userStreamController.addStream(userStream!);
  }
void _searchUsers(String query) {
  setState(() {
    if (query.isEmpty) {
      // If the query is empty, show all users
      filteredUsers = offlineUsers; // for offline mode
    } else {
       var userName;
      // If there is a query, filter offlineUsers based on the search query
      filteredUsers = offlineUsers.where((user) {
         if(AppLocalizations.of(context)!.language=='English'){
 userName = user.cmpName?.toLowerCase();
 searchUsersGroup=user.cmpName;
         }else{
 searchUsersGroup=user.cmpFName;
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
             , systemAdminID: company.systemAdminID ??'empty', notes: company.notes ??'empty'
            
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



// Function to generate a composite key
int _generateCompositeKey(int menucode, int groupcode) {
  // Use any logic that ensures uniqueness for your composite key
  return int.parse('$menucode$groupcode');
}

  bool isAssignMenuExpanded = false; // New variable to control expansion


  String expandedUsercode = '-1'; // Variable to track expanded user

 

int selectedImportSource = 1; // 1 for 'Import from ERP to Mobile', 2 for 'Import from Backend to Mobile'

  @override
  Widget build(BuildContext context) {
    _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text('Companies Settings', style: _appTextStyle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: _appTextStyle,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.serchName,
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
                        ],
                      ),
                    ),
                    if (expandedUsercode == user.cmpCode)
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                           
                            TextField(
                              decoration: InputDecoration(labelText: 'Connection Database'),
                            controller: _connDatabaseController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                     
                            ),
                            TextField(
                              decoration: InputDecoration(labelText: 'Connection Server'),
                           controller: _connServerController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                            ),
                             TextField(
                              decoration: InputDecoration(labelText: 'Connection UserName'),
                           controller: _connUserController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                     
                            ),
                 
                            TextField(
                              decoration: InputDecoration(labelText: 'Connection Password'),
                           controller: _connPasswordController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                     
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
                              decoration: InputDecoration(labelText: 'Connection Port'),
                            
                            ),
                            TextField(
                              decoration: InputDecoration(labelText: 'Type Database'),
                             controller: _typeDatabaseController,
              onChanged: (value) {
                    _formChanged = true; 
                  },
                     
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _toggleAssignMenuExpansion(user.cmpCode);
                                  },
                                  child: Text('Cancel'),
                                ),
                        ElevatedButton(
  onPressed: () async {
    // Create a new SystemAdmin object with the updated values
    CompaniesConnection updatedCompaniesConnection = CompaniesConnection(
      connectionID: _generateConnectionID(),
      connDatabase: _connDatabaseController.text,
      connServer: _connServerController.text,
      connUser: _connUserController.text,
      connPassword: _connPasswordController.text,
      connPort: int.tryParse(_connPortController.text) ?? 0,
      typeDatabase: _typeDatabaseController.text,
    );

    // Open the systemAdminBox
    var systemAdminBox = await Hive.openBox<CompaniesConnection>('companiesConnectionBox');

    // Check if the user already exists in the box
    if (systemAdminBox.containsKey(user.cmpCode)) {
      // Update the existing SystemAdmin object
      systemAdminBox.put(user.cmpCode, updatedCompaniesConnection);
    } else {
      // Insert the new SystemAdmin object
      systemAdminBox.put(user.cmpCode, updatedCompaniesConnection);
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
  child: Text('Update'),
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
        ],
      ),
    );
  }
}
