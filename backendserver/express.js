const express = require('express');
const cors = require('cors');
const app = express();
const port = 5000;

app.use(cors());
app.use(express.json());

// Initialize Firebase Admin SDK
const admin = require('firebase-admin');
const serviceAccount = require('./sales-bab47-firebase-adminsdk-gqqph-a89e060434.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://sales-bab47.firebaseio.com', // Update with your actual database URL
});

// Import the function for data migration
const importDataToFirestore = require('./functionserver');

app.post('/importData', async (req, res) => {
  const { userGroupCode } = req.body;

  if (userGroupCode !== undefined) {
    await importDataToFirestore(userGroupCode);
    res.status(200).json({ message: 'Data migration complete.' });
  } else {
    res.status(400).json({ error: `Bad Request - userGroupCode is undefined or invalid: ${userGroupCode}` });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server listening at http://localhost:${port}`);
});
