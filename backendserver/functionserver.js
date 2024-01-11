const admin = require('firebase-admin');
const sql = require('mssql');

const serviceAccount = require('./sales-bab47-firebase-adminsdk-gqqph-a89e060434.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://sales-bab47.firebaseio.com', // Update with your actual database URL
});
async function importDataToFirestore(userGroupCode) {
   
  try {
    // Fetch user configuration from Firestore based on user's group code
// Search for a document where 'userGroupCode' matches the specified value
const configSnapshot = await admin.firestore().collection('SystemAdmin').where('groupcode', '==', 1).get();
console.log('Firestore Query:', `groupcode == ${userGroupCode?.toString()}`);
console.log('Config Snapshot:', configSnapshot.docs.map(doc => doc.data()));

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


// Rest of your code to check and use the configuration data...

    if (!configData || !configData.connServer || !configData.connDatabase) {
      console.error('Invalid configuration data:', configData);
      return;
    }

    // Configuration for SQL Server connection based on Firestore data
    const sqlConfig = {
      server: configData.connServer,
      database: configData.connDatabase,
      options: {
        trustedConnection: true,
      },
      driver: "msnodesqlv8",
    };

    // Connect to SQL Server and fetch data
    await sql.connect(sqlConfig);
    const result = await new sql.Request().query('SELECT * FROM Items');
    const rows = result.recordset;

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
  }
}

module.exports = importDataToFirestore;
