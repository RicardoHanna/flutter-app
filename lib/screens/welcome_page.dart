import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Customers_Form.dart';
import 'package:project/Forms/Items_Form.dart';
import 'package:project/Forms/Price_Lists_Form.dart';
import 'package:project/Forms/settings_edit_user_form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/Synchronize/DataSynchronizerFromFirebaseToHive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/screens/admin_page.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/screens/synchronize_data_page.dart';
import 'package:project/utils.dart';
import 'settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/resources/add_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/Synchronize/DataSynchronizer.dart';


class welcomePage extends StatefulWidget {
  final String identifier;
  final String email;
  final String password;
  final AppNotifier appNotifier;
  welcomePage({required this.identifier,required this.password, required this.appNotifier,required this.email});

  @override
  State<welcomePage> createState() => _welcomePageState();
}

class _welcomePageState extends State<welcomePage> {
  late String _profilePicturePath='';
Uint8List ? _image;
String ?_image1;
 int _userGroup=0;
 String ? _username;

 String ? _userFname;
   @override
void initState() {
  super.initState();
 
  _loadUserGroup();
    loadUserGroupHive();
printUserMenu();

    // _synchronizeData();
 
}


 
  
     Future<void> _synchronizeData() async {
    DataSynchronizer dataSynchronizer = DataSynchronizer();
    await dataSynchronizer.synchronizeData();


  }

  Future<void> loadUserGroupHive() async {
    await Hive.initFlutter();
    //await insertUsers();
   // await insertUsersGroup();
    await printUserDataTranslations();
  }

    Future<void> printUserMenu() async {
 var itemsBox = await Hive.openBox<Authorization>('authorizationBox');
  var itemspriceBox = await Hive.openBox<ItemsPrices>('itemprices');
   print('Printing Users wdsdsd:');
    for (var item in itemspriceBox.values) {
      print('Username: ${item.plCode}');
      print('Email: ${item.price}');
}
    print('Printing Users Authooo:');
    for (var item in itemsBox.values) {
      print(item.key);
      print('Menu Code: ${item.menucode}');
      print('Grp Code: ${item.groupcode}');

      print('-------------------------');
    }
   // itemsBox.clear();
  // Open 'translationsBox' for Translations
//itemsBox.clear();
  print('Printed all data');


}

 Future<void> insertUsers() async {


    var userTranslationsBox = await Hive.openBox<Translations>('translationsBox');

    // Insert users with roles
    var userGroupsTranslations = <Translations>[
      Translations(usercode: 1, translations: {'en': 'Admin', 'ar': 'مسؤل'}),
      Translations(usercode: 2, translations: {'en': 'User', 'ar': 'مستخدم'}),
      Translations(usercode: 3, translations: {'en': 'manager', 'ar': 'مدير'}),
      Translations(usercode: 4, translations: {'en': 'representative', 'ar': 'مندوب'}),
      Translations(usercode: 5, translations: {'en': 'hr', 'ar': 'موارد'}),
    
    ];

    await userTranslationsBox.addAll(userGroupsTranslations);

    print('Data inserted successfully');
  }

