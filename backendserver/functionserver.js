const admin = require('firebase-admin');
const sql = require('mssql');

const path = require('path');

const serviceAccount = require('./firebasesdk.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://sales-bab47.firebaseio.com', // Update with your actual database URL
});

async function importDataToFirestore(userGroupCode, itemTable, priceListsTable, selectAllTables,customersTable,systemTables) {
  try {
    // Fetch user configuration from Firestore based on user's group code
    const configSnapshot = await admin.firestore().collection('SystemAdmin').where('groupcode', '==', userGroupCode).get();
    console.log('Firestore Query:', `groupcode == ${userGroupCode?.toString()}`);
    console.log('Config Snapshot:', configSnapshot.docs.map(doc => doc.data()));
    console.log('Firestore Query:', `itemtable == ${itemTable?.toString()}`);
    console.log('Firestore Query:', `selectAllTables == ${selectAllTables?.toString()}`);
    console.log('Firestore Query:', `priceListsTable == ${priceListsTable?.toString()}`);
    console.log('Firestore Query:', `customerSTable == ${customersTable?.toString()}`);
    console.log('Firestore Query:', `systemTable == ${systemTables?.toString()}`);
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
        port: configData.connPort
      }
    };
      // Connect to SQL Server
    await sql.connect(sqlConfig);

    let queryItems = '';let queryItemBrand = '';let queryItemGroup='';let queryItemCateg='';
    let queryItemAttach='';let queryPriceList='';let queryItemUOM='';
let queryItemsPrices='';let queryCompanies='';let queryDepartments='';let queryExchangeRate='';
let queryCurrencies=''; let queryVATGroups='';let queryCustGroups='';let queryCustProperties='';
let queryRegions='';let queryWarehouses='';let queryPaymentTerms='';let querySalesEmployees='';
let querySalesEmployeesCustomers='';let querySalesEmployeesDepartments='';let querySalesEmployeesItemsBrands='';
let querySalesEmployeesItemsCategories='';let querySalesEmployeesItemsGroups='';let querySalesEmployeesItems='';
let queryUsersSalesEmployees='';let queryCustomers='';let queryCustomerAddresses='';let queryCustomerContacts='';
let queryCustomerProperties='';let queryCustomerAttachments='';let queryCustomerItemsSpecialPrice='';
let queryCustomerBrandSpecialPrice='';let queryCustomerGroupSpecialPrice='';let queryCustomerCategSpecialPrice='';
let queryCustomerGroupItemsSpecialPrice='';let queryCustomerGroupBrandSpecialPrice='';let queryCustomerGroupGroupSpecialPrice='';
let queryCustomerGroupCategSpecialPrice='';let queryCustomerPropItemsSpecialPrice='';let queryCustomerPropBrandSpecialPrice='';
let queryCustomerPropGroupSpecialPrice='';let queryCustomerPropCategSpecialPrice='';

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
        queryItemsPrices='SELECT * FROM ItemsPrices';     
       }

      if (priceListsTable === 'PriceList') {
        queryPriceList='SELECT * FROM PriceList';
      }

      if(customersTable==='Customers'){
        queryCustomers='SELECT * FROM Customers';
        queryCustomerAddresses='SELECT * FROM CustomerAddresses';
        queryCustomerContacts='SELECT * FROM CustomerContacts';
        queryCustomerProperties='SELECT * FROM CustomerProperties';
        queryCustomerAttachments='SELECT * FROM CustomerAttachments';
        queryCustomerItemsSpecialPrice='SELECT * FROM CustomerItemsSpecialPrice';
        queryCustomerBrandSpecialPrice='SELECT * FROM CustomerBrandSpecialPrice';
        queryCustomerGroupSpecialPrice='SELECT * FROM CustomerGroupSpecialPrice';
        queryCustomerCategSpecialPrice='SELECT * FROM CustomerCategSpecialPrice';
        queryCustomerGroupItemsSpecialPrice='SELECT * FROM CustomerGroupItemsSpecialPrice';
        queryCustomerGroupBrandSpecialPrice='SELECT * FROM CustomerGroupBrandSpecialPrice';
        queryCustomerGroupGroupSpecialPrice='SELECT * FROM CustomerGroupGroupSpecialPrice';
        queryCustomerGroupCategSpecialPrice='SELECT * FROM CustomerGroupCategSpecialPrice';
        queryCustomerPropItemsSpecialPrice='SELECT * FROM CustomerPropItemsSpecialPrice';
        queryCustomerPropBrandSpecialPrice='SELECT * FROM CustomerPropBrandSpecialPrice';
        queryCustomerPropGroupSpecialPrice='SELECT * FROM CustomerPropGroupSpecialPrice';
        queryCustomerPropCategSpecialPrice='SELECT * FROM CustomerPropCategSpecialPrice';
      }

      if(systemTables==='System'){
         queryCompanies='SELECT * FROM Companies';
         queryDepartments='SELECT * FROM Departments';
         queryExchangeRate='SELECT * FROM ExchangeRate';
         queryCurrencies='SELECT * FROM Currencies'; 
         queryVATGroups='SELECT * FROM VATGroups';
         queryCustGroups='SELECT * FROM CustGroups';
         queryCustProperties='SELECT * FROM CustProperties';
         queryRegions='SELECT * FROM Regions';
         queryWarehouses='SELECT * FROM Warehouses';
         queryPaymentTerms='SELECT * FROM PaymentTerms';
         querySalesEmployees='SELECT * FROM SalesEmployees';
         querySalesEmployeesCustomers='SELECT * FROM SalesEmployeesCustomers';
         querySalesEmployeesDepartments='SELECT * FROM SalesEmployeesDepartments';
         querySalesEmployeesItemsBrands='SELECT * FROM SalesEmployeesItemsBrands';
         querySalesEmployeesItemsCategories='SELECT * FROM SalesEmployeesItemsCategories';
         querySalesEmployeesItemsGroups='SELECT * FROM SalesEmployeesItemsGroups';
         querySalesEmployeesItems='SELECT * FROM SalesEmployeesItems';
         queryUsersSalesEmployees='SELECT * FROM UsersSalesEmployees';
      }

      // Add other tables as needed
    }

    // Execute the SQL query
   // Execute the SQL queries
