import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/TranslationsClass.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/screens/admin_users_page.dart';

class AdminUsersGroupPage extends StatefulWidget {
    final AppNotifier appNotifier;
   AdminUsersGroupPage({required this.appNotifier});

  @override
  _AdminUsersGroupPageState createState() => _AdminUsersGroupPageState();
}

class _AdminUsersGroupPageState extends State<AdminUsersGroupPage> {
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




Future<void> _editUserGroup(BuildContext context,String updatedGroupEn,String updatedGroupAr) async {
  Map<String, String>? newGroupEn = await showDialog(
    context: context,
    builder: (BuildContext context) {
TextEditingController newGroupControllerEn = TextEditingController(text: updatedGroupEn);
      TextEditingController newGroupControllerAr = TextEditingController(text: updatedGroupAr);
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.addUser, style: _appTextStyle),
        content: Column(
          children: [
            TextField(
              style: _appTextStyle,
              controller: newGroupControllerEn,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroupen),
            ),
            TextField(
              style: _appTextStyle,
              controller: newGroupControllerAr,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroupar),
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
              String groupEn = newGroupControllerEn.text.trim();
              String groupAr = newGroupControllerAr.text.trim();

              if (groupEn.isEmpty || groupAr.isEmpty) {
                // Show an error message if either field is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.bothNames)),
                );
                return;
              }

              // Check if the user group already exists
            /*  bool groupExists = offlineUsers.any((existingGroup) =>
                  existingGroup.translations['en'] == groupEn.toLowerCase() || existingGroup.translations['ar'] == groupAr.toLowerCase()
                  ||  existingGroup.translations['en'] == groupEn.toUpperCase() || existingGroup.translations['ar'] == groupAr.toUpperCase()
                   ||  existingGroup.translations['en'] == groupEn || existingGroup.translations['ar'] == groupAr
                   );

              if (groupExists) {
                // Show an error message if the user group already exists
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.alreadyExists)),
                );*/
             // } else {
                

  int newUserCode = 0;

  // Define the language variable based on your logic
  String language =
      AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';

  // Open the Hive box for translations
  var translationsBox = await Hive.openBox<Translations>('translationsBox');

 
  bool groupExists = offlineUsers.any(
    (existingGroup) =>
        existingGroup.translations['en']== groupEn.toLowerCase() ||
        existingGroup.translations['ar']== groupAr.toLowerCase(),
  );

  if (groupExists) {
    // Group exists, fetch user code from translations
    var translation = translationsBox.values.firstWhere(
      (t) =>
          t.translations[language]?.toLowerCase() == groupEn.toLowerCase() ||
          t.translations[language]?.toLowerCase() == groupAr.toLowerCase(),
      orElse: () => Translations(usercode: 0, translations: {}),
    );

   // newUserCode = translation.usercode;

 
      // Group doesn't exist, fetch user code from user groups collection
    var userGroupBox = await Hive.openBox<UserGroup>('userGroupBox');

var values = translationsBox.values;
  for (var userGroup in values) {
    if (userGroup.translations['en'] == updatedGroupEn) {
      newUserCode=userGroup.usercode; // Assuming usercode is the key you want to retrieve
    }
  }
     print(newUserCode);
    // Add the new user group to the user groups box
    await userGroupBox.put(newUserCode,UserGroup(usercode: newUserCode, username: groupEn));

    // Add the new translation to the translations box
    await translationsBox.put(newUserCode,Translations(
      usercode: newUserCode,
      translations: {'en': groupEn, 'ar': groupAr},
    ));
    
  int indexToUpdate = offlineUsers.indexWhere(
    (existingGroup) => existingGroup.usercode == newUserCode,
  );

  if (indexToUpdate != -1) {
    setState(() {
      offlineUsers[indexToUpdate].translations['en'] = groupEn;
      offlineUsers[indexToUpdate].translations['ar'] = groupAr;
    });
  } else {
    // This should not happen in your case, but handle it just in case
    print("Error: User code $newUserCode not found in offlineUsers");
  }
  
 
                // Return the new group if it doesn't exist
                Navigator.of(context).pop({'en': groupEn, 'ar': groupAr});
              }
            },
            child: Text(AppLocalizations.of(context)!.update, style: _appTextStyle),
          ),
        ],
      );
    },
  );
}

//-------------------------------------------------------------------

