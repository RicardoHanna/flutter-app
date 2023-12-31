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

class AdminUsersPage extends StatefulWidget {
    final AppNotifier appNotifier;
   AdminUsersPage({required this.appNotifier});

  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  TextEditingController _searchController = TextEditingController();
 // late Stream<List<UserClass>> _usersStream;
  late List<UserClass> users = [];
  late List<UserClass> filteredUsers = [];
  TextStyle _appTextStyle=TextStyle();
  late StreamController<List<UserClass>> _userStreamController;
  Stream<List<UserClass>> get _usersStream => _userStreamController.stream;
  late List<UserClass> offlineUsers = []; // Add this line


  void initState() {
    super.initState();
    _userStreamController = StreamController<List<UserClass>>.broadcast();
    _initUserStream();

  }
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateOfflineUsers();
  }

 Future<void> _updateOfflineUsers() async {
  Stream<List<UserClass>>? userStream = await _getUserStream();
  List<UserClass> updatedUsers = await userStream?.first ?? [];
  
  setState(() {
    offlineUsers = updatedUsers;
    // Ensure that filteredUsers is initialized with offlineUsers
    filteredUsers = updatedUsers;
  });
}

   Future<void> _initUserStream() async {
    Stream<List<UserClass>>? userStream = await _getUserStream();
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
        final userName = user.username.toLowerCase();
        final input = query.toLowerCase();
        return userName.contains(input);
      }).toList();
    }
  });
}



Future<Stream<List<UserClass>>> _getUserStream() async {
  
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
            usercode: userData['usercode'] ?? 0,
            username: userData['username'] ?? 'DefaultUsername',
            userFname: userData['userFname'] ?? 'DefaultFUsername',
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
      
        var userBox = await Hive.openBox('userBox');
  
  // Mark the user as deleted (you can use a specific field like 'isDeleted')
  userBox.delete(email);

  // Update offlineUsers list after deletion
                setState(() {
                  offlineUsers.removeWhere((user) => user.email == email);
                });
               
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
            child:StreamBuilder<List<UserClass>>(
  stream: _usersStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    List<UserClass> userList = snapshot.data ?? [];
String languageUser='';

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        if(AppLocalizations.of(context)!.language=='English'){
languageUser=user.username;
}else{
  languageUser=user.userFname;
}
        return ListTile(
          title: Text(languageUser, style: _appTextStyle),
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
                        usercode: user.usercode,
                        username: user.username,
                        userFname: user.userFname,
                        email: user.email,
                        password: user.password,
                        phonenumber: user.phonenumber,
                        imeicode: user.imeicode,
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
                  _deleteUser(user.username, user.email);
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
