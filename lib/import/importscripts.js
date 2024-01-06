const admin = require('firebase-admin');
const { Storage } = require('@google-cloud/storage');
const csv = require('csv-parser');
const fs = require('fs');
const sql = require('mssql/msnodesqlv8');

// Initialize Firebase Admin SDK
const serviceAccount = require('C:/Users/ricardo/Downloads/sales-bab47-firebase-adminsdk-gqqph-a89e060434.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://sales-bab47.firebaseio.com', // Update with your actual database URL
});

// Initialize Firebase Storage
const storage = admin.storage();
const bucket = storage.bucket('sales-bab47.appspot.com');

// Firebase Storage file path
const storageFilePath = 'Items_Data.csv';

// Configuration for SQL Server connection
var sqlConfig = {

  server : "DESKTOP-3J3L4AJ\\SQLEXPRESS01", // eg:: 'DESKTOP_mjsi\\MSSQLEXPRESS'
 database: "Sales",

options :{
  trustedConnection:true,
},
driver:"msnodesqlv8",
}




// Download CSV file and upload data to Firebase
const file = bucket.file(storageFilePath);

// Connect to SQL Server and fetch data
sql.connect(sqlConfig)
  .then(() => {
    return new sql.Request().query('SELECT * FROM Items');
  })
  .then(result => {
    const rows = result.recordset;

    // Upload each row to the 'Items' collection with automatically generated document ID
    const itemsCollection = admin.firestore().collection('Items');

    rows.forEach(row => {
      itemsCollection.add(row)
        .then((docRef) => {
          console.log(`Document added with ID: ${docRef.id}`);
        })
        .catch((error) => {
          console.error('Error adding document:', error);
        });
    });

    console.log('Data migration complete.');
  })
  .catch(err => {
    console.error('Error connecting to SQL Server:', err);
  });
