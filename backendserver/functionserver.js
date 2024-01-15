const admin = require('firebase-admin');
const sql = require('mssql');

const path = require('path');

const serviceAccount = require('./firebasesdk.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://sales-bab47.firebaseio.com', // Update with your actual database URL
});

async function importDataToFirestore(userGroupCode, itemTable, priceListsTable, selectAllTables) {
  try {
    // Fetch user configuration from Firestore based on user's group code
    const configSnapshot = await admin.firestore().collection('SystemAdmin').where('groupcode', '==', userGroupCode).get();
    console.log('Firestore Query:', `groupcode == ${userGroupCode?.toString()}`);
    console.log('Config Snapshot:', configSnapshot.docs.map(doc => doc.data()));
    console.log('Firestore Query:', `itemtable == ${itemTable?.toString()}`);
    console.log('Firestore Query:', `selectAllTables == ${selectAllTables?.toString()}`);
    console.log('Firestore Query:', `priceListsTable == ${priceListsTable?.toString()}`);
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
    const sqlConfig = {
      user: configData.connUser,
      password: configData.connPassword,
      server: configData.connServer,
      database: configData.connDatabase,
      options: {
        encrypt: false,
        trustServerCertificate: true,
        port: 1433
      }
    };
      // Connect to SQL Server
    await sql.connect(sqlConfig);

    let queryItems = '';let queryItemBrand = '';let queryItemGroup='';let queryItemCateg='';let queryItemAttach='';let queryPriceList='';let queryItemUOM='';
let queryItemsPrices='';
    if (selectAllTables === 'selectall') {
      queryItems='SELECT * FROM Items';
      queryItemBrand='SELECT * From ItemBrand';
      queryItemGroup='SELECT * From ItemGroup';
      queryItemCateg='SELECT * From ItemCateg';
      queryItemAttach='SELECT * FROM ItemAttach';
      queryPriceList='SELECT * FROM PriceList';
      queryItemUOM='SELECT * FROM ItemUOM';
      queryItemsPrices='SELECT * FROM ItemsPrices';
    } else {
      // Construct the query based on the selected tables
      if (itemTable === 'Items') {
        queryItems='SELECT * FROM Items';
        queryItemBrand='SELECT * From ItemBrand';
        queryItemGroup='SELECT * From ItemGroup';
        queryItemCateg='SELECT * From ItemCateg';
        queryItemAttach='SELECT * FROM ItemAttach';

        queryItemUOM='SELECT * FROM ItemUOM';
        queryItemsPrices='SELECT * FROM ItemsPrices';      }

      if (priceListsTable === 'PriceList') {
        queryPriceList='SELECT * FROM PriceList';
      }

      // Add other tables as needed
    }

    // Execute the SQL query
    const resultItems = await new sql.Request().query(queryItems);
    const resultItemBrand = await new sql.Request().query(queryItemBrand);
    const resultItemGroup = await new sql.Request().query(queryItemGroup);
    const resultItemCateg = await new sql.Request().query(queryItemCateg);
    const resultItemAttach = await new sql.Request().query(queryItemAttach);
    const resultItemUOM = await new sql.Request().query(queryItemUOM);
    const resultItemsPrices = await new sql.Request().query(queryItemsPrices);
    const resultPriceList= await new sql.Request().query(queryPriceList);

    const rowsItems = resultItems.recordset;
    const rowsItemBrand = resultItemBrand.recordset;
    const rowsItemGroup = resultItemGroup.recordset;
    const rowsItemCateg = resultItemCateg.recordset;
    const rowsItemAttach = resultItemAttach.recordset;
    const rowsItemUOM = resultItemUOM.recordset;
    const rowsItemPrices = resultItemsPrices.recordset;
    const rowsPriceList = resultPriceList.recordset;
    // Upload each row to the respective Firestore collection with automatically generated document ID
    for (let i = 0; i < rowsItems.length; i++) {
      try {
        if (selectAllTables === 'selectall') {
          const docRefItems = await admin.firestore().collection('Items').add(rowsItems[i]);
          const docRefItemPrices = await admin.firestore().collection('ItemsPrices').add(rowsItemPrices[i]);
          const docRefItemBrand = await admin.firestore().collection('ItemBrand').add(rowsItemBrand[i]);
          const docRefItemCateg = await admin.firestore().collection('ItemCateg').add(rowsItemCateg[i]);
          const docRefItemAttach = await admin.firestore().collection('ItemAttach').add(rowsItemAttach[i]);
          const docRefItemGroup = await admin.firestore().collection('ItemGroup').add(rowsItemGroup[i]);
          const docRefItemUOM = await admin.firestore().collection('ItemUOM').add(rowsItemUOM[i]);
          const docRefPriceLists = await admin.firestore().collection('PriceLists').add(rowsPriceList[i]);
          console.log(`Document added to Items collection with IDs: ${docRefItems.id}, ${docRefItemPrices.id}, ${docRefItemBrand.id}, ${docRefItemCateg.id}, ${docRefItemAttach.id}, ${docRefItemGroup.id}, ${docRefItemUOM.id}`);
        }


        if (itemTable === 'Items') {
          const docRefItems = await admin.firestore().collection('Items').add(rowsItems[i]);
          const docRefItemPrices = await admin.firestore().collection('ItemsPrices').add(rowsItemPrices[i]);
          const docRefItemBrand = await admin.firestore().collection('ItemBrand').add(rowsItemBrand[i]);
          const docRefItemCateg = await admin.firestore().collection('ItemCateg').add(rowsItemCateg[i]);
          const docRefItemAttach = await admin.firestore().collection('ItemAttach').add(rowsItemAttach[i]);
          const docRefItemGroup = await admin.firestore().collection('ItemGroup').add(rowsItemGroup[i]);
          const docRefItemUOM = await admin.firestore().collection('ItemUOM').add(rowsItemUOM[i]);

          console.log(`Document added to Items collection with IDs: ${docRefItems.id}, ${docRefItemPrices.id}, ${docRefItemBrand.id}, ${docRefItemCateg.id}, ${docRefItemAttach.id}, ${docRefItemGroup.id}, ${docRefItemUOM.id}`);
        }

        if (priceListsTable === 'PriceList') {
          const docRefPriceLists = await admin.firestore().collection('PriceLists').add(rowsPriceList[i]);
          console.log(`Document added to PriceLists collection with ID: ${docRefPriceLists.id}`);
        }

        // Add other cases for different tables

      } catch (error) {
        console.error('Error adding document:', error);
      }
    }

    console.log('Data migration complete.');
  } catch (err) {
    console.error('Error:', err);
  } finally {
    // Close the SQL Server connection
    await sql.close();
  }

}

module.exports = importDataToFirestore;