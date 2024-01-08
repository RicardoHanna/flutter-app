const admin = require('firebase-admin');
const sql = require('mssql/msnodesqlv8');

async function importDataToFirestore() {
  // Initialize Firebase Admin SDK
  const serviceAccount = require('C:/Users/ricardo/Downloads/sales-bab47-firebase-adminsdk-gqqph-a89e060434.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://sales-bab47.firebaseio.com', // Update with your actual database URL
  });

  // Configuration for SQL Server connection
  var sqlConfig = {
    server: "DESKTOP-3J3L4AJ\\SQLEXPRESS01",
    database: "Sales",
    options: {
      trustedConnection: true,
    },
    driver: "msnodesqlv8",
  };

  // Connect to SQL Server and fetch data
  try {
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
    console.error('Error connecting to SQL Server:', err);
  }
}

module.exports = importDataToFirestore;