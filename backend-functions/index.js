// backend-functions/index.js

const functions = require("firebase-functions");

exports.importData = functions.https.onRequest(async (request, response) => {
  // Your function logic here
  response.send("Import Data function executed successfully!");
});
