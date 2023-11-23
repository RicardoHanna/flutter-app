import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class AppNotifier with ChangeNotifier {
  Locale _userLocale;
  String _userEmail;

  AppNotifier(this._userLocale, this._userEmail);

  Locale get userLocale => _userLocale;

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



  Future<void> _updateLanguageInDatabase(String newLanguage) async {
    try {
      // Query for the document with the provided email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: _userEmail)
          .get();

      // Check if the document exists
      if (querySnapshot.docs.isNotEmpty) {
        // Update the document with the new values
        await querySnapshot.docs.first.reference.update({
          'languages': newLanguage,
        });
      } else {
        print('Document with email $_userEmail not found.');
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }
}