const resultItems = await new sql.Request().query(queryItems);
const resultItemBrand = await new sql.Request().query(queryItemBrand);
const resultItemGroup = await new sql.Request().query(queryItemGroup);
const resultItemCateg = await new sql.Request().query(queryItemCateg);
const resultItemAttach = await new sql.Request().query(queryItemAttach);
const resultItemUOM = await new sql.Request().query(queryItemUOM);
const resultItemsPrices = await new sql.Request().query(queryItemsPrices);
const resultPriceList = await new sql.Request().query(queryPriceList);
const resultCompanies = await new sql.Request().query(queryCompanies);
const resultDepartments = await new sql.Request().query(queryDepartments);
const resultExchangeRate = await new sql.Request().query(queryExchangeRate);
const resultCurrencies = await new sql.Request().query(queryCurrencies);
const resultVATGroups = await new sql.Request().query(queryVATGroups);
const resultCustGroups = await new sql.Request().query(queryCustGroups);
const resultCustProperties = await new sql.Request().query(queryCustProperties);
const resultRegions = await new sql.Request().query(queryRegions);
const resultWarehouses = await new sql.Request().query(queryWarehouses);
const resultPaymentTerms = await new sql.Request().query(queryPaymentTerms);
const resultSalesEmployees = await new sql.Request().query(querySalesEmployees);
const resultSalesEmployeesCustomers = await new sql.Request().query(querySalesEmployeesCustomers);
const resultSalesEmployeesDepartments = await new sql.Request().query(querySalesEmployeesDepartments);
const resultSalesEmployeesItemsBrands = await new sql.Request().query(querySalesEmployeesItemsBrands);
const resultSalesEmployeesItemsCategories = await new sql.Request().query(querySalesEmployeesItemsCategories);
const resultSalesEmployeesItemsGroups = await new sql.Request().query(querySalesEmployeesItemsGroups);
const resultSalesEmployeesItems = await new sql.Request().query(querySalesEmployeesItems);
const resultUsersSalesEmployees = await new sql.Request().query(queryUsersSalesEmployees);
const resultCustomers = await new sql.Request().query(queryCustomers);
const resultCustomerAddresses = await new sql.Request().query(queryCustomerAddresses);
const resultCustomerContacts = await new sql.Request().query(queryCustomerContacts);
const resultCustomerProperties = await new sql.Request().query(queryCustomerProperties);
const resultCustomerAttachments = await new sql.Request().query(queryCustomerAttachments);
const resultCustomerItemsSpecialPrice = await new sql.Request().query(queryCustomerItemsSpecialPrice);
const resultCustomerBrandSpecialPrice = await new sql.Request().query(queryCustomerBrandSpecialPrice);
const resultCustomerGroupSpecialPrice = await new sql.Request().query(queryCustomerGroupSpecialPrice);
const resultCustomerCategSpecialPrice = await new sql.Request().query(queryCustomerCategSpecialPrice);
const resultCustomerGroupItemsSpecialPrice = await new sql.Request().query(queryCustomerGroupItemsSpecialPrice);
const resultCustomerGroupBrandSpecialPrice = await new sql.Request().query(queryCustomerGroupBrandSpecialPrice);
const resultCustomerGroupGroupSpecialPrice = await new sql.Request().query(queryCustomerGroupGroupSpecialPrice);
const resultCustomerGroupCategSpecialPrice = await new sql.Request().query(queryCustomerGroupCategSpecialPrice);
const resultCustomerPropItemsSpecialPrice = await new sql.Request().query(queryCustomerPropItemsSpecialPrice);
const resultCustomerPropBrandSpecialPrice = await new sql.Request().query(queryCustomerPropBrandSpecialPrice);
const resultCustomerPropGroupSpecialPrice = await new sql.Request().query(queryCustomerPropGroupSpecialPrice);
const resultCustomerPropCategSpecialPrice = await new sql.Request().query(queryCustomerPropCategSpecialPrice);

