import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:project/screens/admin_authorizations_page.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:project/screens/admin_usersgroup_page.dart';
import 'package:project/screens/general_settings_page.dart';

class AdminPage extends StatefulWidget {
    final AppNotifier appNotifier;
    final String email;
   AdminPage({required this.appNotifier,required this.email});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
   @override
void initState() {
  super.initState();
 
  _loadUserGroup();

}
   int _userGroup=0;
Future<void> _loadUserGroup() async {
  print(widget.email);
  try {
    var userBox = await Hive.openBox('userBox');
    
    // Retrieve user data from Hive box
    var user = userBox.get(widget.email) as Map<dynamic, dynamic>?;
print(user.toString());
print(widget.email);
    if (user != null && mounted) {
      setState(() {
        _userGroup = user['usergroup'];
      });
    } else {
      print('User not found in Hive.');
      // Handle the case when the user is not found in Hive.
    }
  
  } catch (e) {
    print('Error loading user group and username: $e');
  }

}
  TextStyle _appTextStyle=TextStyle();

 @override
  Widget build(BuildContext context) {
      TextStyle   _appTextStyle = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble());

    final List<String> data = <String>[AppLocalizations.of(context)!.adminusers, AppLocalizations.of(context)!.adminusergroup,AppLocalizations.of(context)!.authorizations,AppLocalizations.of(context)!.generalSettings];

   final Map<String, IconData> iconData = {
    AppLocalizations.of(context)!.adminusers: Icons.people,
AppLocalizations.of(context)!.adminusergroup: Icons.groups_2,
   AppLocalizations.of(context)!.authorizations : Icons.security_outlined,
   AppLocalizations.of(context)!.generalSettings: Icons.settings_accessibility
   
  };

    final Map<String, int> menuCodes = {
    AppLocalizations.of(context)!.adminusers: AdminSubMenu.ADMIN_USERS_MENU_CODE,
AppLocalizations.of(context)!.adminusergroup: AdminSubMenu.SETTINGS_USERSGROUP_MENU_CODE,
AppLocalizations.of(context)!.authorizations: AdminSubMenu.AUTHORIZATIONS_MENU_CODE,
    AppLocalizations.of(context)!.generalSettings: AdminSubMenu.GENERAL_SETTINGS_MENU_CODE
};

    final Map<String, Widget> formWidgets = {
    AppLocalizations.of(context)!.adminusers: AdminUsersPage(appNotifier: widget.appNotifier,),
AppLocalizations.of(context)!.adminusergroup: AdminUsersGroupPage(appNotifier: widget.appNotifier,),
AppLocalizations.of(context)!.authorizations: AdminAuthorizationsPage(appNotifier: widget.appNotifier,),
AppLocalizations.of(context)!.generalSettings: GeneralSettings(appNotifier: widget.appNotifier),
  };
     _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.adminPage,style: _appTextStyle),
      ),
      body: Padding(
  padding: EdgeInsets.all(8),
  child: ListView.separated(
    itemCount: data.length,
    itemBuilder: (BuildContext context, int index) {
      return ListTile(
        title: Text(data[index],style: _appTextStyle,),
        leading: Icon(iconData[data[index]]),
        onTap: () async{
          int menuCode = menuCodes[data[index]] ?? 0; // Default to 0 if menu code not found
         print(menuCode);
         print(_userGroup);
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
          }else {
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
  Future<bool> checkAuthorization(int groupcode, int userGroup) async {
  var authorizationBox = await Hive.openBox<Authorization>('authorizationBox');

  // Use a composite key to query for authorization
  int compositeKey = _generateCompositeKey(groupcode, userGroup);

  // Check if the authorization exists
  return authorizationBox.containsKey(compositeKey);
}

int _generateCompositeKey(int menucode, int groupcode) {
  // Use any logic that ensures uniqueness for your composite key
  return int.parse('$menucode$groupcode');
}

}