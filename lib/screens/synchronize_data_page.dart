import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Forms/Import_Form.dart';
import 'package:project/Synchronize/DataSynchronizer.dart';
import 'package:project/app_notifier.dart';
import 'package:project/classes/TranslationsClass.dart';
import 'package:project/classes/UserClass.dart';
import 'package:project/Forms/edit_user_form.dart';
import 'package:project/Forms/user_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/syncronizesubmenu_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/screens/admin_users_page.dart';

class SynchronizeDataPage extends StatefulWidget {
    final AppNotifier appNotifier;
    final String email;
   SynchronizeDataPage({required this.appNotifier,required this.email});

  @override
  _SynchronizeDataPageState createState() => _SynchronizeDataPageState();
}

class _SynchronizeDataPageState extends State<SynchronizeDataPage> {
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



@override
  Widget build(BuildContext context) {
      TextStyle   _appTextStyle = TextStyle(fontSize:widget.appNotifier.fontSize.toDouble());

    final List<String> data = <String>['Import','Export'];
  

   final Map<String, IconData> iconData = {
    'Import': Icons.import_export,
   'Export': Icons.sync,
 
  };

    final Map<String, int> menuCodes = {

    'Export': SynchronizeSubMenu.EXPORT_MENU_CODE,

 
};

     _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text('Synchronize Data',style: _appTextStyle),
      ),
    body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.separated(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(data[index], style: _appTextStyle),
              leading: Icon(iconData[data[index]]),
              onTap: () async {
                if (data[index] == 'Import') {
    
                    // Handle the case when the user has access
                 
                  // Show the import dialog
                  String importSource = await _showImportDialog();
                  print('Selected Import Source: $importSource');

                  // Redirect to ImportForm based on the selected import source
                  if (importSource == 'Import from ERP to Mobile') {

                               int menuCode =  SynchronizeSubMenu.IMPORT_FROM_ERP_MENU_CODE ?? 0;
                     bool hasAccess = await checkAuthorization(menuCode, _userGroup);
print(menuCode);
                     if(hasAccess){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImportForm(
                          appNotifier: widget.appNotifier,
                          email: widget.email,
                          title: 'Import from ERP To Mobile',
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
                  } else if (importSource == 'Import from Backend to Mobile') {
                     int menuCode = SynchronizeSubMenu.IMPORT_FROM_BACKEND_MENU_CODE ?? 0;
                     print(menuCode);
                     print(_userGroup);
                     bool hasAccess = await checkAuthorization(menuCode, _userGroup);

                    if(hasAccess){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImportForm(
                          appNotifier: widget.appNotifier,
                          email: widget.email,
                          title: 'Import from Backend to Mobile',
                        ),
                      ),
                    );
                     
                    } else{
                             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.permissionAccess),
              ),
            );
                     }
                  }
                   
                } else {
                   int menuCode = menuCodes[data[index]] ?? 0;
                   print(menuCode);
                     bool hasAccess = await checkAuthorization(menuCode, _userGroup);

                 if (hasAccess) {
                  // Handle other actions as before
              String exportSource = await _showExportDialog();
              if(exportSource=='Yes'){
 
  await _synchronizeData();
      ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Data is Exported!',style: _appTextStyle,),
              ),
            );
              }else{
              }

              }
              else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.permissionAccess),
                      ),
                    );
                  }
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

 Future<void> _synchronizeData() async {
    DataSynchronizer dataSynchronizer = DataSynchronizer();
    await dataSynchronizer.synchronizeData();


  }

Future<dynamic> _showImportDialog() async {
     TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Import Source',style:_appTextStyle ,),
        content: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Import from ERP to Mobile');
              },
              style: TextButton.styleFrom(
              //  primary: Colors.blue, // Choose a consistent color
              ),
              child: Text('Import from ERP to Mobile',style: _appTextStyle,),
            ),
            SizedBox(height: 10,),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Import from Backend to Mobile');
              },
              style: TextButton.styleFrom(
                primary: Colors.blue, // Choose a consistent color
              ),
              child: Text('Import from Backend to Mobile',style: _appTextStyle,),
            ),
          ],
        ),
      );
    },
  );
}



Future<dynamic> _showExportDialog() async {
       TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure to want to export all data?'),
          content: Padding(
            padding: EdgeInsets.only(left: 15,right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Yes');
                  },
                  child: Text('Yes',style: _appTextStyle,),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'No');
                    },
                    child: Text('No',style: _appTextStyle,),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

