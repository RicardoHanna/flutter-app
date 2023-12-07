import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
class AppNotifier with ChangeNotifier {
  Locale _userLocale;
  String _userEmail;
    int _fontSize;


  AppNotifier(this._userLocale, this._userEmail,this._fontSize);

  Locale get userLocale => _userLocale;
  int get fontSize => _fontSize;

  void updateLocale(Locale newLocale) {
    _userLocale = newLocale;
    notifyListeners();
  }

  void setUserEmail(String email) {
    _userEmail = email;
  }



Future<void> updateLang(Locale newLocale) async {
  _userLocale = newLocale;
  notifyListeners();
  _updateLanguageInDatabase(newLocale.languageCode);
}

Future<void> updateFontSize(int newSize) async {
    _fontSize = newSize;
    notifyListeners();
    _updateFontSizeInDatabase(newSize);
  }

  Future<void> _updateLanguageInDatabase(String newLanguage) async {
    try {
          var userBox = await Hive.openBox('userBox');
       dynamic userDataDynamic = userBox.get(_userEmail);
       if (userDataDynamic != null) {
      // Update the font size locally
      userDataDynamic['languages'] = newLanguage;
      await userBox.put(_userEmail, userDataDynamic);
       }
      // Query for the document with the provided email
    } catch (e) {
      print('Error updating user: $e');
    }
  }


  Future<void> _updateFontSizeInDatabase(int newSize) async {
    try {
      var userBox = await Hive.openBox('userBox');
       dynamic userDataDynamic = userBox.get(_userEmail);
       if (userDataDynamic != null) {
      // Update the font size locally
      userDataDynamic['font'] = newSize;
      await userBox.put(_userEmail, userDataDynamic);
       }

    } catch (e) {
      print('Error updating font size in the database: $e');
    }
  }
}

  

