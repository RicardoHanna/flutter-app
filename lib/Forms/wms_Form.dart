import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'dart:ui'; // Import dart:ui for accessing AssetImage

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

class WMS extends StatefulWidget {
  final AppNotifier appNotifier;
  final String usercode;


  WMS({required this.appNotifier, required this.usercode});

  @override
  State<WMS> createState() => _WMSState();
}

class _WMSState extends State<WMS> {
  int _userGroup = 0;
  String usercode = '';
String apiurl='http://5.189.188.139:8080/api/';

  @override
  void initState() {
    super.initState();
    loadawait();
  }

  Future<void> loadawait() async {
    await _loadUserGroup();
  }

  @override
  @override
  Widget build(BuildContext context) {
    TextStyle _appTextStyleAppBar =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());
    TextStyle _appTextStyle =
        TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());

    return Scaffold(
      appBar: AppBar(
        title: Text('WMS', style: _appTextStyle),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            _buildWMSOption(
               imagePath:
                  'lib/icons/wms/wms_receive.png', // Path to your picking icon
              label: 'Receiving',
              onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceivingScreen(
                          appNotifier: widget.appNotifier,
                       usercode: widget.usercode,
                       
                      ),
                    ),
                  );
              },
            ),
            _buildWMSOption(
              imagePath:
                  'lib/icons/wms/wms_picking.png', // Path to your picking icon
                  
              label: 'Picking',
              onTap: () {
                    
              },
            ),
            _buildWMSOption(
              imagePath:
                  'lib/icons/wms/wms_putaway.png', // Path to your picking icon
              label: 'Put Away',
              onTap: () {
                   
                
              },
            ),
               _buildWMSOption(
              imagePath:
                  'lib/icons/wms/wms_packing.png', // Path to your picking icon
              label: 'Packing',
              onTap: () {
                // Handle put away option onTap event
              },
            ),
            _buildWMSOption(
              imagePath:
                  'lib/icons/wms/wms_transactions.png', // Path to your picking icon
              label: 'Transactions',
              onTap: () {
                // Handle put away option onTap event
              },
            ),
            _buildWMSOption(
              imagePath:
                  'lib/icons/wms/wms_cycle.png', // Path to your picking icon
              label: 'Cycle',
              onTap: () {
                // Handle put away option onTap event
              },
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildWMSOption(
  {required String imagePath,
  required String label,
  required VoidCallback onTap}) {
return InkWell(
  onTap: () async {
    bool authorized = await checkAuthorizationForLabel(label);
    if (authorized) {
      onTap();
    } else {
      Flushbar(
        message: 'You do not have permission to access $label.',
        duration: Duration(seconds: 3),
      )..show(context);
    }
  },
    child: Card(
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 50, // Adjust the width according to your icon size
            height: 50, // Adjust the height according to your icon size
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    ),
  );
}

Future<bool> checkAuthorizationForLabel(String label) async {
  // Perform authorization check based on the label
  int menucode = getMenuCodeForLabel(label);
  return await checkAuthorization(menucode, _userGroup);
}

int getMenuCodeForLabel(String label) {
  // Implement logic to map label to menu code
  switch (label) {
    case 'Receiving':
      return Menu.RECEIVE_MENU_CODE;
    case 'Picking':
      return Menu.PICKING_MENU_CODE;
    case 'Put Away':
      return Menu.PUTAWAY_MENU_CODE;
    case 'Packing':
      return Menu.PACKING_MENU_CODE;
    case 'Transactions':
      return Menu.TRANSACTIONS_MENU_CODE;
    case 'Cycle':
      return Menu.CYCLE_MENU_CODE;
    default:
      return 0;
  }
}


  Future<void> _loadUserGroup() async {
    try {
      var userBox = await Hive.openBox('userBox');
      var user;

      if (usercode.isEmpty) {
        // If usercode is empty, fetch data based on email
        user = userBox.values.firstWhere(
          (user) => user['usercode'] == widget.usercode,
          orElse: () => null,
        );
      } else {
        // Retrieve user data from Hive box based on usercode
        user = userBox.get(usercode) as Map<dynamic, dynamic>?;
      }

      print(user.toString());
      //print(widget.email);

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
    // Return true for admin user
    return true;
  } else {
    try {
      // Fetch authorization data from the API
      final authorizationData = await fetchAuthorizationData();
      // Generate composite key for the menucode and userGroup
      int compositeKey = _generateCompositeKey(menucode, userGroup);
      print('ccc');
      print(authorizationData.toString());
      print('ssd');
      print(compositeKey);

      if (authorizationData is Map) {
        // Check if the authorization data is a map
        print('@@@@@@@@@@@');
        return authorizationData.containsKey(compositeKey) && authorizationData[compositeKey]!;
      } else if (authorizationData is List) {
        // Check if the authorization data is a list
        print('################');
        // Iterate over the list to check each map for the compositeKey
        for (var item in authorizationData) {
          if (item['menucode'] == menucode && item['groupcode'] == userGroup) {
            return true; // Found matching compositeKey in the list
          }
        }
        return false; // Did not find matching compositeKey in the list
      } else {
        // Handle unexpected data format
        print('Unexpected authorization data format');
        return false;
      }
    } catch (e) {
      // Handle exceptions
      print('Error checking authorization: $e');
      return false;
    }
  }
}


Future<dynamic> fetchAuthorizationData() async {
  try {
    final response = await http.get(Uri.parse('${apiurl}getAuthorization'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        // If data is a list, return the list itself
        return data;
      } else {
        // Parse the response data and return it as a Map<int, bool>
        // Format: {compositeKey: authorizationValue}
        return Map<int, bool>.from(data);
      }
    } else {
      // Handle unsuccessful HTTP response
      print('Failed to fetch authorization data: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    // Handle exceptions during HTTP request
    print('Error fetching authorization data: $e');
    return null;
  }
}


  int _generateCompositeKey(int menucode, int groupcode) {
    // Use any logic that ensures uniqueness for your composite key
    return int.parse('$menucode$groupcode');
  }

  
}
