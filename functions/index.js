// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.syncUserToHive = functions.firestore
  .document('Users/{userId}')
  .onCreate((snap, context) => {
    const userData = snap.data();

    const hiveUser = {
      username: userData.username,
      email: userData.email,
      password: userData.password,
      phonenumber: userData.phonenumber,
      imeicode: userData.imeicode,
      warehouse: userData.warehouse,
      active: userData.active,
      imageLink: userData.imageLink,
      usergroup: userData.usergroup,
      languages: userData.languages,
      font: userData.font,
    };

    const userBox = admin.firestore().collection('userBox');
    userBox.put(email,hiveUser);

    return null;
  });
