import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project/app_notifier.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:project/Forms/settings_edit_user_form.dart';
import 'package:project/classes/UserClass.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final String email;
  final String password;
    final AppNotifier appNotifier;
   
  
  SettingsPage({required this.email,required this.password,required this.appNotifier});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'English';
  int _selectedFont = 16;
  late TextStyle _appTextStyle;

  @override
  void initState() {
    super.initState();
 if(_selectedLanguage=='Arabic') _selectedLanguage='عربي';
    _appTextStyle = TextStyle(fontSize: _selectedFont.toDouble());
    // Load user preferences when the widget is created
    _loadUserPreferences();

  }


  void _loadUserPreferences() async {
String userLanguage='';
 int userFont=0 ;
    var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
var userBox = await Hive.openBox('userBox');
       dynamic userDataDynamic = userBox.get(widget.email);
       if (userDataDynamic != null) {
      // Update the font size locally
   userLanguage  =  userDataDynamic['languages'] ?? _selectedLanguage;
  userFont=  userDataDynamic['font']?? _selectedFont;

       }

  }
    try {
       if (connectivityResult != ConnectivityResult.none) {
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
         userFont = userDocument['font'] ?? _selectedFont;
         userLanguage = userDocument['languages'] ?? _selectedLanguage;
      }
       }
if(userLanguage=='Arabic') userLanguage='عربي';

        // Update the state with the user's preferences
        setState(() {
          _selectedFont = userFont;
          _selectedLanguage = userLanguage;
          _appTextStyle = TextStyle(fontSize: _selectedFont.toDouble());
        });
        print(_selectedLanguage);
      
    } catch (e) {
      print('Error loading user preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
        TextStyle _appTextStyle = TextStyle(fontSize: widget.appNotifier.fontSize.toDouble());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings,style: _appTextStyle),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(AppLocalizations.of(context)!.common,style: _appTextStyle),
            tiles: [
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.languages,style: _appTextStyle),
                value: Text(_selectedLanguage, style: _appTextStyle),
                leading: Icon(Icons.language),
                onPressed: (context) => _showLanguageDialog(context),
              ),
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.font, style: _appTextStyle),
                value: Text(
  '${AppLocalizations.of(context)!.font}: $_selectedFont',
  style: _appTextStyle,
),

                leading: Icon(Icons.font_download),
                onPressed: (context) => _showFontDialog(context),
              ),
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.account, style: _appTextStyle),
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
    if(_selectedLanguage=='Arabic') _selectedLanguage='عربي';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language', style: _appTextStyle),
          content: DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) async {
              if (_selectedLanguage != newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });

                Navigator.of(context).pop();
if(newValue=='عربي') newValue='Arabic';
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
            items: ['English', 'عربي'].map((String userLang) {
              return DropdownMenuItem<String>(
                value: userLang,
                child: Text(userLang,style: _appTextStyle),
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
          title: Text(AppLocalizations.of(context)!.selectFont, style: _appTextStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                style: _appTextStyle,
                controller: TextEditingController(text: _selectedFont.toString()),
                onChanged: (String value) {
                  setState(() {
                    _selectedFont = int.tryParse(value) ?? _selectedFont;
                    if (_selectedFont > 30) {
                      _selectedFont = 30;
                    } else if (_selectedFont < 1) {
                      _selectedFont = 1;
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Provider.of<AppNotifier>(context, listen: false).setUserEmail(widget.email);

                await Provider.of<AppNotifier>(context, listen: false)
                    .updateFontSize(_selectedFont);

                setState(() {
                  _appTextStyle = TextStyle(fontSize: _selectedFont.toDouble());
                });
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }

  void _showAccountSettings(BuildContext context) {
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
  }
}
