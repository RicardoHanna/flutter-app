import 'package:flutter/material.dart';

bool isValidEmail(String email) {
  // Implement email validation logic as needed
  RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  return emailRegExp.hasMatch(email);
}

  bool isValidPassword(String password) {
    // Implement password validation logic as needed
    return password.length > 5;
  }

  bool isValidPhoneNumber(String phoneNumber) {
  // Implement phone number validation logic as needed
  RegExp phoneRegExp = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
  return phoneRegExp.hasMatch(phoneNumber);
}