 Future<void> insertUsersGroup() async {


    var userGroupBox = await Hive.openBox<UserGroup>('userGroupBox');

    // Insert users with roles
    var userGroups = <UserGroup>[
      UserGroup(usercode: 1, username:'Admin'),
      UserGroup(usercode: 2, username:'User'),
      UserGroup(usercode: 3, username:'representative'),
      UserGroup(usercode: 4,  username:'hr'),

    
    ];

    await userGroupBox.addAll(userGroups);

    print('Data inserted successfully');
  }
 

Future<void> printUserDataTranslations() async {
  // Open 'userBox' for Users
    var usersBox = await Hive.openBox('userBox');

    print('Printing Users:');
    for (var user in usersBox.values) {
      print('Username: ${user.username}');
      print('Email: ${user.email}');
      print('-------------------------');
    }
  
  // Open 'translationsBox' for Translations
  var userTranslationBox = await Hive.openBox('translationsBox');

  print('Printing Translations:');
  for (var userTGroup in userTranslationBox.values) {
    print('User Code: ${userTGroup.usercode}'); // Corrected to 'usercode'
    print('English Translation: ${userTGroup.translations['en']}');
    print('Arabic Translation: ${userTGroup.translations['ar']}');
    print('-------------------------');
  }
  
  print('Printed all data');
}



Future<void> _loadUserGroup() async {
  try {
    var userBox = await Hive.openBox('userBox');
    
    // Retrieve user data from Hive box
    var user = userBox.get(widget.email) as Map<dynamic, dynamic>?;
print(user.toString());
print(widget.email);
    if (user != null && mounted) {
      setState(() {
        _userGroup = user['usergroup'];
        _username = user['username'];
        _userFname= user['userFname'];

      });
    } else {
      print('User not found in Hive.');
      // Handle the case when the user is not found in Hive.
    }
  
  } catch (e) {
    print('Error loading user group and username: $e');
  }

}

Future<Uint8List?> _loadProfilePicturePath() async {
  try {
    // Open the 'userBox' Hive box
    var userBox = await Hive.openBox('userBox');
    var user = userBox.get(widget.email) as Map<dynamic, dynamic>?;

    if (user != null) {
      // If there is no internet, load the image from the locally stored path
      // You might need to handle the case where the locally stored path is empty
      if (user['imageLink'].isNotEmpty) {
        if (await hasInternetConnection()) {
          // If there is internet, load the image from the online source
         String localPath = user['imageLink'];
         print('nooooo'+localPath);
          Uint8List localImageBytes = await _getImageBytes(localPath);
          print(localImageBytes);
          return localImageBytes;
        } else {
          // If there is no internet, load the image from the locally stored path
          String localPath = user['imageLink'];
          Uint8List localImageBytes = await _getLocalImageBytes(localPath);
          return localImageBytes;
        }
      }
    }

    return null;
    
  } catch (e) {
    print('Error loading profile picture path from Hive: $e');
    return null;
  }
}
Future<bool> hasInternetConnection() async {
  try {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  } catch (e) {
    print('Error checking internet connection: $e');
    return false;
  }
}

Future<Uint8List> _getLocalImageBytes(String localPath) async {
  // Use the file package to read image bytes from the local file path
  // Example: https://pub.dev/packages/file
  File file = File(localPath);
  return await file.readAsBytes();
}


Future<Uint8List> _getImageBytes(String imageUrl) async {
  http.Response response = await http.get(Uri.parse(imageUrl));
  return response.bodyBytes;
}




Future<void> _selectProfilePicture() async {
  try {
    // Show a dialog with options to select from camera or gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectprofile),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text(AppLocalizations.of(context)!.camera),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text(AppLocalizations.of(context)!.gallery),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  } catch (e) {
    print('Error selecting profile picture: $e');
    // Handle the error as needed
  }
}

Future<void> _pickImage(ImageSource source) async {
  final ImagePicker _picker = ImagePicker();
  XFile? image = await _picker.pickImage(
    source: source,
  );

  if (image != null) {
    Uint8List img = await image.readAsBytes();
    setState(() {
      _image = img;
    });

    String localPath = image.path;
    saveProfile(localPath);
  }
}

Future<bool> checkAuthorization(int menucode, int userGroup) async {
  var authorizationBox = await Hive.openBox<Authorization>('authorizationBox');

  // Use a composite key to query for authorization
  int compositeKey = _generateCompositeKey(menucode, userGroup);
  print('hi');
print(compositeKey);
  // Check if the authorization exists
  return authorizationBox.containsKey(compositeKey);
}

int _generateCompositeKey(int menucode, int groupcode) {
  // Use any logic that ensures uniqueness for your composite key
  return int.parse('$menucode$groupcode');
}




void saveProfile(String localPath) async {
  String? email = widget.email;
  String resp = await StoreData().saveData(email: email, file: _image!, localPath: localPath);

  // Save image to Firebase Storage
  String downloadURL = await StoreData().uploadImageToStorage('profileImage', _image!);

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save download URL in Firestore
  try {
    await _firestore.collection('Users').where('email', isEqualTo: email).get().then(
      (QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // Update the existing user in Firestore
          String documentId = querySnapshot.docs[0].id;
          _firestore.collection('Users').doc(documentId).update({
            'imageLink': downloadURL,
          });
        }
      },
    );
  } catch (e) {
    print('Error updating Firestore user: $e');
  }
}



 

  
  @override
  Widget build(BuildContext context) {
     final Map<String, Widget> formWidgets = {
   AppLocalizations.of(context)!.items: ItemsForm(appNotifier: widget.appNotifier,),
    AppLocalizations.of(context)!.pricelists: PriceLists(appNotifier: widget.appNotifier,),
    'Customers':CustomersForm(appNotifier:widget.appNotifier),
  };

  final Map<String, int> menuCodes = {
  AppLocalizations.of(context)!.items: Menu.ITEMS_MENU_CODE,
  AppLocalizations.of(context)!.pricelists: Menu.PRICELISTS_MENU_CODE,
  'Customers':Menu.CUSTOMERS_MENU_CODE
  // Add other menu items and their menu codes
};
final List<String> data = <String>[AppLocalizations.of(context)!.items, AppLocalizations.of(context)!.pricelists,'Customers'];

   final Map<String, IconData> iconData = {
    AppLocalizations.of(context)!.items: Icons.shopping_cart,
    AppLocalizations.of(context)!.pricelists: Icons.attach_money,
    'Customers':Icons.people_outline_outlined
  };

  String languageUser='';
         if(AppLocalizations.of(context)!.language=='English'){
languageUser=_username!;
}else{
  languageUser=_userFname!;
}
  TextStyle _appTextStyleAppBar = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
      TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
       TextStyle _SappTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble(),color: Colors.white);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(AppLocalizations.of(context)!.welcome,style: _appTextStyleAppBar,),
      ),
     drawer:Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      UserAccountsDrawerHeader(
 
        accountName: Text(languageUser,style: _appTextStyle,),
        accountEmail: Text(widget.email!,style: _appTextStyle,),
        currentAccountPicture: Stack(
          children: [
            FutureBuilder<Uint8List?>(
              future: _loadProfilePicturePath(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),);
                } else if (snapshot.hasError) {
                  return CircleAvatar(
                     radius: 80,
                    backgroundImage: NetworkImage('https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                  );
                } else if (snapshot.data != null) {
                  return CircleAvatar(
                     radius: 80,
                    backgroundImage: MemoryImage(snapshot.data!),
                  );
                } else {
                  return CircleAvatar(
                     radius: 80,
                    backgroundImage: NetworkImage('https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                  );
                }
              },
            ),
            Positioned(
              top: 40,
              left: 29,
              child: IconButton(
                onPressed: _selectProfilePicture,
                icon: Icon(Icons.add_a_photo),
                tooltip: 'Add Photo',
              ),
            ),
          ],
        ),
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text(AppLocalizations.of(context)!.settings, style: _appTextStyle),
       onTap: () async {
    // Check if the user has the required authorization
    bool hasAccess = await checkAuthorization(Menu.SETTINGS_MENU_CODE, _userGroup);

    if (hasAccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsEditUserForm(
                email: widget.email,
                password: widget.password,
                appNotifier: widget.appNotifier,
              ),
            ),
          );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.permissionAccess),
        ),
      );
    }
        },
      ),
  ListTile(
  leading: Icon(Icons.admin_panel_settings),
  title: Text(AppLocalizations.of(context)!.adminPage, style: _appTextStyle),
  onTap: () async {
    // Check if the user has the required authorization
    bool hasAccess = await checkAuthorization(Menu.ADMIN_MENU_CODE, _userGroup);

    if (hasAccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPage(appNotifier: widget.appNotifier,email: widget.email,),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.permissionAccess),
        ),
      );
    }
  },
),

      
       ListTile(
       leading: Icon(Icons.sync),
        title: Text(AppLocalizations.of(context)!.syncronize, style: _appTextStyle),
        onTap: () async {
    // Check if the user has the required authorization
    bool hasAccess = await checkAuthorization(Menu.SYNCRONIZE_MENU_CODE, _userGroup);

    if (hasAccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SynchronizeDataPage(appNotifier: widget.appNotifier,email: widget.email,),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.permissionAccess),
        ),
      );
    }
  //  if (hasAccess) {
      // bool? confirmed = await _showSyncConfirmationDialog(context);

    //  if (confirmed != null && confirmed) {
     //  _synchronizeDatatoHive();
    /*   ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.syncronized),
        ),
      );*/
   // }
   /* }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.permissionAccess),
        ),
      );
    }*/
    }
      ),
      ListTile(
        leading: Icon(Icons.logout_rounded),
        title: Text(AppLocalizations.of(context)!.logout, style: _appTextStyle),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(appNotifier: widget.appNotifier),
            ),
          );
        },
      ),
    ],
  ),
  
),
 
