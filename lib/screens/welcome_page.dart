import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/app_notifier.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/utils.dart';
import 'package:project/screens/admin_page.dart';
import 'settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/resources/add_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/usergroup_hive.dart';



class welcomePage extends StatefulWidget {
  final String email;
  final String password;
  final AppNotifier appNotifier;
  welcomePage({required this.email,required this.password, required this.appNotifier});

  @override
  State<welcomePage> createState() => _welcomePageState();
}

class _welcomePageState extends State<welcomePage> {
  late String _profilePicturePath='';
Uint8List ? _image;
String ?_image1;
 int? _userGroup;
 String ? _username;
   @override
  void initState() {
    super.initState();
    loadUserGroupHive();
  }

  Future<void> loadUserGroupHive() async {
    await Hive.initFlutter();
    await printUserDataTranslations();
  }

 /*Future<void> insertUsers() async {


    var userTranslationsBox = await Hive.openBox('translationsBox');

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
  }*/

 

Future<void> printUserDataTranslations() async {
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
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: widget.email)
        .where('password', isEqualTo: widget.password)
        .get()
        .then((QuerySnapshot querySnapshot) => querySnapshot.docs.first);

   setState(() {
          _userGroup = userDoc.get('usergroup');
          _username = userDoc.get('username');
        });
   
  } catch (e) {
    print('Error loading profile picture path: $e');
    return null;
  }
}



 Future<Uint8List?> _loadProfilePicturePath() async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: widget.email)
        .where('password', isEqualTo: widget.password)
        .get()
        .then((QuerySnapshot querySnapshot) => querySnapshot.docs.first);

    String imageLink = userDoc.get('imageLink');
  
    if (imageLink.isNotEmpty) {
      Uint8List imageBytes = await _getImageBytes(imageLink);
      return imageBytes;
    } else {
      return null;
    }
  } catch (e) {
    print('Error loading profile picture path: $e');
    return null;
  }
}

Future<Uint8List> _getImageBytes(String imageUrl) async {
  http.Response response = await http.get(Uri.parse(imageUrl));
  return response.bodyBytes;
}

  Future<void> _selectProfilePicture() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image=img;
    });
    saveProfile();
  }

void saveProfile() async{
  String _email=widget.email;
 String resp=await StoreData().saveData(email:_email , file: _image!);
}


  
  @override
  Widget build(BuildContext context) {
      TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
       TextStyle _SappTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble(),color: Colors.white);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(AppLocalizations.of(context)!.welcome,style: _appTextStyle,),
      ),
     drawer:Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      UserAccountsDrawerHeader(
        accountName: Text('$_username'),
        accountEmail: Text(widget.email),
        currentAccountPicture: Stack(
          children: [
            FutureBuilder<Uint8List?>(
              future: _loadProfilePicturePath(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(
                email: widget.email,
                password: widget.password,
                appNotifier: widget.appNotifier,
              ),
            ),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.admin_panel_settings),
        title: Text(AppLocalizations.of(context)!.adminPage, style: _appTextStyle),
        onTap: () {
          if (_userGroup == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminPage(appNotifier: widget.appNotifier),
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
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your welcome page content goes here',
                style: _appTextStyle,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
      
}