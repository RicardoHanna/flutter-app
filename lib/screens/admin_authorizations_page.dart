import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/TranslationsClass.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/screens/admin_users_page.dart';

class AdminAuthorizationsPage extends StatefulWidget {
    final AppNotifier appNotifier;
   AdminAuthorizationsPage({required this.appNotifier});

  @override
  _AdminAuthorizationsPageState createState() => _AdminAuthorizationsPageState();
}

class _AdminAuthorizationsPageState extends State<AdminAuthorizationsPage> {
  TextStyle _appTextStyle=TextStyle();
 TextEditingController _searchController = TextEditingController();
 // late Stream<List<UserClass>> _usersStream;
  late List<TranslationsClass> users = [];
  late List<TranslationsClass> filteredUsers = [];

  late StreamController<List<TranslationsClass>> _userStreamController;
  Stream<List<TranslationsClass>> get _usersStream => _userStreamController.stream;
  late List<TranslationsClass> offlineUsers = []; // Add this line
String searchUsersGroup='';

  void initState() {
    super.initState();
    _userStreamController = StreamController<List<TranslationsClass>>.broadcast();
    _initUserStream();

  }
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateOfflineUsers();
    printUserDataTranslations();
  }

  Future<void> printUserDataTranslations() async {
 var itemsBox = await Hive.openBox<Authorization>('authorizationBox');
    
    print('Printing Users:');
    for (var item in itemsBox.values) {
      print('Menu Code: ${item.menucode}');
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
  });
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
            usercode: user.usercode ?? 0,
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

Future<void> _assignUserGroup(BuildContext context, String updatedGroupEn, String updatedGroupAr, int groupcode) async {
  var menuBox = await Hive.openBox<Menu>('menuBox');
  var menuItems = menuBox.values.toList();
  Set<int> selectedItems = {};

  // Load existing authorizations for the specified groupcode
  var authorizationBox = await Hive.openBox<Authorization>('authorizationBox');
  var existingAuthorizations = authorizationBox.values.where((auth) => auth.groupcode == groupcode);

  // Mark selected items based on existing authorizations
  for (var authorization in existingAuthorizations) {
    selectedItems.add(authorization.menucode);
  }

  // ignore: use_build_context_synchronously
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Assign User Group to Menu', style: _appTextStyle),
            content: Column(
              children: [
                for (var item in menuItems)
                  CheckboxListTile(
                    title: Text(item.menuname),
                    value: selectedItems.contains(item.menucode),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          selectedItems.add(item.menucode);
                          // Insert authorization when checking
                          int compositeKey = _generateCompositeKey(item.menucode, groupcode);
                          authorizationBox.put(compositeKey, Authorization(menucode: item.menucode, groupcode: groupcode));
                        } else {
                          selectedItems.remove(item.menucode);
                          // Delete authorization when unchecking
                          int compositeKey = _generateCompositeKey(item.menucode, groupcode);
                          authorizationBox.delete(compositeKey);
                        }
                      });
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cancel
                },
                child: Text(AppLocalizations.of(context)!.cancel, style: _appTextStyle),
              ),
              TextButton(
                onPressed: () async {
                  // Delete existing authorizations for the specified groupcode
                  await authorizationBox.delete((key, value) => value.groupcode == groupcode);

                  // Add new authorizations for the selected items
                  for (var selectedItem in selectedItems) {
                    int compositeKey = _generateCompositeKey(selectedItem, groupcode);
                    authorizationBox.put(compositeKey, Authorization(menucode: selectedItem, groupcode: groupcode));
                  }

                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(AppLocalizations.of(context)!.update, style: _appTextStyle),
              ),
            ],
          );
        },
      );
    },
  );
}

// Function to generate a composite key
int _generateCompositeKey(int menucode, int groupcode) {
  // Use any logic that ensures uniqueness for your composite key
  return int.parse('$menucode$groupcode');
}


//-------------------------------------------------------------------


  @override
  Widget build(BuildContext context) {
     _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text('Authorizations',style: _appTextStyle),
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
            child:StreamBuilder<List<TranslationsClass>>(
  stream: _usersStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    List<TranslationsClass> userList = snapshot.data ?? [];
String languageUser='';

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        if(AppLocalizations.of(context)!.language=='English'){
languageUser=user.translations['en']!;
}else{
  languageUser=user.translations['ar']!;
}
        return ListTile(
          title: Text(languageUser, style: _appTextStyle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children:[
              IconButton(
                icon: Icon(Icons.assignment_add),
                color: Colors.blue,
                onPressed: () {
                _assignUserGroup(context,user.translations['en']!,user.translations['ar']!,user.usercode);
                },
              ),
             
            ],
          ),
        );
      },
    );
  },
),

          ),
          
        ],
      ),
    );
  }
}
