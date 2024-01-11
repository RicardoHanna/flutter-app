const express = require('express');
const cors = require('cors');
const app = express();
const port = 5000;

app.use(cors());
app.use(express.json());

// Define a route for the root endpoint
app.get('/', (req, res) => {
  res.send('Welcome to the Express.js server!');
});

const importDataToFirestore = require('./functionscripts');

app.use(express.json());
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
