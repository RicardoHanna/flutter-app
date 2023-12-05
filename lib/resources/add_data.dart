import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

Future<String> saveData({required String email, required Uint8List file}) async {
  String resp = "Some Error Occurred";
  try {
    if(email.isNotEmpty){
    String imageUrl = await uploadImageToStorage('profileImage', file);
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming there is only one document with the given email
      String documentId = querySnapshot.docs[0].id;

      await _firestore.collection('Users').doc(documentId).update({
        'imageLink': imageUrl,
      });

      resp = 'success';
    } else {
      resp = 'User not found'; // Handle the case where the user with the given email is not found.
    }
  }
  } catch (err) {
    resp = err.toString();
  }
  return resp;
}


}