Future<void> _addNewUserGroup(BuildContext context) async {
  Map<String, String>? newGroupEn = await showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController newGroupControllerEn = TextEditingController();
      TextEditingController newGroupControllerAr = TextEditingController();
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.addUser, style: _appTextStyle),
        content: Column(
          children: [
            TextField(
              style: _appTextStyle,
              controller: newGroupControllerEn,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroupen),
            ),
            TextField(
              style: _appTextStyle,
              controller: newGroupControllerAr,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.usergroupar),
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
              String groupEn = newGroupControllerEn.text.trim();
              String groupAr = newGroupControllerAr.text.trim();

              if (groupEn.isEmpty || groupAr.isEmpty) {
                // Show an error message if either field is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.bothNames)),
                );
                return;
              }

              // Check if the user group already exists
              bool groupExists = offlineUsers.any((existingGroup) =>
                  existingGroup.translations['en'] == groupEn.toLowerCase() || existingGroup.translations['ar'] == groupAr.toLowerCase()
                  ||  existingGroup.translations['en'] == groupEn.toUpperCase() || existingGroup.translations['ar'] == groupAr.toUpperCase()
                   ||  existingGroup.translations['en'] == groupEn || existingGroup.translations['ar'] == groupAr
                   );

              if (groupExists) {
                // Show an error message if the user group already exists
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.alreadyExists)),
                );
              } else {
                

  int newUserCode = 0;

  // Define the language variable based on your logic
  String language =
      AppLocalizations.of(context)!.language == 'English' ? 'en' : 'ar';

  // Open the Hive box for translations
  var translationsBox = await Hive.openBox<Translations>('translationsBox');

 
  bool groupExists = offlineUsers.any(
    (existingGroup) =>
        existingGroup.translations['en']== groupEn.toLowerCase() ||
        existingGroup.translations['ar']== groupAr.toLowerCase(),
  );

  if (groupExists) {
    // Group exists, fetch user code from translations
    var translation = translationsBox.values.firstWhere(
      (t) =>
          t.translations[language]?.toLowerCase() == groupEn.toLowerCase() ||
          t.translations[language]?.toLowerCase() == groupAr.toLowerCase(),
      orElse: () => Translations(usercode: 0, translations: {}),
    );

    newUserCode = translation.usercode;
  
  } else {
    // Group doesn't exist, fetch user code from user groups collection
    var userGroupBox = await Hive.openBox<UserGroup>('userGroupBox');
    int latestUserCode = 0;

    if (userGroupBox.isNotEmpty) {
      latestUserCode = userGroupBox.values
          .map<int>((userGroup) => userGroup.usercode)
          .reduce((value, element) => value > element ? value : element);
    }

    newUserCode = latestUserCode + 1;

    // Add the new user group to the user groups box
    await userGroupBox.put(newUserCode, UserGroup(usercode: newUserCode, username: groupEn));

    // Add the new translation to the translations box
    await translationsBox.put(newUserCode, Translations(
      usercode: newUserCode,
      translations: {'en': groupEn, 'ar': groupAr},
    ));
     setState(() {
      offlineUsers.add( TranslationsClass(
            usercode:newUserCode ?? 0,
            translations: {'en':groupEn, 'ar':  groupAr},));
    });
  }
                // Return the new group if it doesn't exist
                Navigator.of(context).pop({'en': groupEn, 'ar': groupAr});
              }
            },
            child: Text(AppLocalizations.of(context)!.add, style: _appTextStyle),
          ),
        ],
      );
    },
  );
}





void _deleteUser(int usercode, String username) async {
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
      
        var userBox = await Hive.openBox<Translations>('translationsBox');
  
  // Mark the user as deleted (you can use a specific field like 'isDeleted')
  userBox.delete(usercode);

  // Update offlineUsers list after deletion
                setState(() {
                 offlineUsers.removeWhere((user) => user.usercode == usercode);
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
        title: Text(AppLocalizations.of(context)!.adminusergroup,style: _appTextStyle),
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
                icon: Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () {
                _editUserGroup(context,user.translations['en']!,user.translations['ar']!);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  _deleteUser(user.usercode,languageUser);
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
              _addNewUserGroup(context);
            },
            child: Text(AppLocalizations.of(context)!.add,style: _appTextStyle),
          ),
        ],
      ),
    );
  }
}
