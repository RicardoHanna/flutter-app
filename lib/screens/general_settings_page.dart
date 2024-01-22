import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/TranslationsClass.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/syncronizesubmenu_hive.dart';
import 'package:project/hive/systemadmin_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/screens/admin_users_page.dart';

class GeneralSettings extends StatefulWidget {
    final AppNotifier appNotifier;

   GeneralSettings({required this.appNotifier});

  @override
  _GeneralSettingsState createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
TextStyle _appTextStyle=TextStyle();
 TextEditingController _searchController = TextEditingController();
 // late Stream<List<UserClass>> _usersStream;
  late List<TranslationsClass> users = [];
  late List<TranslationsClass> filteredUsers = [];

  late StreamController<List<TranslationsClass>> _userStreamController;
  Stream<List<TranslationsClass>> get _usersStream => _userStreamController.stream;
  late List<TranslationsClass> offlineUsers = []; // Add this line
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
    _userStreamController = StreamController<List<TranslationsClass>>.broadcast();
    _initUserStream();
    Hive.openBox<SystemAdmin>('systemAdminBox');
  }
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateOfflineUsers();
    printUserDataTranslations();
  }

  Future<void> printUserDataTranslations() async {
 var itemsBox = await Hive.openBox<SystemAdmin>('systemAdminBox');
    
    print('Printing Users:');
    for (var item in itemsBox.values) {
      print('Menu Code: ${item.autoExport}');
      print('Grp Code: ${item.groupcode}');

      print('-------------------------');
    }
  // Open 'translationsBox' for Translations
//itemsBox.clear();
  print('Printed all data');


}

Future<void> _updateOfflineUsers() async {
  Stream<List<TranslationsClass>>? userStream = await _getUserStream();
  List<TranslationsClass> updatedUsers = await userStream?.first ?? [];

  setState(() {
    offlineUsers = updatedUsers;
    // Ensure that filteredUsers is initialized with offlineUsers
    filteredUsers = updatedUsers;

    // Automatically fill in data for the first user if available
    
  });
 
}

void _toggleAssignMenuExpansion(int usercode) {
  
    setState(() {
      expandedUsercode = (expandedUsercode == usercode) ? -1 : usercode;
      // Fill in the form data when a user is selected
      if (expandedUsercode != -1) {
        _fillFormDataForUser(expandedUsercode);
      }
    });
    print(expandedUsercode);
    print(usercode);
  }

  void _fillFormDataForUser(int usercode) {
    // Retrieve the SystemAdmin data from the systemAdminBox
    var systemAdminBox = Hive.box<SystemAdmin>('systemAdminBox');
    SystemAdmin? systemAdmin = systemAdminBox.get(usercode);

    // Fill in the data if available
    if (systemAdmin != null) {
      setState(() {
        autoExport = systemAdmin.autoExport;
        _connDatabaseController.text = systemAdmin.connDatabase;
        _connServerController.text = systemAdmin.connServer;
        _connPasswordController.text = systemAdmin.connPassword;
        _connUserController.text=systemAdmin.connUser;
        _connPortController.text = systemAdmin.connPort.toString();
        _typeDatabaseController.text = systemAdmin.typeDatabase;
        importFromErpToMobile=systemAdmin.importFromErpToMobile;
        importFromBackendToMobile=systemAdmin.importFromBackendToMobile;
        
      });
    }
  }


   Future<void> _initUserStream() async {
    Stream<List<TranslationsClass>>? userStream = await _getUserStream();
    _userStreamController.addStream(userStream!);
  }
