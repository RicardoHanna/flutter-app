import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class AdminPage extends StatefulWidget {
    final AppNotifier appNotifier;
   AdminPage({required this.appNotifier});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  TextEditingController _searchController = TextEditingController();
 // late Stream<List<UserClass>> _usersStream;
  late List<UserClass> users = [];
  late List<UserClass> filteredUsers = [];
  TextStyle _appTextStyle=TextStyle();
  late StreamController<List<UserClass>> _userStreamController;
  Stream<List<UserClass>> get _usersStream => _userStreamController.stream;
  late List<UserClass> offlineUsers = []; // Add this line

void _initializeConnectivity() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      _syncDeletedUsersWithFirestore();
    }
  });
}

  void initState() {
    super.initState();
    _userStreamController = StreamController<List<UserClass>>.broadcast();
    _initUserStream();

  }

   Future<void> _initUserStream() async {
    Stream<List<UserClass>>? userStream = await _getUserStream();
    _userStreamController.addStream(userStream!);
  }

void _searchUsers(String query) {
  setState(() {
    if (query.isEmpty) {
      // If the query is empty, show all users
      filteredUsers = users; // for online mode
    } else {
      // If there is a query, filter filteredUsers based on the search query
      if (users.isNotEmpty) {
        // Online mode
        filteredUsers = users.where((user) {
          final userName = user.username.toLowerCase();
          final input = query.toLowerCase();
          return userName.contains(input) ||
              user.email.toLowerCase().contains(input);
        }).toList();
      } else {
        // Offline mode
        filteredUsers = offlineUsers.where((user) {
          final userName = user.username.toLowerCase();
          final input = query.toLowerCase();
          return userName.contains(input) ||
              user.email.toLowerCase().contains(input);
        }).toList();
      }
    }
  });
}


Future<Stream<List<UserClass>>> _getUserStream() async {
    var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult != ConnectivityResult.none) {
      // Online: Listen for real-time updates from Firestore
      var snapshot = await FirebaseFirestore.instance.collection('Users').get();

      users = snapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

  
          String username = data['username'] as String? ?? 'DefaultUsername';
          String email = data['email'] as String? ?? 'DefaultEmail';
          String password = data['password'] as String? ?? 'DefaultPass';
          String phonenumber = data['phonenumber'] as String? ?? 'DefaultPhone';
          String warehouse = data['warehouse'] as String? ?? 'DefaultWarehouse';
          int usergroup = data['usergroup'] as int? ?? 0;
          int font = data['font'] as int? ?? 0;
          String imeicode = data['imeicode'] as String? ?? 'DefaultIMEsI';
          String languages = data['languages'] as String? ?? 'DefaultLanguages';
          bool active = data['active'] as bool? ?? false;

            return UserClass(
              username: username,
              email: email,
              password: password,
              phonenumber: phonenumber,
              imeicode: imeicode,
              warehouse: warehouse,
              usergroup: usergroup,
              font: font,
              languages: languages,
              active: active,
            );
          }).toList();
           _userStreamController.add(users);
      
      
    }   else {
  // Offline: Retrieve data from Hive
  var userBox = await Hive.openBox('userBox');
  offlineUsers = [];

  // Get all keys in the userBox
  List<String> allKeys = userBox.keys.cast<String>().toList();

  // Loop through each key and retrieve user data
  for (String key in allKeys) {
    // Retrieve user data as a dynamic map
    dynamic userDataDynamic = userBox.get(key);

    // Convert the dynamic map to Map<String, dynamic> or null
    Map<String, dynamic>? userData = userDataDynamic is Map ? Map<String, dynamic>.from(userDataDynamic) : null;

    print('hive get userData for key $key: $userData');

    // Check if userData is not null
    if (userData != null) {
      // Convert Map from Hive to UserClass and add to the users list
      offlineUsers.add(UserClass(
            username: userData['username'] ?? 'DefaultUsername',
            email: userData['email'] ?? 'DefaultEmail',
            password: userData['password'] ?? 'DefaultPass',
            phonenumber: userData['phonenumber'] ?? 'DefaultPhone',
            imeicode: userData['imeicode'] ?? 'DefaultIMEsI',
            warehouse: userData['warehouse'] ?? 'DefaultWarehouse',
            usergroup: userData['usergroup'] ?? 0,
            font: userData['font'] ?? 0,
            languages: userData['languages'] ?? 'DefaultLanguages',
            active: userData['active'] ?? false,
          ));
    }
  }

  // Return the list of users as a stream
   return Stream.value(offlineUsers);
}
  // Default return statement in case neither online nor offline conditions are met
  return Stream.empty();
  }


