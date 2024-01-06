const admin = require('firebase-admin');
const sql = require('mssql/msnodesqlv8');
const serviceAccount = require('C:/Users/ricardo/Downloads/sales-bab47-firebase-adminsdk-gqqph-a89e060434.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://sales-bab47.firebaseio.com',
});

// Initialize SQL Server connection
const sqlConfig = {
  server: "DESKTOP-3J3L4AJ\\SQLEXPRESS01",
  database: "Sales",
  options: {
    trustedConnection: true,
  },
  driver: "msnodesqlv8",
};

// Fetch data from Firebase
const firebaseCollection = 'Authorization';
const firebaseData = [];

const firestore = admin.firestore();
const firebaseCollectionRef = firestore.collection(firebaseCollection);
firebaseCollectionRef.get()
  .then(snapshot => {
    snapshot.forEach(doc => {
      const data = doc.data();
      firebaseData.push(data);
    });

    // Insert data into SQL Server
    sql.connect(sqlConfig)
      .then(() => {
        firebaseData.forEach(row => {
            const groupcode = row.groupcode !== undefined ? row.groupcode : row.value1 !== undefined ? row.value1 : null;
            const menucode = row.menucode !== undefined ? row.menucode : row.value2 !== undefined ? row.value2 : null;
          
            console.log('Inserting values into SQL Server - groupcode:', groupcode, 'menucode:', menucode);
          
            const request = new sql.Request();
          
            request.input('groupcode', sql.Int, groupcode);
            request.input('menucode', sql.Int, menucode);
          
            request.query('INSERT INTO Authorizations (groupcode, menucode) VALUES (@groupcode, @menucode);')
              .then(result => {
                console.log('Data inserted into SQL Server:', result);
              })
              .catch(err => {
                console.error('Error inserting data into SQL Server:', err);
              });
          });
          
          
      })
      .catch(err => {
        console.error('Error connecting to SQL Server:', err);
      });
  })
  .catch(err => {
    console.error('Error fetching data from Firebase:', err);
  });