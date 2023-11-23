import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/app_notifier.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:project/Forms/settings_edit_user_form.dart';
import 'package:project/classes/UserClass.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final String email;
  final String password;
  
  SettingsPage({required this.email,required this.password});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'English';
  int _selectedFont = 16;

 @override
  void initState() {
    super.initState();
    // Load user preferences when the widget is created
    _loadUserPreferences();
  }

  void _loadUserPreferences() async {
    try {
      // Query the 'Users' collection using the provided email and password
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: widget.email)
          .where('password', isEqualTo: widget.password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Retrieve the user's document
        var userDocument = querySnapshot.docs.first.data() as Map<String, dynamic>;

        // Extract font and language values
        int userFont = userDocument['font'] ?? _selectedFont;
        String userLanguage = userDocument['languages'] ?? _selectedLanguage;

        // Update the state with the user's preferences
        setState(() {
          _selectedFont = userFont;
          _selectedLanguage = userLanguage;
        });
      }
    } catch (e) {
      print('Error loading user preferences: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Common'),
            tiles: [
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.languages),
                value: Text(_selectedLanguage),
                leading: Icon(Icons.language),
                onPressed: (context) => _showLanguageDialog(context),
              ),
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.font),
                value: Text('Font Size: $_selectedFont'),
                leading: Icon(Icons.font_download),
                onPressed: (context) => _showFontDialog(context),
              ),
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.account),
                leading: Icon(Icons.account_box),
                onPressed: (context) => _showAccountSettings(context),
              ),
              
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Language'),
        content: DropdownButton<String>(
          value: _selectedLanguage,
          onChanged: (String? newValue) async {
            if (_selectedLanguage != newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });

              Navigator.of(context).pop();

              // Update the language in the database
              Provider.of<AppNotifier>(context, listen: false).setUserEmail(widget.email);
              await Provider.of<AppNotifier>(context, listen: false).updateLang(Locale(newValue!));

              // Set the user locale after updating the language
              if (_selectedLanguage == 'English') {
                Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('en'));
              } else {
                Provider.of<AppNotifier>(context, listen: false).updateLocale(Locale('ar'));
              }
            }
          },
          items: ['English', 'Arabic'].map((String userLang) {
            return DropdownMenuItem<String>(
              value: userLang,
              child: Text(userLang),
            );
          }).toList(),
        ),
      );
    },
  );
}

void _showFontDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectFont),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: _selectedFont.toString()),
              onChanged: (String value) {
                setState(() {
                  _selectedFont = int.tryParse(value) ?? _selectedFont;
                  if (_selectedFont > 30) {
                    _selectedFont = 30;
                  } else if (_selectedFont < 10) {
                    _selectedFont = 10;
                  }
                });
              },
            ),
       
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Additional actions on font change if needed
            },
            child: Text(AppLocalizations.of(context)!.submit),
          ),
        ],
      );
    },
  );
}


  void _showAccountSettings(BuildContext context) {
 Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  SettingsEditUserForm(
email: widget.email,password: widget.password,
                  ),
                  ));
  }
}
