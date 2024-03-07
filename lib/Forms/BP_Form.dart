import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/Forms/Customers_Form.dart';
import 'package:project/Forms/Items_Form.dart';
import 'package:project/Forms/Price_Lists_Form.dart';
import 'package:project/Forms/Report_Form.dart';
import 'package:project/Forms/settings_edit_user_form.dart';
import 'package:project/app_notifier.dart';
import 'package:project/Synchronize/DataSynchronizerFromFirebaseToHive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/companiesusers_hive.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/userssalesemployees_hive.dart';
import 'package:project/screens/admin_page.dart';
import 'package:project/screens/login_page.dart';
import 'package:project/screens/synchronize_data_page.dart';
import 'package:project/utils.dart';
import 'package:project/wms/Receiving_Form.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/resources/add_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/Synchronize/DataSynchronizer.dart';

class BusinessPartner extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;
  final String email;


  BusinessPartner({required this.appNotifier,required this.usercode, required this.email});

  @override
  State<BusinessPartner> createState() => _BusinessPartnerState();
}




class _BusinessPartnerState extends State<BusinessPartner> {
   int _userGroup = 0;
 String usercode = '';
 
  @override
  void initState() {
    super.initState();
loadawait();
    
  }
    Future<void> loadawait() async {
    await _loadUserGroup();
    }

 @override
Widget build(BuildContext context) {
  TextStyle _appTextStyleAppBar =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  final Map<String, Widget> formWidgets = {
    AppLocalizations.of(context)!.customers: CustomersForm(
      appNotifier: widget.appNotifier,
      userCode: widget.usercode,
    ),

    };

  final Map<String, int> menuCodes = {
     AppLocalizations.of(context)!.customers: Menu.CUSTOMERS_MENU_CODE,

    // Add other menu items and their menu codes
  };

  final List<String> data = <String>[
    AppLocalizations.of(context)!.customers,

  ];

  final Map<String, IconData> iconData = {
      AppLocalizations.of(context)!.customers: Icons.people_outline_outlined,
    
  };

  return Scaffold(
    appBar: AppBar(
        title: Text('Business Partners',style: _appTextStyle,),
    ),
     body: Padding(
      padding: EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 2, // Two cards per row
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: List.generate(data.length, (index) {
          return FutureBuilder<bool>(
            future: checkAuthorization(menuCodes[data[index]] ?? 0, _userGroup),
            builder: (context, snapshot) {
              if (snapshot.hasError || !(snapshot.data ?? false)) {
                // If there is an error or the user doesn't have access, show grey card
                return Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      data[index],
                      style: _appTextStyle.copyWith(color: Colors.grey),
                    ),
                    leading: Icon(iconData[data[index]]),
                    onTap: () {
                      Flushbar(
                        message: AppLocalizations.of(context)!.permissionAccess,
                        duration: Duration(seconds: 3),
                      )..show(context);
                    },
                  ),
                );
              } else {
                // If the user has access, show regular card
            return Card(
  elevation: 5,
  child: InkWell(
    onTap: () {
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
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        Icon(iconData[data[index]],size: 43,),
        SizedBox(height: 10),
        Text(
          data[index],
          style: _appTextStyle,
        ),
      ],
    ),
  ),
);

              }
            },
          );
        }),
      ),
    ),
  );
}


   Future<void> _loadUserGroup() async {
    try {
      var userBox = await Hive.openBox('userBox');
      var user;

      if (usercode.isEmpty) {
        // If usercode is empty, fetch data based on email
        user = userBox.values.firstWhere(
          (user) => user['email'] == widget.email,
          orElse: () => null,
        );
      } else {
        // Retrieve user data from Hive box based on usercode
        user = userBox.get(usercode) as Map<dynamic, dynamic>?;
      }

      print(user.toString());
      print(widget.email);

      if (user != null && mounted) {
        setState(() {
          _userGroup = user['usergroup'];
      
          usercode = user['usercode'];
        });
      } else {
        print('User not found in Hive.');
        // Handle the case when the user is not found in Hive.
      }
    } catch (e) {
      print('Error loading user group and username: $e');
    }
  }
Future<bool> checkAuthorization(int menucode, int userGroup) async {
    if (userGroup == 1) {
      // if is admin

      return true;
    } else {
      var authorizationBox =
          await Hive.openBox<Authorization>('authorizationBox');

      // Use a composite key to query for authorization
      int compositeKey = _generateCompositeKey(menucode, userGroup);
      print('hi');
      print(compositeKey);
      // Check if the authorization exists
      return authorizationBox.containsKey(compositeKey);
    }
  }

  int _generateCompositeKey(int menucode, int groupcode) {
    // Use any logic that ensures uniqueness for your composite key
    return int.parse('$menucode$groupcode');
  }
 
}
