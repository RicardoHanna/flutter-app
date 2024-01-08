const express = require('express');
const bodyParser = require('body-parser');
const sql = require('msnodesqlv8');

const app = express();
const port = 3000;

app.use(bodyParser.json());

app.post('/import', async (req, res) => {
  try {
    // Implement SQL Server connection and data import logic here
    // Example: Fetch data from SQL Server
    const sqlConfig = {
      server: 'DESKTOP-3J3L4AJ\\SQLEXPRESS01',
      database: 'Sales',
      options: {
        trustedConnection: true,
      },
      driver: 'msnodesqlv8',
    };

    const query = 'SELECT * FROM Items';
    const result = await executeQuery(sqlConfig, query);

    // Process the result as needed
    console.log(result);

    res.status(200).json({ message: 'Import successful' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Function to execute a SQL query
function executeQuery(config, query) {
  return new Promise((resolve, reject) => {
    sql.query(config, query, (err, result) => {
      if (err) {
        reject(err);
      } else {
        resolve(result);
      }
    });
  });
}

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