Future<void> _deleteUserOffline(String email) async {
  var userBox = await Hive.openBox('userBox');
  
  // Mark the user as deleted (you can use a specific field like 'isDeleted')
  userBox.put(email, {'isDeleted': true});
}

Future<void> _syncDeletedUsersWithFirestore() async {
  var userBox = await Hive.openBox('userBox');
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult != ConnectivityResult.none) {
    try {
      // Get all keys in the local database
      List<String> allKeys = userBox.keys.cast<String>().toList();

      // Loop through each key and retrieve user data
      for (String key in allKeys) {
        dynamic userDataDynamic = userBox.get(key);

        // Ensure that userDataDynamic is not null and is a Map
        if (userDataDynamic is Map<String, dynamic>) {
          Map<String, dynamic> userData = userDataDynamic;

          // Check if the user is marked as deleted
          if (userData['isDeleted'] == true) {
            // Query for the document with the given email
            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection('Users')
                .where('email', isEqualTo: userData['email'])
                .get();

            // Check if the document exists
            if (querySnapshot.docs.isNotEmpty) {
              // Delete the document
              await querySnapshot.docs.first.reference.delete();
              print('Deleted user from Firestore for email ${userData['email']}');
            } else {
              print('Document with email ${userData['email']} not found in Firestore.');
            }

            // Remove the synced user data from the local database
            await userBox.delete(key);
          }
        }
      }
    } catch (e) {
      print('Error syncing deleted users with Firestore: $e');
    }
  }
}



void _deleteUser(String username,String email) async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDeletion,style: _appTextStyle),
        content: Text(AppLocalizations.of(context)!.textDeletion('$username','$username'),style: _appTextStyle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Do not delete
            },
            child: Text(AppLocalizations.of(context)!.cancel,style: _appTextStyle),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm deletion
            },
            child: Text(AppLocalizations.of(context)!.delete,style: _appTextStyle),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    try {
      
       await _deleteUserOffline(email);
      var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Changes will be applied when online.")),
    );
         
    return;
  }
      // Query for the document with the given username
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .get();

      // Check if the document exists
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the document
        await querySnapshot.docs.first.reference.delete();
      } else {
        print('Document with username $username not found.');
      }

      // No need to update the stream here; it will be updated in _getUserStream
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}


  @override
  Widget build(BuildContext context) {
     _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.adminPage,style: _appTextStyle),
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
            child: StreamBuilder<List<UserClass>>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                List<UserClass> userList = snapshot.data ?? [];

                return ListView.builder(
  itemCount: filteredUsers.isEmpty ? userList.length : filteredUsers.length,
  itemBuilder: (context, index) {
    filteredUsers=offlineUsers;
    final user = filteredUsers.isEmpty ? userList[index] : offlineUsers[index];
                    return ListTile(
                      title: Text(user.username, style: _appTextStyle),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditUserForm(
                                    username: user.username,
                                    email: user.email,
                                    password: user.password,
                                    phonenumber: user.phonenumber,
                                    imeicode:user.imeicode,
                                    warehouse: user.warehouse,
                                    usergroup: user.usergroup,
                                    font: user.font,
                                    languages: user.languages,
                                    active: user.active,
                                    appNotifier: widget.appNotifier,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteUser(user.username,user.email);
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
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserForm(appNotifier:widget.appNotifier)),
              );
            },
            child: Text(AppLocalizations.of(context)!.add,style: _appTextStyle),
          ),
        ],
      ),
    );
  }
}