// Get the results
const rowsItems = resultItems.recordset;
const rowsItemBrand = resultItemBrand.recordset;
const rowsItemGroup = resultItemGroup.recordset;
const rowsItemCateg = resultItemCateg.recordset;
const rowsItemAttach = resultItemAttach.recordset;
const rowsItemUOM = resultItemUOM.recordset;
const rowsItemPrices = resultItemsPrices.recordset;
const rowsPriceList = resultPriceList.recordset;
const rowsCompanies = resultCompanies.recordset;
const rowsDepartments = resultDepartments.recordset;
const rowsExchangeRate = resultExchangeRate.recordset;
const rowsCurrencies = resultCurrencies.recordset;
const rowsVATGroups = resultVATGroups.recordset;
const rowsCustGroups = resultCustGroups.recordset;
const rowsCustProperties = resultCustProperties.recordset;
const rowsRegions = resultRegions.recordset;
const rowsWarehouses = resultWarehouses.recordset;
const rowsPaymentTerms = resultPaymentTerms.recordset;
const rowsSalesEmployees = resultSalesEmployees.recordset;
const rowsSalesEmployeesCustomers = resultSalesEmployeesCustomers.recordset;
const rowsSalesEmployeesDepartments = resultSalesEmployeesDepartments.recordset;
const rowsSalesEmployeesItemsBrands = resultSalesEmployeesItemsBrands.recordset;
const rowsSalesEmployeesItemsCategories = resultSalesEmployeesItemsCategories.recordset;
const rowsSalesEmployeesItemsGroups = resultSalesEmployeesItemsGroups.recordset;
const rowsSalesEmployeesItems = resultSalesEmployeesItems.recordset;
const rowsUsersSalesEmployees = resultUsersSalesEmployees.recordset;
const rowsCustomers = resultCustomers.recordset;
const rowsCustomerAddresses = resultCustomerAddresses.recordset;
const rowsCustomerContacts = resultCustomerContacts.recordset;
const rowsCustomerProperties = resultCustomerProperties.recordset;
const rowsCustomerAttachments = resultCustomerAttachments.recordset;
const rowsCustomerItemsSpecialPrice = resultCustomerItemsSpecialPrice.recordset;
const rowsCustomerBrandSpecialPrice = resultCustomerBrandSpecialPrice.recordset;
const rowsCustomerGroupSpecialPrice = resultCustomerGroupSpecialPrice.recordset;
const rowsCustomerCategSpecialPrice = resultCustomerCategSpecialPrice.recordset;
const rowsCustomerGroupItemsSpecialPrice = resultCustomerGroupItemsSpecialPrice.recordset;
const rowsCustomerGroupBrandSpecialPrice = resultCustomerGroupBrandSpecialPrice.recordset;
const rowsCustomerGroupGroupSpecialPrice = resultCustomerGroupGroupSpecialPrice.recordset;
const rowsCustomerGroupCategSpecialPrice = resultCustomerGroupCategSpecialPrice.recordset;
const rowsCustomerPropItemsSpecialPrice = resultCustomerPropItemsSpecialPrice.recordset;
const rowsCustomerPropBrandSpecialPrice = resultCustomerPropBrandSpecialPrice.recordset;
const rowsCustomerPropGroupSpecialPrice = resultCustomerPropGroupSpecialPrice.recordset;
const rowsCustomerPropCategSpecialPrice = resultCustomerPropCategSpecialPrice.recordset;

    // Upload each row to the respective Firestore collection with automatically generated document ID
    let docRefItems, docRefItemPrices, docRefItemBrand, docRefItemCateg, docRefItemAttach, docRefItemGroup, docRefItemUOM, docRefPriceLists;
    let docRefCustomers, docRefCustomerAddresses, docRefCustomerContacts, docRefCustomerProperties, docRefCustomerAttachments, docRefCustomerItemsSpecialPrice, docRefCustomerBrandSpecialPrice, docRefCustomerGroupSpecialPrice, docRefCustomerCategSpecialPrice, docRefCustomerGroupItemsSpecialPrice, docRefCustomerGroupBrandSpecialPrice, docRefCustomerGroupGroupSpecialPrice, docRefCustomerGroupCategSpecialPrice, docRefCustomerPropItemsSpecialPrice, docRefCustomerPropBrandSpecialPrice, docRefCustomerPropGroupSpecialPrice, docRefCustomerPropCategSpecialPrice;
    let  docRefCompanies ,docRefDepartments,docRefExchangeRate, docRefCurrencies, docRefVATGroups, docRefCustGroups,docRefCustProperties, docRefRegions , docRefWarehouses, docRefPaymentTerms ,docRefSalesEmployees ,  docRefSalesEmployeesCustomers , docRefSalesEmployeesDepartments , docRefSalesEmployeesItemsBrands , docRefSalesEmployeesItemsCategories , docRefSalesEmployeesItemsGroups , docRefSalesEmployeesItems , docRefUsersSalesEmployees;
    // ... rest of your code
    
      try {
        if (selectAllTables === 'selectall') {
          if (rowsItems && rowsItems.length) {
          for (let i = 0; i < rowsItems.length; i++) {
           docRefItems = await admin.firestore().collection('Items').add(rowsItems[i]);
          }
          }
          if (rowsItemPrices && rowsItemPrices.length) {
          for (let i = 0; i < rowsItemPrices.length; i++) {
           
           docRefItemPrices = await admin.firestore().collection('ItemsPrices').add(rowsItemPrices[i]);
            }
          }
          if (rowsItemBrand && rowsItemBrand.length) {
          for (let i = 0; i < rowsItemBrand.length; i++) {
          
           docRefItemBrand = await admin.firestore().collection('ItemBrand').add(rowsItemBrand[i]);
            }
          }
          if (rowsItemCateg && rowsItemCateg.length) {
          for (let i = 0; i < rowsItemCateg.length; i++) {
         
           docRefItemCateg = await admin.firestore().collection('ItemCateg').add(rowsItemCateg[i]);
          }
        }
        if (rowsItemAttach && rowsItemAttach.length) {
        for (let i = 0; i < rowsItemAttach.length; i++) {
    
           docRefItemAttach = await admin.firestore().collection('ItemAttach').add(rowsItemAttach[i]);
          }
          }
          if (rowsItemGroup && rowsItemGroup.length) {
          for (let i = 0; i < rowsItemGroup.length; i++) {
            
           docRefItemGroup = await admin.firestore().collection('ItemGroup').add(rowsItemGroup[i]);
            }
          }
          if (rowsItemUOM && rowsItemUOM.length) {
          for (let i = 0; i < rowsItemUOM.length; i++) {
         
           docRefItemUOM = await admin.firestore().collection('ItemUOM').add(rowsItemUOM[i]);
            }
          }
          if (rowsPriceList && rowsPriceList.length) {
          for (let i = 0; i < rowsPriceList.length; i++) {
    
           docRefPriceLists = await admin.firestore().collection('PriceLists').add(rowsPriceList[i]);
            }
          }
          //------
          if (rowsCustomers && rowsCustomers.length) {
          for (let i = 0; i < rowsCustomers.length; i++) {
          
           docRefCustomers = await admin.firestore().collection('Customers').add(rowsCustomers[i]);
            }
          }
          if (rowsCustomerAddresses && rowsCustomerAddresses.length) {
          for (let i = 0; i < rowsCustomerAddresses.length; i++) {
       
           docRefCustomerAddresses = await admin.firestore().collection('CustomerAddresses').add(rowsCustomerAddresses[i]);
            }
          }
          if (rowsCustomerContacts && rowsCustomerContacts.length) {
          for (let i = 0; i < rowsCustomerContacts.length; i++) {
        
           docRefCustomerContacts = await admin.firestore().collection('CustomerContacts').add(rowsCustomerContacts[i]);
            }
          }
          if (rowsCustomerProperties && rowsCustomerProperties.length) {
          for (let i = 0; i < rowsCustomerProperties.length; i++) {
          
           docRefCustomerProperties = await admin.firestore().collection('CustomerProperties').add(rowsCustomerProperties[i]);
            }
          }
          if (rowsCustomerAttachments && rowsCustomerAttachments.length) {
          for (let i = 0; i < rowsCustomerAttachments.length; i++) {
        
           docRefCustomerAttachments = await admin.firestore().collection('CustomerAttachments').add(rowsCustomerAttachments[i]);
            }
          }
          if (rowsCustomerItemsSpecialPrice && rowsCustomerItemsSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerItemsSpecialPrice.length; i++) {
           
           docRefCustomerItemsSpecialPrice = await admin.firestore().collection('CustomerItemsSpecialPrice').add(rowsCustomerItemsSpecialPrice[i]);
            }
          }
          if (rowsCustomerBrandSpecialPrice && rowsCustomerBrandSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerBrandSpecialPrice.length; i++) {
          
           docRefCustomerBrandSpecialPrice = await admin.firestore().collection('CustomerBrandSpecialPrice').add(rowsCustomerBrandSpecialPrice[i]);
            }
          }
          if (rowsCustomerGroupSpecialPrice && rowsCustomerGroupSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerGroupSpecialPrice.length; i++) {
    
           docRefCustomerGroupSpecialPrice = await admin.firestore().collection('CustomerGroupSpecialPrice').add(rowsCustomerGroupSpecialPrice[i]);
            }
          }
          if (rowsCustomerCategSpecialPrice && rowsCustomerCategSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerCategSpecialPrice.length; i++) {
       
           docRefCustomerCategSpecialPrice = await admin.firestore().collection('CustomerCategSpecialPrice').add(rowsCustomerCategSpecialPrice[i]);
            }
          }
          if (rowsCustomerGroupItemsSpecialPrice && rowsCustomerGroupItemsSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerGroupItemsSpecialPrice.length; i++) {
       
           docRefCustomerGroupItemsSpecialPrice = await admin.firestore().collection('CustomerGroupItemsSpecialPrice').add(rowsCustomerGroupItemsSpecialPrice[i]);
            }
          }
          if (rowsCustomerGroupBrandSpecialPrice && rowsCustomerGroupBrandSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerGroupBrandSpecialPrice.length; i++) {

           docRefCustomerGroupBrandSpecialPrice = await admin.firestore().collection('CustomerGroupBrandSpecialPrice').add(rowsCustomerGroupBrandSpecialPrice[i]);
            }
          }
          if (rowsCustomerGroupGroupSpecialPrice && rowsCustomerGroupGroupSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerGroupGroupSpecialPrice.length; i++) {
        
           docRefCustomerGroupGroupSpecialPrice = await admin.firestore().collection('CustomerGroupGroupSpecialPrice').add(rowsCustomerGroupGroupSpecialPrice[i]);
            }
          }
          if (rowsCustomerGroupCategSpecialPrice && rowsCustomerGroupCategSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerGroupCategSpecialPrice.length; i++) {
    
           docRefCustomerGroupCategSpecialPrice = await admin.firestore().collection('CustomerGroupCategSpecialPrice').add(rowsCustomerGroupCategSpecialPrice[i]);
            }
          }
          if (rowsCustomerPropItemsSpecialPrice && rowsCustomerPropItemsSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerPropItemsSpecialPrice.length; i++) {
        
           docRefCustomerPropItemsSpecialPrice = await admin.firestore().collection('CustomerPropItemsSpecialPrice').add(rowsCustomerPropItemsSpecialPrice[i]);
            }
          }
          if (rowsCustomerPropBrandSpecialPrice && rowsCustomerPropBrandSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerPropBrandSpecialPrice.length; i++) {
        
           docRefCustomerPropBrandSpecialPrice = await admin.firestore().collection('CustomerPropBrandSpecialPrice').add(rowsCustomerPropBrandSpecialPrice[i]);
            }
          }
          if (rowsCustomerPropGroupSpecialPrice && rowsCustomerPropGroupSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerPropGroupSpecialPrice.length; i++) {
 
           docRefCustomerPropGroupSpecialPrice = await admin.firestore().collection('CustomerPropGroupSpecialPrice').add(rowsCustomerPropGroupSpecialPrice[i]);
            }
          }
          if (rowsCustomerPropCategSpecialPrice && rowsCustomerPropCategSpecialPrice.length) {
          for (let i = 0; i < rowsCustomerPropCategSpecialPrice.length; i++) {
    
           docRefCustomerPropCategSpecialPrice = await admin.firestore().collection('CustomerPropCategSpecialPrice').add(rowsCustomerPropCategSpecialPrice[i]);
            }
          }
        
          console.log(`Document added to Customers collection with IDs: ${docRefCustomers?.id}, ${docRefCustomerAddresses?.id}, ${docRefCustomerContacts?.id}, ${docRefCustomerProperties?.id}, ${docRefCustomerAttachments?.id}, ${docRefCustomerItemsSpecialPrice?.id}, ${docRefCustomerBrandSpecialPrice?.id}, ${docRefCustomerGroupSpecialPrice?.id}, ${docRefCustomerCategSpecialPrice?.id}, ${docRefCustomerGroupItemsSpecialPrice?.id}, ${docRefCustomerGroupBrandSpecialPrice?.id}, ${docRefCustomerGroupGroupSpecialPrice?.id}, ${docRefCustomerGroupCategSpecialPrice?.id}, ${docRefCustomerPropItemsSpecialPrice?.id}, ${docRefCustomerPropBrandSpecialPrice?.id}, ${docRefCustomerPropGroupSpecialPrice?.id}, ${docRefCustomerPropCategSpecialPrice?.id}`);
          //-----
          if (rowsCompanies && rowsCompanies.length) {
          for (let i = 0; i < rowsCompanies.length; i++) {

           docRefCompanies = await admin.firestore().collection('Companies').add(rowsCompanies[i]);
            }
          }
          if (rowsDepartments && rowsDepartments.length) {
          for (let i = 0; i < rowsDepartments.length; i++) {
     
           docRefDepartments = await admin.firestore().collection('Departments').add(rowsDepartments[i]);
            }
          }
          if (rowsExchangeRate && rowsExchangeRate.length) {
          for (let i = 0; i < rowsExchangeRate.length; i++) {
      
           docRefExchangeRate = await admin.firestore().collection('ExchangeRate').add(rowsExchangeRate[i]);
            }
          }
          if (rowsCurrencies && rowsCurrencies.length) {
          for (let i = 0; i < rowsCurrencies.length; i++) {

           docRefCurrencies = await admin.firestore().collection('Currencies').add(rowsCurrencies[i]);
            }
          }
          if (rowsVATGroups && rowsVATGroups.length) {
          for (let i = 0; i < rowsVATGroups.length; i++) {
         
           docRefVATGroups = await admin.firestore().collection('VATGroups').add(rowsVATGroups[i]);
            }
          }
          if (rowsCustGroups && rowsCustGroups.length) {
          for (let i = 0; i < rowsCustGroups.length; i++) {
           
           docRefCustGroups = await admin.firestore().collection('CustGroups').add(rowsCustGroups[i]);
            }
          }
          if (rowsCustProperties && rowsCustProperties.length) {
          for (let i = 0; i < rowsCustProperties.length; i++) {
     
           docRefCustProperties = await admin.firestore().collection('CustProperties').add(rowsCustProperties[i]);
            }
          }
          if (rowsRegions && rowsRegions.length) {
          for (let i = 0; i < rowsRegions.length; i++) {
          
           docRefRegions = await admin.firestore().collection('Regions').add(rowsRegions[i]);
            }
          }
          if (rowsWarehouses && rowsWarehouses.length) {
          for (let i = 0; i < rowsWarehouses.length; i++) {
      
           docRefWarehouses = await admin.firestore().collection('Warehouses').add(rowsWarehouses[i]);
            }
          }
          if (rowsPaymentTerms && rowsPaymentTerms.length) {
          for (let i = 0; i < rowsPaymentTerms.length; i++) {
         
           docRefPaymentTerms = await admin.firestore().collection('PaymentTerms').add(rowsPaymentTerms[i]);
            }
          }
          if (rowsSalesEmployees && rowsSalesEmployees.length) {
          for (let i = 0; i < rowsSalesEmployees.length; i++) {
         
           docRefSalesEmployees = await admin.firestore().collection('SalesEmployees').add(rowsSalesEmployees[i]);
            }
          }
          if (rowsSalesEmployeesCustomers && rowsSalesEmployeesCustomers.length) {
          for (let i = 0; i < rowsSalesEmployeesCustomers.length; i++) {
    
           docRefSalesEmployeesCustomers = await admin.firestore().collection('SalesEmployeesCustomers').add(rowsSalesEmployeesCustomers[i]);
            }
          }
          if (rowsSalesEmployeesDepartments && rowsSalesEmployeesDepartments.length) {
          for (let i = 0; i < rowsSalesEmployeesDepartments.length; i++) {
        
           docRefSalesEmployeesDepartments = await admin.firestore().collection('SalesEmployeesDepartments').add(rowsSalesEmployeesDepartments[i]);
            }
          }
          if (rowsSalesEmployeesItemsBrands && rowsSalesEmployeesItemsBrands.length) {
          for (let i = 0; i < rowsSalesEmployeesItemsBrands.length; i++) {
            
           docRefSalesEmployeesItemsBrands = await admin.firestore().collection('SalesEmployeesItemsBrands').add(rowsSalesEmployeesItemsBrands[i]);
            }
          }
          if (rowsSalesEmployeesItemsCategories && rowsSalesEmployeesItemsCategories.length) {
          for (let i = 0; i < rowsSalesEmployeesItemsCategories.length; i++) {
          
           docRefSalesEmployeesItemsCategories = await admin.firestore().collection('SalesEmployeesItemsCategories').add(rowsSalesEmployeesItemsCategories[i]);
            }
          }
          if (rowsSalesEmployeesItemsGroups && rowsSalesEmployeesItemsGroups.length) {
          for (let i = 0; i < rowsSalesEmployeesItemsGroups.length; i++) {

           docRefSalesEmployeesItemsGroups = await admin.firestore().collection('SalesEmployeesItemsGroups').add(rowsSalesEmployeesItemsGroups[i]);
            }
          }
          if (rowsSalesEmployeesItems && rowsSalesEmployeesItems.length) {
          for (let i = 0; i < rowsSalesEmployeesItems.length; i++) {
      
           docRefSalesEmployeesItems = await admin.firestore().collection('SalesEmployeesItems').add(rowsSalesEmployeesItems[i]);
            }
          }
          if (rowsUsersSalesEmployees && rowsUsersSalesEmployees.length) {
          for (let i = 0; i < rowsUsersSalesEmployees.length; i++) {
          
           docRefUsersSalesEmployees = await admin.firestore().collection('UsersSalesEmployees').add(rowsUsersSalesEmployees[i]);
            }
          }
        
          console.log(`Document added to System collection with IDs: ${docRefCompanies?.id}, ${docRefDepartments?.id}, ${docRefExchangeRate?.id}, ${docRefCurrencies?.id}, ${docRefVATGroups?.id}, ${docRefCustGroups?.id}, ${docRefCustProperties?.id}, ${docRefRegions?.id}, ${docRefWarehouses?.id}, ${docRefPaymentTerms?.id}, ${docRefSalesEmployees?.id}, ${docRefSalesEmployeesCustomers?.id}, ${docRefSalesEmployeesDepartments?.id}, ${docRefSalesEmployeesItemsBrands?.id}, ${docRefSalesEmployeesItemsCategories?.id}, ${docRefSalesEmployeesItemsGroups?.id}, ${docRefSalesEmployeesItems?.id}, ${docRefUsersSalesEmployees?.id}`);

          console.log(`Document added to Items collection with IDs: ${docRefItems?.id}, ${docRefItemPrices?.id}, ${docRefItemBrand?.id}, ${docRefItemCateg?.id}, ${docRefItemAttach?.id}, ${docRefItemGroup?.id}, ${docRefItemUOM?.id}`);
        }


        if (itemTable === 'Items') {
          if (rowsItems && rowsItems.length) {
            for (let i = 0; i < rowsItems.length; i++) {
             docRefItems = await admin.firestore().collection('Items').add(rowsItems[i]);
            }
            }
            if (rowsItemPrices && rowsItemPrices.length) {
            for (let i = 0; i < rowsItemPrices.length; i++) {
             
             docRefItemPrices = await admin.firestore().collection('ItemsPrices').add(rowsItemPrices[i]);
              }
            }
            if (rowsItemBrand && rowsItemBrand.length) {
            for (let i = 0; i < rowsItemBrand.length; i++) {
            
             docRefItemBrand = await admin.firestore().collection('ItemBrand').add(rowsItemBrand[i]);
              }
            }
            if (rowsItemCateg && rowsItemCateg.length) {
            for (let i = 0; i < rowsItemCateg.length; i++) {
           
             docRefItemCateg = await admin.firestore().collection('ItemCateg').add(rowsItemCateg[i]);
            }
          }
          if (rowsItemAttach && rowsItemAttach.length) {
          for (let i = 0; i < rowsItemAttach.length; i++) {
      
             docRefItemAttach = await admin.firestore().collection('ItemAttach').add(rowsItemAttach[i]);
            }
            }
            if (rowsItemGroup && rowsItemGroup.length) {
            for (let i = 0; i < rowsItemGroup.length; i++) {
              
             docRefItemGroup = await admin.firestore().collection('ItemGroup').add(rowsItemGroup[i]);
              }
            }
            if (rowsItemUOM && rowsItemUOM.length) {
            for (let i = 0; i < rowsItemUOM.length; i++) {
           
             docRefItemUOM = await admin.firestore().collection('ItemUOM').add(rowsItemUOM[i]);
              }
            }

          console.log(`Document added to Items collection with IDs: ${docRefItems?.id}, ${docRefItemPrices?.id}, ${docRefItemBrand?.id}, ${docRefItemCateg?.id}, ${docRefItemAttach?.id}, ${docRefItemGroup?.id}, ${docRefItemUOM?.id}`);
        }

        if (priceListsTable === 'PriceList') {
          if (rowsPriceList && rowsPriceList.length) {
            for (let i = 0; i < rowsPriceList.length; i++) {
      
             docRefPriceLists = await admin.firestore().collection('PriceLists').add(rowsPriceList[i]);
              }
            }
        }

        if(customersTable === 'Customers'){
          if (rowsCustomers && rowsCustomers.length) {
            for (let i = 0; i < rowsCustomers.length; i++) {
            
             docRefCustomers = await admin.firestore().collection('Customers').add(rowsCustomers[i]);
              }
            }
            if (rowsCustomerAddresses && rowsCustomerAddresses.length) {
            for (let i = 0; i < rowsCustomerAddresses.length; i++) {
         
             docRefCustomerAddresses = await admin.firestore().collection('CustomerAddresses').add(rowsCustomerAddresses[i]);
              }
            }
            if (rowsCustomerContacts && rowsCustomerContacts.length) {
            for (let i = 0; i < rowsCustomerContacts.length; i++) {
          
             docRefCustomerContacts = await admin.firestore().collection('CustomerContacts').add(rowsCustomerContacts[i]);
              }
            }
            if (rowsCustomerProperties && rowsCustomerProperties.length) {
            for (let i = 0; i < rowsCustomerProperties.length; i++) {
            
             docRefCustomerProperties = await admin.firestore().collection('CustomerProperties').add(rowsCustomerProperties[i]);
              }
            }
            if (rowsCustomerAttachments && rowsCustomerAttachments.length) {
            for (let i = 0; i < rowsCustomerAttachments.length; i++) {
          
             docRefCustomerAttachments = await admin.firestore().collection('CustomerAttachments').add(rowsCustomerAttachments[i]);
              }
            }
            if (rowsCustomerItemsSpecialPrice && rowsCustomerItemsSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerItemsSpecialPrice.length; i++) {
             
             docRefCustomerItemsSpecialPrice = await admin.firestore().collection('CustomerItemsSpecialPrice').add(rowsCustomerItemsSpecialPrice[i]);
              }
            }
            if (rowsCustomerBrandSpecialPrice && rowsCustomerBrandSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerBrandSpecialPrice.length; i++) {
            
             docRefCustomerBrandSpecialPrice = await admin.firestore().collection('CustomerBrandSpecialPrice').add(rowsCustomerBrandSpecialPrice[i]);
              }
            }
            if (rowsCustomerGroupSpecialPrice && rowsCustomerGroupSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerGroupSpecialPrice.length; i++) {
      
             docRefCustomerGroupSpecialPrice = await admin.firestore().collection('CustomerGroupSpecialPrice').add(rowsCustomerGroupSpecialPrice[i]);
              }
            }
            if (rowsCustomerCategSpecialPrice && rowsCustomerCategSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerCategSpecialPrice.length; i++) {
         
             docRefCustomerCategSpecialPrice = await admin.firestore().collection('CustomerCategSpecialPrice').add(rowsCustomerCategSpecialPrice[i]);
              }
            }
            if (rowsCustomerGroupItemsSpecialPrice && rowsCustomerGroupItemsSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerGroupItemsSpecialPrice.length; i++) {
         
             docRefCustomerGroupItemsSpecialPrice = await admin.firestore().collection('CustomerGroupItemsSpecialPrice').add(rowsCustomerGroupItemsSpecialPrice[i]);
              }
            }
            if (rowsCustomerGroupBrandSpecialPrice && rowsCustomerGroupBrandSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerGroupBrandSpecialPrice.length; i++) {
  
             docRefCustomerGroupBrandSpecialPrice = await admin.firestore().collection('CustomerGroupBrandSpecialPrice').add(rowsCustomerGroupBrandSpecialPrice[i]);
              }
            }
            if (rowsCustomerGroupGroupSpecialPrice && rowsCustomerGroupGroupSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerGroupGroupSpecialPrice.length; i++) {
          
             docRefCustomerGroupGroupSpecialPrice = await admin.firestore().collection('CustomerGroupGroupSpecialPrice').add(rowsCustomerGroupGroupSpecialPrice[i]);
              }
            }
            if (rowsCustomerGroupCategSpecialPrice && rowsCustomerGroupCategSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerGroupCategSpecialPrice.length; i++) {
      
             docRefCustomerGroupCategSpecialPrice = await admin.firestore().collection('CustomerGroupCategSpecialPrice').add(rowsCustomerGroupCategSpecialPrice[i]);
              }
            }
            if (rowsCustomerPropItemsSpecialPrice && rowsCustomerPropItemsSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerPropItemsSpecialPrice.length; i++) {
          
             docRefCustomerPropItemsSpecialPrice = await admin.firestore().collection('CustomerPropItemsSpecialPrice').add(rowsCustomerPropItemsSpecialPrice[i]);
              }
            }
            if (rowsCustomerPropBrandSpecialPrice && rowsCustomerPropBrandSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerPropBrandSpecialPrice.length; i++) {
          
             docRefCustomerPropBrandSpecialPrice = await admin.firestore().collection('CustomerPropBrandSpecialPrice').add(rowsCustomerPropBrandSpecialPrice[i]);
              }
            }
            if (rowsCustomerPropGroupSpecialPrice && rowsCustomerPropGroupSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerPropGroupSpecialPrice.length; i++) {
   
             docRefCustomerPropGroupSpecialPrice = await admin.firestore().collection('CustomerPropGroupSpecialPrice').add(rowsCustomerPropGroupSpecialPrice[i]);
              }
            }
            if (rowsCustomerPropCategSpecialPrice && rowsCustomerPropCategSpecialPrice.length) {
            for (let i = 0; i < rowsCustomerPropCategSpecialPrice.length; i++) {
      
             docRefCustomerPropCategSpecialPrice = await admin.firestore().collection('CustomerPropCategSpecialPrice').add(rowsCustomerPropCategSpecialPrice[i]);
              }
            }
          
        
            console.log(`Document added to Customers collection with IDs: ${docRefCustomers?.id}, ${docRefCustomerAddresses?.id}, ${docRefCustomerContacts?.id}, ${docRefCustomerProperties?.id}, ${docRefCustomerAttachments?.id}, ${docRefCustomerItemsSpecialPrice?.id}, ${docRefCustomerBrandSpecialPrice?.id}, ${docRefCustomerGroupSpecialPrice?.id}, ${docRefCustomerCategSpecialPrice?.id}, ${docRefCustomerGroupItemsSpecialPrice?.id}, ${docRefCustomerGroupBrandSpecialPrice?.id}, ${docRefCustomerGroupGroupSpecialPrice?.id}, ${docRefCustomerGroupCategSpecialPrice?.id}, ${docRefCustomerPropItemsSpecialPrice?.id}, ${docRefCustomerPropBrandSpecialPrice?.id}, ${docRefCustomerPropGroupSpecialPrice?.id}, ${docRefCustomerPropCategSpecialPrice?.id}`);
          }
        
        if(systemTables === 'System'){
          if (rowsCompanies && rowsCompanies.length) {
            for (let i = 0; i < rowsCompanies.length; i++) {
  
             docRefCompanies = await admin.firestore().collection('Companies').add(rowsCompanies[i]);
              }
            }
            if (rowsDepartments && rowsDepartments.length) {
            for (let i = 0; i < rowsDepartments.length; i++) {
       
             docRefDepartments = await admin.firestore().collection('Departments').add(rowsDepartments[i]);
              }
            }
            if (rowsExchangeRate && rowsExchangeRate.length) {
            for (let i = 0; i < rowsExchangeRate.length; i++) {
        
             docRefExchangeRate = await admin.firestore().collection('ExchangeRate').add(rowsExchangeRate[i]);
              }
            }
            if (rowsCurrencies && rowsCurrencies.length) {
            for (let i = 0; i < rowsCurrencies.length; i++) {
  
             docRefCurrencies = await admin.firestore().collection('Currencies').add(rowsCurrencies[i]);
              }
            }
            if (rowsVATGroups && rowsVATGroups.length) {
            for (let i = 0; i < rowsVATGroups.length; i++) {
           
             docRefVATGroups = await admin.firestore().collection('VATGroups').add(rowsVATGroups[i]);
              }
            }
            if (rowsCustGroups && rowsCustGroups.length) {
            for (let i = 0; i < rowsCustGroups.length; i++) {
             
             docRefCustGroups = await admin.firestore().collection('CustGroups').add(rowsCustGroups[i]);
              }
            }
            if (rowsCustProperties && rowsCustProperties.length) {
            for (let i = 0; i < rowsCustProperties.length; i++) {
       
             docRefCustProperties = await admin.firestore().collection('CustProperties').add(rowsCustProperties[i]);
              }
            }
            if (rowsRegions && rowsRegions.length) {
            for (let i = 0; i < rowsRegions.length; i++) {
            
             docRefRegions = await admin.firestore().collection('Regions').add(rowsRegions[i]);
              }
            }
            if (rowsWarehouses && rowsWarehouses.length) {
            for (let i = 0; i < rowsWarehouses.length; i++) {
        
             docRefWarehouses = await admin.firestore().collection('Warehouses').add(rowsWarehouses[i]);
              }
            }
            if (rowsPaymentTerms && rowsPaymentTerms.length) {
            for (let i = 0; i < rowsPaymentTerms.length; i++) {
           
             docRefPaymentTerms = await admin.firestore().collection('PaymentTerms').add(rowsPaymentTerms[i]);
              }
            }
            if (rowsSalesEmployees && rowsSalesEmployees.length) {
            for (let i = 0; i < rowsSalesEmployees.length; i++) {
           
             docRefSalesEmployees = await admin.firestore().collection('SalesEmployees').add(rowsSalesEmployees[i]);
              }
            }
            if (rowsSalesEmployeesCustomers && rowsSalesEmployeesCustomers.length) {
            for (let i = 0; i < rowsSalesEmployeesCustomers.length; i++) {
      
             docRefSalesEmployeesCustomers = await admin.firestore().collection('SalesEmployeesCustomers').add(rowsSalesEmployeesCustomers[i]);
              }
            }
            if (rowsSalesEmployeesDepartments && rowsSalesEmployeesDepartments.length) {
            for (let i = 0; i < rowsSalesEmployeesDepartments.length; i++) {
          
             docRefSalesEmployeesDepartments = await admin.firestore().collection('SalesEmployeesDepartments').add(rowsSalesEmployeesDepartments[i]);
              }
            }
            if (rowsSalesEmployeesItemsBrands && rowsSalesEmployeesItemsBrands.length) {
            for (let i = 0; i < rowsSalesEmployeesItemsBrands.length; i++) {
              
             docRefSalesEmployeesItemsBrands = await admin.firestore().collection('SalesEmployeesItemsBrands').add(rowsSalesEmployeesItemsBrands[i]);
              }
            }
            if (rowsSalesEmployeesItemsCategories && rowsSalesEmployeesItemsCategories.length) {
            for (let i = 0; i < rowsSalesEmployeesItemsCategories.length; i++) {
            
             docRefSalesEmployeesItemsCategories = await admin.firestore().collection('SalesEmployeesItemsCategories').add(rowsSalesEmployeesItemsCategories[i]);
              }
            }
            if (rowsSalesEmployeesItemsGroups && rowsSalesEmployeesItemsGroups.length) {
            for (let i = 0; i < rowsSalesEmployeesItemsGroups.length; i++) {
  
             docRefSalesEmployeesItemsGroups = await admin.firestore().collection('SalesEmployeesItemsGroups').add(rowsSalesEmployeesItemsGroups[i]);
              }
            }
            if (rowsSalesEmployeesItems && rowsSalesEmployeesItems.length) {
            for (let i = 0; i < rowsSalesEmployeesItems.length; i++) {
        
             docRefSalesEmployeesItems = await admin.firestore().collection('SalesEmployeesItems').add(rowsSalesEmployeesItems[i]);
              }
            }
            if (rowsUsersSalesEmployees && rowsUsersSalesEmployees.length) {
            for (let i = 0; i < rowsUsersSalesEmployees.length; i++) {
            
             docRefUsersSalesEmployees = await admin.firestore().collection('UsersSalesEmployees').add(rowsUsersSalesEmployees[i]);
              }
            }
        
            console.log(`Document added to System collection with IDs: ${docRefCompanies?.id}, ${docRefDepartments?.id}, ${docRefExchangeRate?.id}, ${docRefCurrencies?.id}, ${docRefVATGroups?.id}, ${docRefCustGroups?.id}, ${docRefCustProperties?.id}, ${docRefRegions?.id}, ${docRefWarehouses?.id}, ${docRefPaymentTerms?.id}, ${docRefSalesEmployees?.id}, ${docRefSalesEmployeesCustomers?.id}, ${docRefSalesEmployeesDepartments?.id}, ${docRefSalesEmployeesItemsBrands?.id}, ${docRefSalesEmployeesItemsCategories?.id}, ${docRefSalesEmployeesItemsGroups?.id}, ${docRefSalesEmployeesItems?.id}, ${docRefUsersSalesEmployees?.id}`);
          }
        
        // Add other cases for different tables
        

        // Add other cases for different tables

      } catch (error) {
        console.error('Error adding document:', error);
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