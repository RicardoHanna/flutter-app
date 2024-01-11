import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Synchronize/DataSynchronizerFromFirebaseToHive.dart';
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
import 'package:process/process.dart';
import 'package:http/http.dart' as http;

class ImportForm extends StatefulWidget {
  final AppNotifier appNotifier;
  final String email;
  final String title;

  ImportForm({required this.appNotifier, required this.email, required this.title});

  @override
  _ImportFormState createState() => _ImportFormState();
}

class _ImportFormState extends State<ImportForm> {
  // Track the selected checkboxes
  



final String serverUrl = 'https://apimyapp.onrender.com';
final int userGroupCode = 1;

Future<void> importData() async {
  final response = await http.post(
    Uri.parse('$serverUrl/importData'),
    headers: {'Content-Type': 'application/json'}, // Set content-type to application/json
    body: jsonEncode({'userGroupCode': userGroupCode}), // Encode the body as JSON
  );

  if (response.statusCode == 200) {
    print('Data migration complete');
  } else {
    print('Failed to import data. Status code: ${response.statusCode}');
  }
}




  bool _importItems = false;
  bool _importPriceLists = false;
  bool _importSystem = false;

  bool _selectAll = false;
bool _loading = false; // Track loading state
 @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _buildSwitchList().length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return SwitchListTile(
                title: Text('Select All', style: _appTextStyle),
                value: _selectAll,
                onChanged: (value) {
                  setState(() {
                    _selectAll = value ?? false;
                    _importItems = _selectAll;
                    _importPriceLists = _selectAll;
                    _importSystem = _selectAll;
                  });
                },
              );
            } else {
              return _buildSwitchList()[index - 1];
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildSwitchList() {
    TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    if (widget.title == 'Import from ERP To Mobile') {
      return [
        SwitchListTile(
          title: Text('Items', style: _appTextStyle),
          value: _importItems,
          onChanged: (value) {
            setState(() {
              _importItems = value ?? false;
            });
          },
        ),
        SwitchListTile(
          title: Text('PriceLists', style: _appTextStyle),
          value: _importPriceLists,
          onChanged: (value) {
            setState(() {
              _importPriceLists = value ?? false;
            });
          },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await importData();
          },
          child: Text('Import'),
        ),
      ];
    } else if (widget.title == 'Import from Backend to Mobile') {
      return [
        SwitchListTile(
          title: Text('Items', style: _appTextStyle),
          value: _importItems,
          onChanged: (value) {
            setState(() {
              _importItems = value ?? false;
            });
          },
        ),
        SwitchListTile(
          title: Text('PriceLists', style: _appTextStyle),
          value: _importPriceLists,
          onChanged: (value) {
            setState(() {
              _importPriceLists = value ?? false;
            });
          },
        ),
        SwitchListTile(
          title: Text('System', style: _appTextStyle),
          value: _importSystem,
          onChanged: (value) {
            setState(() {
              _importSystem = value ?? false;
            });
          },
        ),
        ElevatedButton(
          onPressed: () async {
            await _synchronizeAll();
          },
          child: Text('Import', style: _appTextStyle),
        ),
      ];
    }
    return [];
  }

   Future<void> _synchronizeAll() async {

     if(_selectAll){
      await _synchronizeDatatoHive();
    }else{
    // Synchronize all selected options
    if (_importItems) {
      await _synchronizeItems();
    }

    if (_importPriceLists) {
      await _synchronizePriceLists();
    }

    if (_importSystem) {
      await _synchronizeSystem();
    }


    }
  }
 Future<void> _synchronizeItems() async {
    TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
   DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
    await synchronizer.synchronizeData();
    await synchronizer.synchronizeDataItemAttach();
    await synchronizer.synchronizeDataItemBrand();
    await synchronizer.synchronizeDataItemCateg();
    await synchronizer.synchronizeDataItemGroup();
    await synchronizer.synchronizeDataItemPrice();
    await synchronizer.synchronizeDataItemUOM();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Items synchronized successfully',style: _appTextStyle,),
      ),
    );
    print('Items synchronized successfully');
  }

  Future<void> _synchronizePriceLists() async {
      TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
    await synchronizer.synchronizeDataPriceLists();
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PriceLists synchronized successfully',style: _appTextStyle,),
      ),
    );
    print('PriceLists synchronized successfully');
  }

  Future<void> _synchronizeSystem() async {
      TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
     DataSynchronizerFromFirebaseToHive synchronizer = DataSynchronizerFromFirebaseToHive();
    await synchronizer.synchronizeDataUser();
     await synchronizer.synchronizeDataUserGroup();
      await synchronizer.synchronizeDataUserGroupTranslations();
      await synchronizer.synchronizeDataAuthorization();
        await synchronizer.synchronizeDataMenu();
        await synchronizer.synchronizeDataGeneralSettings();
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('System synchronized successfully',style: _appTextStyle,),
      ),
    );
    print('System synchronized successfully');
  }



Future<void> _synchronizeDatatoHive() async {
    TextStyle   _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
  try {
    // Set loading state to true before starting synchronization
    setState(() {
      _loading = true;
    });

    // Your existing synchronization logic
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
    await synchronizer.synchronizeDataUserGroup();
    await synchronizer.synchronizeDataUserGroupTranslations();

    // Simulate a delay for demonstration purposes (remove in production)
    await Future.delayed(Duration(seconds: 3));

    // Display a success message or update UI as needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data synchronized successfully',style: _appTextStyle,),
      ),
    );
  } catch (e) {
    // Handle errors and display an error message or update UI accordingly
    print('Error synchronizing data: $e');
  } finally {
    // Set loading state to false after synchronization
    setState(() {
      _loading = false;
    });
  }
}

// Add this function to show a loading indicator using FutureBuilder
Widget _buildLoadingIndicator() {
  return Center(
    child: CircularProgressIndicator(),
  );
}
}