body: Padding(
  padding: EdgeInsets.all(8),
  child: ListView.separated(
    itemCount: data.length,
    itemBuilder: (BuildContext context, int index) {
      return ListTile(
        title: Text(data[index],style: _appTextStyle,),
        leading: Icon(iconData[data[index]]),
        onTap: () async {
          int menuCode = menuCodes[data[index]] ?? 0; // Default to 0 if menu code not found

          // Check if the user has the required authorization
          bool hasAccess = await checkAuthorization(menuCode, _userGroup);

          if (hasAccess) {
            Widget? formWidget = formWidgets[data[index]];
            if (formWidget != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => formWidget,
                ),
              );
            } else {
              // Handle the case where the widget is null
              print('Form widget is null for ${data[index]}');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.permissionAccess),
              ),
            );
          }
        },
      );
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
  ),
),

      

  );
}

Future<bool?> _showSyncConfirmationDialog(BuildContext context) async {
    TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.syncronizedata, style: _appTextStyle),
        content: Text(AppLocalizations.of(context)!.areyousuretosyncdata, style: _appTextStyle),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.no, style: _appTextStyle),
            onPressed: () {
              Navigator.of(context).pop(false); // Return false
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.yes, style: _appTextStyle),
            onPressed: () {
              Navigator.of(context).pop(true); // Return true
            },
          ),
        ],
      );
    },
  );
}


 void _synchronizeDatatoHive() async {
    try {
      // Show loading indicator or other UI feedback
      // You can use a package like `modal_progress_hud` for a loading spinner

      // Create an instance of your synchronizer class
      DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();

      // Run the synchronization process
      await synchronizer.synchronizeData();
      await synchronizer.synchronizeDataPriceLists();
      await synchronizer.synchronizeDataItemPrice();
      await synchronizer.synchronizeDataItemAttach();
      await synchronizer.synchronizeDataItemBrand();
      await synchronizer.synchronizeDataItemCateg();
      await synchronizer.synchronizeDataItemUOM();
      await synchronizer.synchronizeDataItemGroup();
      await synchronizer.synchronizeDataUserPL();
      await synchronizer.synchronizeDataUser();
      await synchronizer.synchronizeDataMenu();
      await synchronizer.synchronizeDataAuthorization();
      // Display a success message or update UI as needed

    } catch (e) {
      // Handle errors and display an error message or update UI accordingly
      print('Error synchronizing data: $e');
    } finally {
      // Hide loading indicator or perform any cleanup
    }
  }
}