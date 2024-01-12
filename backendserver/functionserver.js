const admin = require('firebase-admin');
const sql = require('msnodesqlv8');

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

    if (!configData || !configData.connServer || !configData.connDatabase) {
      console.error('Invalid configuration data:', configData);
      return;
    }

    // Configuration for SQL Server connection based on Firestore data
  // Configuration for SQL Server connection based on Firestore data
const sqlConfig = "Driver={SQL Server Native Client 11.0};Server=DESKTOP-3J3L4AJ\\SQLEXPRESS01;Database=Sales;Trusted_Connection=Yes";

    // Connect to SQL Server and fetch data
    const query = "select * from Items";
    
    sql.query(sqlConfig, query, (err, rows) => {
      if (err) {
        console.error('Error executing query:', err);
      } else {
        console.log('Query result:', rows);
      }
    });

    console.log('Data migration complete.');
  } catch (err) {
    console.error('Error:', err);
  }
}

module.exports = importDataToFirestore;
