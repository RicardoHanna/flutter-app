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

const importDataToFirestore = require('./importscripts');

app.use(express.json());

app.post('/importData', async (req, res) => {

    console.log('Received importData request');
    try {
      await importDataToFirestore();
      res.status(200).json({ message: 'Data migration complete.' });
    } catch (error) {
      console.error('Error:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  
  app.listen(port, '0.0.0.0', () => {
    console.log(`Server listening at http://localhost:${port}`);
  });
  