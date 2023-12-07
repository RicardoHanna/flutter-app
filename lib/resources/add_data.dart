import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:project/hive/hiveuser.dart';

final FirebaseStorage _storage=FirebaseStorage.instance;
final FirebaseFirestore _firestore=FirebaseFirestore.instance;

class StoreData{

Future<String> uploadImageToStorage(String childName,Uint8List file) async{

  Reference ref = _storage.ref().child(childName);

  UploadTask uploadTask = ref.putData(file);

  TaskSnapshot snapshot = await uploadTask;

 String downloadUrl = await snapshot.ref.getDownloadURL();
 return downloadUrl;

}

  Future<String> saveData({required String email, required Uint8List file, required String localPath}) async {
  String resp = "Some Error Occurred";
  try {
    print('hi');
    if (email.isNotEmpty) {
    //  String imageUrl = await uploadImageToStorage('profileImage', file);
      print('mno');
      // Open the 'userBox' Hive box
      var userBox = await Hive.box('userBox');

      var existingUser = userBox.get(email) as Map<dynamic, dynamic>?;

      if (existingUser != null) {
        // Update both the online and local paths in the user object
       
        existingUser['imageLink'] = localPath;

        // Put the updated user back into the Hive box
        userBox.put(email, existingUser);
        print('hello');
        resp = 'success';
      } else {
        resp = 'User not found';
      }
    }
  } catch (err) {
    resp = err.toString();
  }
  return resp;
}


}


