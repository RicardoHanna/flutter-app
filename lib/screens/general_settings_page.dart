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

class GeneralSettings extends StatefulWidget {
    final AppNotifier appNotifier;

   GeneralSettings({required this.appNotifier});

  @override
  _GeneralSettingsState createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {

  @override
void initState() {
  super.initState();
 
}

  
 @override
  Widget build(BuildContext context) {
     TextStyle   _appTextStyle = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble());
return Scaffold(
 appBar: AppBar(
        title: Text('General Settings',style: _appTextStyle),
      ),
      
);

  }






}