void _searchUsers(String query) {
  setState(() {
    if (query.isEmpty) {
      // If the query is empty, show all users
      filteredUsers = offlineUsers; // for offline mode
    } else {
      
      // If there is a query, filter offlineUsers based on the search query
      filteredUsers = offlineUsers.where((user) {
         if(AppLocalizations.of(context)!.language=='English'){

 searchUsersGroup=user.translations['en']!;
         }else{
 searchUsersGroup=user.translations['ar']!;
         }
        final userName = user.translations['en']?.toLowerCase();
        final input = query.toLowerCase();
        return userName!.contains(input);
      }).toList();
    }
  });
}
Future<Stream<List<TranslationsClass>>> _getUserStream() async {
  try {
    // Offline: Retrieve data from Hive
    var userBox = await Hive.openBox<Translations>('translationsBox');

    if (userBox == null) {
      // Handle the case where opening the box failed
      print('Error: translationsBox is null');
      return Stream.error('Error opening translationsBox');
    }

    // Get all keys in the userBox
    List<int> allKeys = userBox.keys.cast<int>().toList();

    // List to store offline users
    List<TranslationsClass> offlineUsers = [];

    // Loop through each key and retrieve user data
    for (int key in allKeys) {
      try {
        // Retrieve user data from Hive
        Translations? user = userBox.get(key);

        // Check if user is not null
        if (user != null) {
          offlineUsers.add(TranslationsClass(
            groupcode: user.groupcode ?? 0,
            translations: {'en': user.translations['en']??'empty', 'ar': user.translations['ar']??'empty'},
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






// Function to generate a composite key
int _generateCompositeKey(int menucode, int groupcode) {
  // Use any logic that ensures uniqueness for your composite key
  return int.parse('$menucode$groupcode');
}

  bool isAssignMenuExpanded = false; // New variable to control expansion


  int expandedUsercode = -1; // Variable to track expanded user

 


  @override
  Widget build(BuildContext context) {
    _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.generalSettings, style: _appTextStyle),
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
                    ? user.translations['en']!
                    : user.translations['ar']!;
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
                              
                              _toggleAssignMenuExpansion(user.groupcode);
                            },
                          ),
                        ],
                      ),
                    ),
                    if (expandedUsercode == user.groupcode)
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                           
                            SwitchListTile(
                              title: Text('Automatically Export'),
                              value: autoExport,
                              onChanged: (value) {
                                setState(() {
                                  autoExport = value ?? false;
                                });
                              },
                            ),
          SizedBox(height: 10,),   
                             SwitchListTile(
                              title: Text('Import from ERP to Mobile'),
                              value: importFromErpToMobile,
                              onChanged: (value) {
                                setState(() {
                                  importFromErpToMobile = value ?? false;
                                });
                              },
                            ),
                                
                             SizedBox(height: 10,),   

                              SwitchListTile(
                              title: Text('Import from Backend to Mobile'),
                              value: importFromBackendToMobile,
                              onChanged: (value) {
                                setState(() {
                                  importFromBackendToMobile = value ?? false;
                                });
                              },
                            ),
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
                                    _toggleAssignMenuExpansion(user.groupcode);
                                  },
                                  child: Text('Cancel'),
                                ),
                               ElevatedButton(
  onPressed: () async {
   
    // Create a new SystemAdmin object with the updated values
    SystemAdmin updatedSystemAdmin = SystemAdmin(
      autoExport: autoExport,
      connDatabase: _connDatabaseController.text,
      connServer: _connServerController.text,
      connUser: _connUserController.text,
      connPassword: _connPasswordController.text,
      connPort: int.tryParse(_connPortController.text) ?? 0,
      typeDatabase: _typeDatabaseController.text,
      groupcode: user.groupcode,
      importFromErpToMobile: importFromErpToMobile,
      importFromBackendToMobile: importFromBackendToMobile
    );

    // Open the systemAdminBox
    var systemAdminBox = await Hive.openBox<SystemAdmin>('systemAdminBox');

    // Check if the user already exists in the box
    if (systemAdminBox.containsKey(user.groupcode)) {
      // Update the existing SystemAdmin object
      systemAdminBox.put(user.groupcode, updatedSystemAdmin);
    } else {
      // Insert the new SystemAdmin object
      systemAdminBox.put(user.groupcode, updatedSystemAdmin);
    }

    // Optionally, you can close the current screen or perform other actions
    _toggleAssignMenuExpansion(user.groupcode);
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
