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
import 'package:project/screens/admin_authorizations_page.dart';
import 'package:project/screens/admin_users_page.dart';
import 'package:project/screens/admin_usersgroup_page.dart';

class AdminPage extends StatefulWidget {
    final AppNotifier appNotifier;
   AdminPage({required this.appNotifier});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  TextStyle _appTextStyle=TextStyle();

 @override
  Widget build(BuildContext context) {
    final List<String> data = <String>['Admin Users', 'Admin User Group','Authorizations'];

   final Map<String, IconData> iconData = {
    'Admin Users': Icons.people,
    'Admin User Group': Icons.groups_2,
    'Authorizations' : Icons.security_outlined
  };

    final Map<String, Widget> formWidgets = {
    'Admin Users': AdminUsersPage(appNotifier: widget.appNotifier,),
    'Admin User Group': AdminUsersGroupPage(appNotifier: widget.appNotifier,),
     'Authorizations': AdminAuthorizationsPage(appNotifier: widget.appNotifier,),
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
        title: Text(data[index]),
        leading: Icon(iconData[data[index]]),
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
      );
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
  ),
),


    );

  }

}