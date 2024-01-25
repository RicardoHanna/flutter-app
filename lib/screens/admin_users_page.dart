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
import 'package:project/hive/userssalesemployees_hive.dart';

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

final TextEditingController codeFilterController = TextEditingController();
  final TextEditingController activeFilterController = TextEditingController();
  final TextEditingController inactiveFilterController = TextEditingController();
  final TextEditingController itemNameFilterController = TextEditingController();

late List<String> activeList = [];

  late List<String> selectedActive = [];

  late Box userBox;

void initState() {
  super.initState();
  // Call async method within initState
userBox= Hive.box('userBox');
  initializeData();
    _userStreamController = StreamController<List<UserClass>>.broadcast();
    _initUserStream();

  }
 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateOfflineUsers();
  }
Future<void> initializeData() async {
  List<UserClass> userList = await _getUsers();
  users = userList;
  filteredUsers = List.from(users);

  activeList = await getDistinctValuesFromBox('Active', userBox);

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
Future<List<UserClass>> _getUsers() async {
  var usersBox = await Hive.openBox('userBox');
  var allUsers = usersBox.values.toList();

  List<UserClass> usersList = []; // Adjust this type based on your UserClass

  for (var userData in allUsers) {
    var user = UserClass(
      usercode: userData['usercode'],
      username: userData['username'],
      userFname: userData['userFname'],
      email: userData['email'],
      password: userData['password'],
      phonenumber: userData['phonenumber'],
      imeicode: userData['imeicode'],
      usergroup: userData['usergroup'],
      font: userData['font'],
      languages: userData['languages'],
      active: userData['active'],
    );

    usersList.add(user);
  }

  return usersList;
}


Future<List<String>> getDistinctValuesFromBox(String fieldName, Box box) async {
  var distinctValues = <String>{};
  
  for (var item in box.values) {
    var value = getField(item, fieldName);
    
    // Handle bool values by converting them to String
    if (value != null) {
      if (value is bool) {
        value = value.toString();
      }

      distinctValues.add(value);
    }
  }

  return distinctValues.toList();
}


dynamic getField(dynamic item, String fieldName) {
  if (item is User) {
    switch (fieldName) {
      case 'Active':
        return item.active;
     
      // Add cases for other fields as needed
      default:
        return null;
    }
  } else if (item is Map<dynamic, dynamic>) {
    // Handle the case when item is a Map<dynamic, dynamic>
    switch (fieldName) {
      case 'Active':
        return item['active'];

      default:
        return null;
    }
  } else if (item is bool) {
    // Handle the case when item is a bool
    switch (fieldName) {
      case 'Active':
        return item;

      // Add cases for other fields as needed
      default:
        return null;
    }
  } else {
    return null;
  }
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
            usercode: userData['usercode'] ?? '0',
            username: userData['username'] ?? 'DefaultUsername',
            userFname: userData['userFname'] ?? 'DefaultFUsername',
            email: userData['email'] ?? 'DefaultEmail',
            password: userData['password'] ?? 'DefaultPass',
            phonenumber: userData['phonenumber'] ?? 'DefaultPhone',
            imeicode: userData['imeicode'] ?? 'DefaultIMEsI',
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

void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filters Active Users',style: _appTextStyle,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMultiSelectChip('Active', activeList, selectedActive, setState),
            
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel,style: _appTextStyle,),
                ),
                TextButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.apply,style: _appTextStyle,),
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
  filteredUsers = users.where((user) {
    var activeMatch = selectedActive.isEmpty || selectedActive.contains(user.active.toString());

    return activeMatch;
  }).toList();

  setState(() {
    // Update the UI with the filtered items
  });
}




void _deleteUser(String username,String usercode) async {
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
    
    // Retrieve user data from Hive box based on usercode
    var user = userBox.get(usercode) as Map<dynamic, dynamic>?;

    if (user != null) {
    
      // Retrieve usergroup before deleting the user
      var userGroupToDelete = user['usergroup'];
           print(filteredUsers.length);


      if (userGroupToDelete == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You cannot delete Admin'),
          ),
        );
      } 
      
     else  if(filteredUsers.length==1){

 ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need to have at least one User in You App!'),
          ),
        );

      }
      
      
      
      else {

        // Check if usercode exists in UsersSalesEmployee
        var usersSalesEmployeeBox = await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');
      
        var salesEmployee = usersSalesEmployeeBox.values.firstWhere(
  (salesempl) => salesempl.userCode == usercode,
  orElse: () => UserSalesEmployees(cmpCode: '', userCode: '', seCode: '', notes: ''),
);

print(salesEmployee.cmpCode);
print(salesEmployee.seCode);
        if (salesEmployee.seCode != '' && salesEmployee.cmpCode!='') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User is associated with a Sales Employee. Cannot delete!.'),
            ),
          );
        } else {
          print('wdjdwokdw');
          // Continue with deletion if user is not associated with a Sales Employee
          userBox.delete(usercode);

          setState(() {
            offlineUsers.removeWhere((user) => user.usercode == usercode);
          });
        }
      }
    } else {
      print('User not found in Hive.');
      // Handle the case when the user is not found in Hive.
    }
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
        title: Text(AppLocalizations.of(context)!.adminusers,style: _appTextStyle),
        actions: [
          
   IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
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
          title: Text(user.usercode+"   "+languageUser, style: _appTextStyle),
     
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
                  _deleteUser(user.username, user.usercode);
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
