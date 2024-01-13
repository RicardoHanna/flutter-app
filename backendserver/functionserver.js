const admin = require('firebase-admin');
const sql = require('mssql');

const path = require('path');

const serviceAccount = require('./firebasesdk.json');




// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://sales-bab47.firebaseio.com', // Update with your actual database URL
});

async function importDataToFirestore(userGroupCode) {
  try {
    // Fetch user configuration from Firestore based on user's group code
    const configSnapshot = await admin.firestore().collection('SystemAdmin').where('groupcode', '==', 1).get();
    console.log('Firestore Query:', `groupcode == ${userGroupCode?.toString()}`);
//    console.log('Config Snapshot:', configSnapshot.docs.map(doc => doc.data()));

    if (configSnapshot.empty) {
      console.error('User configuration not found for group code:', userGroupCode);
      return;
    }

    const firstConfigDocument = configSnapshot.docs[0];
    if (!firstConfigDocument.exists) {
      console.error('Document found, but user configuration not found for group code:', userGroupCode);
      return;
    }

    const configData = firstConfigDocument.data();

    if (!configData || !configData.connServer || !configData.connDatabase) {
      console.error('Invalid configuration data:', configData);
      return;
    }

    // Configuration for SQL Server connection based on Firestore data
// Configuration for SQL Server connection based on Firestore data
const sqlConfig = {
  user: process.env.SQL_USER || "SA",
  password: process.env.SQL_PASSWORD || "Ma#@!Lia",
  server: process.env.SQL_SERVER || "5.189.137.171",
  database: process.env.SQL_DATABASE || "Test",
  port: parseInt(process.env.SQL_PORT, 10) || 1433,
  options: {
    encrypt: process.env.SQL_ENCRYPT === "true" || false,
    trustServerCertificate: process.env.SQL_TRUST_SERVER_CERT === "true" || true,
    requestTimeout: 15000,  // Set request timeout to match the connection timeout
  },
};

console.log("Attempting to connect to SQL Server with config:", sqlConfig);

// Rest of your code...



// Connect to SQL Server and fetch data
   // Connect to SQL Server and fetch data
   await sql.connect(sqlConfig);
    
   const result = await new sql.Request().query('SELECT * FROM Items');
   const rows = result.recordset;

   if (!rows || rows.length === 0) {
     console.warn('No data retrieved from SQL Server.');
     return;
   }

   // Upload each row to the 'Items' collection with automatically generated document ID
   const itemsCollection = admin.firestore().collection('Items');

   for (const row of rows) {
     try {
       const docRef = await itemsCollection.add(row);
       console.log(`Document added with ID: ${docRef.id}`);
     } catch (error) {
       console.error('Error adding document:', error);
     }
   }

   console.log('Data migration complete.');
 } catch (err) {
   console.error('Error:', err);
 } finally {
   // Always close the SQL Server connection
   await sql.close();
 }
}

module.exports = importDataToFirestore;

module.exports = importDataToFirestore;
