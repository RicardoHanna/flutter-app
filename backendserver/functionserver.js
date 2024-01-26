const admin = require('firebase-admin');
const sql = require('mssql');

const path = require('path');

const serviceAccount = require('./firebasesdk.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://sales-bab47.firebaseio.com', // Update with your actual database URL
});

async function importDataToFirestore(connectionID, itemTable, priceListsTable, selectAllTables,customersTable,systemTables) {
  try {
    // Fetch user configuration from Firestore based on user's group code
    const configSnapshot = await admin.firestore().collection('CompaniesConnection').where('connectionID', '==', connectionID).get();
    console.log('Firestore Query:', `connectionID == ${connectionID?.toString()}`);
    console.log('Config Snapshot:', configSnapshot.docs.map(doc => doc.data()));
    console.log('Firestore Query:', `itemtable == ${itemTable?.toString()}`);
    console.log('Firestore Query:', `selectAllTables == ${selectAllTables?.toString()}`);
    console.log('Firestore Query:', `priceListsTable == ${priceListsTable?.toString()}`);
    console.log('Firestore Query:', `customerSTable == ${customersTable?.toString()}`);
    console.log('Firestore Query:', `systemTable == ${systemTables?.toString()}`);
    if (configSnapshot.empty) {
      console.error('User configuration not found for connection code:', connectionID);
      return;
    }

    const firstConfigDocument = configSnapshot.docs[0];
    if (!firstConfigDocument.exists) {
      console.error('Document found, but user configuration not found for connection code:', connectionID);
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

 if (itemTable === 'Items' || selectAllTables === 'selectall') {
        queryItems = `
        SELECT 
          LTRIM(RTRIM(itemCode)) AS itemCode,
          LTRIM(RTRIM(itemName)) AS itemName,
          LTRIM(RTRIM(itemPrName)) AS itemPrName,
          LTRIM(RTRIM(itemFName)) AS itemFName,
          LTRIM(RTRIM(itemPrFName)) AS itemPrFName,
          LTRIM(RTRIM(groupCode)) AS groupCode,
          LTRIM(RTRIM(categCode)) AS categCode,
          LTRIM(RTRIM(brandCode)) AS brandCode,
          LTRIM(RTRIM(itemType)) AS itemType,
          LTRIM(RTRIM(barCode)) AS barCode,
          LTRIM(RTRIM(uom)) AS uom,
          LTRIM(RTRIM(picture)) AS picture,
          LTRIM(RTRIM(remark)) AS remark,
          LTRIM(RTRIM(brand)) AS brand,
          LTRIM(RTRIM(manageBy)) AS manageBy,
          LTRIM(RTRIM(vatRate)) AS vatRate,
          LTRIM(RTRIM(active)) AS active,
          LTRIM(RTRIM(weight)) AS weight,
          LTRIM(RTRIM(charect1)) AS charect1,
          LTRIM(RTRIM(charact2)) AS charact2,
          LTRIM(RTRIM(cmpCode)) AS cmpCode
        FROM Items`;
    
    queryItemBrand = `
    SELECT 
      LTRIM(RTRIM(brandCode)) AS brandCode,
      LTRIM(RTRIM(brandName)) AS brandName,
      LTRIM(RTRIM(brandFName)) AS brandFName,
      LTRIM(RTRIM(cmpCode)) AS cmpCode
    FROM ItemBrand`;
    
    queryItemGroup = `
        SELECT 
          LTRIM(RTRIM(groupCode)) AS groupCode,
          LTRIM(RTRIM(groupName)) AS groupName,
          LTRIM(RTRIM(groupFName)) AS groupFName,
          LTRIM(RTRIM(cmpCode)) AS cmpCode
        FROM ItemGroup`;
    
        queryItemCateg = `
        SELECT 
          LTRIM(RTRIM(categCode)) AS categCode,
          LTRIM(RTRIM(categName)) AS categName,
          LTRIM(RTRIM(categFName)) AS categFName,
          LTRIM(RTRIM(cmpCode)) AS cmpCode
        FROM ItemCateg`;
    
       queryItemAttach = `
        SELECT 
          LTRIM(RTRIM(itemCode)) AS itemCode,
          LTRIM(RTRIM(attachmentType)) AS attachmentType,
          LTRIM(RTRIM(attachmentPath)) AS attachmentPath,
          LTRIM(RTRIM(note)) AS note,
          LTRIM(RTRIM(cmpCode)) AS cmpCode
        FROM ItemAttach`;
     
        queryItemUOM = `
        SELECT 
          LTRIM(RTRIM(itemCode)) AS itemCode,
          LTRIM(RTRIM(uom)) AS uom,
          LTRIM(RTRIM(qtyperUOM)) AS qtyperUOM,
          LTRIM(RTRIM(barCode)) AS barCode,
          LTRIM(RTRIM(cmpCode)) AS cmpCode
        FROM ItemUOM`;
    
        
        queryItemsPrices = `
        SELECT 
          LTRIM(RTRIM(plCode)) AS plCode,
          LTRIM(RTRIM(itemCode)) AS itemCode,
          LTRIM(RTRIM(uom)) AS uom,
          LTRIM(RTRIM(basePrice)) AS basePrice,
          LTRIM(RTRIM(currency)) AS currency,
          LTRIM(RTRIM(auto)) AS auto,
          LTRIM(RTRIM(disc)) AS disc,
          LTRIM(RTRIM(price)) AS price,
          LTRIM(RTRIM(cmpCode)) AS cmpCode
        FROM ItemsPrices`;
       }

       if (priceListsTable === 'PriceList' || selectAllTables === 'selectall') {
        queryPriceList = `
          SELECT 
            LTRIM(RTRIM(plCode)) AS plCode,
            LTRIM(RTRIM(plName)) AS plName,
            LTRIM(RTRIM(currency)) AS currency,
            LTRIM(RTRIM(basePL)) AS basePL,
            factor,
            incVAT,
            LTRIM(RTRIM(securityGroup)) AS securityGroup,
            LTRIM(RTRIM(cmpCode)) AS cmpCode
          FROM PriceList`;
      
       }

      if(customersTable==='Customers' || selectAllTables === 'selectall'){
        queryCustomers = `
        SELECT 
          LTRIM(RTRIM(cmpCode)) AS cmpCode,
          LTRIM(RTRIM(custCode)) AS custCode,
          LTRIM(RTRIM(custName)) AS custName,
          LTRIM(RTRIM(custFName)) AS custFName,
          LTRIM(RTRIM(groupCode)) AS groupCode,
          LTRIM(RTRIM(mofNum)) AS mofNum,
          LTRIM(RTRIM(barcode)) AS barcode,
          LTRIM(RTRIM(phone)) AS phone,
          LTRIM(RTRIM(mobile)) AS mobile,
          LTRIM(RTRIM(fax)) AS fax,
          LTRIM(RTRIM(website)) AS website,
          LTRIM(RTRIM(email)) AS email,
          LTRIM(RTRIM(active)) AS active,
          LTRIM(RTRIM(printLayout)) AS printLayout,
          LTRIM(RTRIM(dfltAddressID)) AS dfltAddressID,
          LTRIM(RTRIM(dfltContactID)) AS dfltContactID,
          LTRIM(RTRIM(curCode)) AS curCode,
          LTRIM(RTRIM(cashClient)) AS cashClient,
          LTRIM(RTRIM(discType)) AS discType,
          LTRIM(RTRIM(vatCode)) AS vatCode,
          LTRIM(RTRIM(prListCode)) AS prListCode,
          LTRIM(RTRIM(payTermsCode)) AS payTermsCode,
          LTRIM(RTRIM(discount)) AS discount,
          LTRIM(RTRIM(creditLimit)) AS creditLimit,
          LTRIM(RTRIM(balance)) AS balance,
          LTRIM(RTRIM(balanceDue)) AS balanceDue,
          LTRIM(RTRIM(notes)) AS notes
        FROM Customers`;
    
        queryCustomerAddresses = `
        SELECT 
          LTRIM(RTRIM(cmpCode)) AS cmpCode,
          LTRIM(RTRIM(custCode)) AS custCode,
          LTRIM(RTRIM(addressID)) AS addressID,
          LTRIM(RTRIM(address)) AS address,
          LTRIM(RTRIM(fAddress)) AS fAddress,
          LTRIM(RTRIM(regCode)) AS regCode,
          LTRIM(RTRIM(gpslat)) AS gpslat,
          LTRIM(RTRIM(gpslong)) AS gpslong,
          LTRIM(RTRIM(notes)) AS notes
        FROM CustomerAddresses`;
        
        queryCustomerContacts = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custCode)) AS custCode,
      LTRIM(RTRIM(contactID)) AS contactID,
      LTRIM(RTRIM(contactName)) AS contactName,
      LTRIM(RTRIM(contactFName)) AS contactFName,
      LTRIM(RTRIM(phone)) AS phone,
      LTRIM(RTRIM(mobile)) AS mobile,
      LTRIM(RTRIM(email)) AS email,
      LTRIM(RTRIM(position)) AS position,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerContacts`;


     queryCustomerProperties = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custCode)) AS custCode,
      LTRIM(RTRIM(propCode)) AS propCode,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerProperties`;


          queryCustomerAttachments = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custCode)) AS custCode,
      LTRIM(RTRIM(attach)) AS attach,
      LTRIM(RTRIM(notes)) AS notes,
      LTRIM(RTRIM(attachType)) AS attachType
    FROM CustomerAttachments`;


      queryCustomerItemsSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custCode)) AS custCode,
      LTRIM(RTRIM(itemCode)) AS itemCode,
      LTRIM(RTRIM(uom)) AS uom,
      basePrice,
      LTRIM(RTRIM(currency)) AS currency,
      auto,
      disc,
      price,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerItemsSpecialPrice`;

        queryCustomerBrandSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custCode)) AS custCode,
      LTRIM(RTRIM(brandCode)) AS brandCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerBrandSpecialPrice`;

      queryCustomerGroupSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custCode)) AS custCode,
      LTRIM(RTRIM(groupCode)) AS groupCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerGroupSpecialPrice`;

    queryCustomerCategSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custCode)) AS custCode,
      LTRIM(RTRIM(categCode)) AS categCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerCategSpecialPrice`;

 queryCustomerGroupItemsSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custGroupCode)) AS custGroupCode,
      LTRIM(RTRIM(itemCode)) AS itemCode,
      LTRIM(RTRIM(uom)) AS uom,
      basePrice,
      LTRIM(RTRIM(currency)) AS currency,
      auto,
      disc,
      price,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerGroupItemsSpecialPrice`;

    
    queryCustomerGroupBrandSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custGroupCode)) AS custGroupCode,
      LTRIM(RTRIM(brandCode)) AS brandCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerGroupBrandSpecialPrice`;


  queryCustomerGroupGroupSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custGroupCode)) AS custGroupCode,
      LTRIM(RTRIM(groupCode)) AS groupCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerGroupGroupSpecialPrice`;


      queryCustomerGroupCategSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custGroupCode)) AS custGroupCode,
      LTRIM(RTRIM(categCode)) AS categCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerGroupCategSpecialPrice`;


  queryCustomerPropItemsSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custPropCode)) AS custPropCode,
      LTRIM(RTRIM(itemCode)) AS itemCode,
      LTRIM(RTRIM(uom)) AS uom,
      basePrice,
      LTRIM(RTRIM(currency)) AS currency,
      auto,
      disc,
      price,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerPropItemsSpecialPrice`;


       queryCustomerPropBrandSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custPropCode)) AS custPropCode,
      LTRIM(RTRIM(brandCode)) AS brandCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerPropBrandSpecialPrice`;

         queryCustomerPropGroupSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custGroupCode)) AS custGroupCode,
      LTRIM(RTRIM(propCode)) AS propCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerPropGroupSpecialPrice`;

  queryCustomerPropCategSpecialPrice = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(custPropCode)) AS custPropCode,
      LTRIM(RTRIM(categCode)) AS categCode,
      disc,
      LTRIM(RTRIM(notes)) AS notes
    FROM CustomerPropCategSpecialPrice`;
      }

      if(systemTables==='System' || selectAllTables === 'selectall'){
        queryCompanies = `
        SELECT 
          LTRIM(RTRIM(cmpCode)) AS cmpCode,
          LTRIM(RTRIM(cmpName)) AS cmpName,
          LTRIM(RTRIM(cmpFName)) AS cmpFName,
          LTRIM(RTRIM(tel)) AS tel,
          LTRIM(RTRIM(mobile)) AS mobile,
          LTRIM(RTRIM(address)) AS address,
          LTRIM(RTRIM(fAddress)) AS fAddress,
          LTRIM(RTRIM(prHeader)) AS prHeader,
          LTRIM(RTRIM(prFHeader)) AS prFHeader,
          LTRIM(RTRIM(prFooter)) AS prFooter,
          LTRIM(RTRIM(prFFooter)) AS prFFooter,
          LTRIM(RTRIM(mainCurCode)) AS mainCurCode,
          LTRIM(RTRIM(secCurCode)) AS secCurCode,
          LTRIM(RTRIM(rateType)) AS rateType,
          LTRIM(RTRIM(issueBatchMethod)) AS issueBatchMethod,
          LTRIM(RTRIM(systemAdminID)) AS systemAdminID,
          LTRIM(RTRIM(notes)) AS notes
        FROM Companies`;
        
        queryDepartments = `
        SELECT 
          LTRIM(RTRIM(cmpCode)) AS cmpCode,
          LTRIM(RTRIM(depCode)) AS depCode,
          LTRIM(RTRIM(depName)) AS depName,
          LTRIM(RTRIM(depFName)) AS depFName,
          LTRIM(RTRIM(notes)) AS notes
        FROM Departments`;

        queryExchangeRate = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(curCode)) AS curCode,
      fDate,
      tDate,
      rate
    FROM ExchangeRate`;

    
    queryCurrencies = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(curCode)) AS curCode,
      LTRIM(RTRIM(curName)) AS curName,
      LTRIM(RTRIM(curFName)) AS curFName,
      notes
    FROM Currencies`;

queryVATGroups = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(vatCode)) AS vatCode,
      LTRIM(RTRIM(vatName)) AS vatName,
      LTRIM(RTRIM(vatRate)) AS vatRate,
      LTRIM(RTRIM(baseCurCode)) AS baseCurCode,
      notes
    FROM VATGroups`;

queryCustGroups = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(grpCode)) AS grpCode,
      LTRIM(RTRIM(grpName)) AS grpName,
      LTRIM(RTRIM(grpFName)) AS grpFName,
      notes
    FROM CustGroups`;

    
    queryCustProperties = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(propCode)) AS propCode,
      LTRIM(RTRIM(propName)) AS propName,
      LTRIM(RTRIM(propFName)) AS propFName,
      notes
    FROM CustProperties`;

    queryRegions = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(regCode)) AS regCode,
      LTRIM(RTRIM(regName)) AS regName,
      LTRIM(RTRIM(regFName)) AS regFName,
      notes
    FROM Regions`;

   queryWarehouses = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(whsCode)) AS whsCode,
      LTRIM(RTRIM(whsName)) AS whsName,
      LTRIM(RTRIM(whsFName)) AS whsFName,
      notes
    FROM Warehouses`;


        queryPaymentTerms = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(ptCode)) AS ptCode,
      LTRIM(RTRIM(ptName)) AS ptName,
      LTRIM(RTRIM(ptFName)) AS ptFName,
      startFrom,
      nbrofDays,
      notes
    FROM PaymentTerms`;

 querySalesEmployees = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(seCode)) AS seCode,
      LTRIM(RTRIM(seName)) AS seName,
      LTRIM(RTRIM(seFName)) AS seFName,
      LTRIM(RTRIM(mobile)) AS mobile,
      LTRIM(RTRIM(email)) AS email,
      LTRIM(RTRIM(whsCode)) AS whsCode,
      LTRIM(RTRIM(reqFromWhsCode)) AS reqFromWhsCode,
      notes
    FROM SalesEmployees`;

        querySalesEmployeesCustomers = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(seCode)) AS seCode,
      LTRIM(RTRIM(custCode)) AS custCode,
      notes
    FROM SalesEmployeesCustomers`;

           querySalesEmployeesDepartments = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(seCode)) AS seCode,
      LTRIM(RTRIM(deptCode)) AS deptCode,
      LTRIM(RTRIM(reqFromWhsCode)) AS reqFromWhsCode,
      notes
    FROM SalesEmployeesDepartments`;


       querySalesEmployeesItemsBrands = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(seCode)) AS seCode,
      LTRIM(RTRIM(brandCode)) AS brandCode,
      LTRIM(RTRIM(reqFromWhsCode)) AS reqFromWhsCode,
      notes
    FROM SalesEmployeesItemsBrands`;


        querySalesEmployeesItemsCategories = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(seCode)) AS seCode,
      LTRIM(RTRIM(categCode)) AS categCode,
      LTRIM(RTRIM(reqFromWhsCode)) AS reqFromWhsCode,
      notes
    FROM SalesEmployeesItemsCategories`;

         querySalesEmployeesItemsGroups = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(seCode)) AS seCode,
      LTRIM(RTRIM(groupCode)) AS groupCode,
      LTRIM(RTRIM(reqFromWhsCode)) AS reqFromWhsCode,
      notes
    FROM SalesEmployeesItemsGroups`;

      querySalesEmployeesItems = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(seCode)) AS seCode,
      LTRIM(RTRIM(itemCode)) AS itemCode,
      LTRIM(RTRIM(reqFromWhsCode)) AS reqFromWhsCode,
      notes
    FROM SalesEmployeesItems`;

 queryUsersSalesEmployees = `
    SELECT 
      LTRIM(RTRIM(cmpCode)) AS cmpCode,
      LTRIM(RTRIM(userCode)) AS userCode,
      LTRIM(RTRIM(seCode)) AS seCode,
      notes
    FROM UsersSalesEmployees`;
      }

      // Add other tables as needed
    

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

    // Function to update Firestore document when SQL Server record is updated
// Function to update Firestore document when SQL Server record is updated
async function updateFirestoreOnSqlServerUpdate(collectionName, updatedRecord, identifierFields, ...identifierValues) {
  const firestoreCollection = admin.firestore().collection(collectionName);

  // Construct the where clause for the query, excluding undefined values
  let query = firestoreCollection;
  for (let i = 0; i < identifierFields.length; i++) {
    if (identifierValues[i] !== undefined) {
      query = query.where(identifierFields[i], '==', identifierValues[i]);
    }
  }

  // Query Firestore to find the document with matching identifier fields and values
  const querySnapshot = await query.get();

  if (!querySnapshot.empty) {
    // Document exists, update the first matching document
    const firestoreDocument = querySnapshot.docs[0].ref;
    await firestoreDocument.update(updatedRecord);
  } else {
    // Document doesn't exist, add it
    await admin.firestore().collection(collectionName).add({ ...updatedRecord });
  }
}

async function deleteFirestoreOnSqlServerDelete(collectionName, identifierFields, ...identifierValues) {
  const firestoreCollection = admin.firestore().collection(collectionName);

  // Construct the where clause for the query, excluding undefined values
  let query = firestoreCollection;
  for (let i = 0; i < identifierFields.length; i++) {
    if (identifierValues[i] !== undefined) {
      query = query.where(identifierFields[i], '==', identifierValues[i]);
      console.log(identifierFields[i]);
      console.log(identifierValues[i]);
    }
  }

  // Query Firestore to find the document with matching identifier fields and values
  const querySnapshot = await query.get();

  for (const doc of querySnapshot.docs) {
    await doc.ref.delete();
  }
}

// Helper function to construct an object from identifier fields and values
function constructObject(fields, values) {
  const result = {};
  for (let i = 0; i < fields.length; i++) {
    if (values[i] !== undefined) {
      result[fields[i]] = values[i];
    }
  }
  return result;
}






      try {
        if (selectAllTables === 'selectall') {
         selectALL();
        }


        if (itemTable === 'Items') {
          if (rowsItems && rowsItems.length) {
            const identifierFieldItems = 'itemCode'; // Change this to the correct identifier field for 'Items'
            let identifierValues = []; // Array to store identifier values for documents in Firestore
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsItems.length; i++) {
              const updatedRecord = rowsItems[i];
              const identifierValue = updatedRecord.itemCode; // Assuming 'itemCode' is the identifier value for 'Items'
          
              identifierValues.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('Items', updatedRecord, identifierFieldItems, identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollection = admin.firestore().collection('Items');
            const firestoreQuery = await firestoreCollection.get();
            const firestoreDocuments = firestoreQuery.docs.map(doc => doc.data());
            
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDelete = firestoreDocuments.filter(doc => !identifierValues.includes(doc[identifierFieldItems]));
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDelete) {
              await deleteFirestoreOnSqlServerDelete('Items', identifierFieldItems, docToDelete[identifierFieldItems]);
            }
          } else {
            // Handle the case where there are no rowsItems from SQL Server
            console.error('No data retrieved from SQL Server.');
          }
         
          
   // Example for 'ItemPrices'
   if (rowsItemPrices && rowsItemPrices.length) {
    const identifierFieldsItemPrices = ['plCode', 'itemCode'];
    let identifierValuesItemPrices = [];
  
    // Update or add documents in Firestore
    for (let i = 0; i < rowsItemPrices.length; i++) {
      const updatedRecord = rowsItemPrices[i];
      const identifierValue = [updatedRecord.plCode, updatedRecord.itemCode];
  
      identifierValuesItemPrices.push(identifierValue);
  
      // Update or add the document in Firestore
      await updateFirestoreOnSqlServerUpdate('ItemsPrices', updatedRecord, identifierFieldsItemPrices, ...identifierValue);
    }
  
    // Fetch documents from Firestore
    const firestoreCollectionItemPrices = admin.firestore().collection('ItemsPrices');
    const firestoreQueryItemPrices = await firestoreCollectionItemPrices.get();
    const firestoreDocumentsItemPrices = firestoreQueryItemPrices.docs.map(doc => doc.data());
  
    // Identify documents in Firestore that are not in SQL Server results
    const documentsToDeleteItemPrices = firestoreDocumentsItemPrices.filter(doc =>
      !identifierValuesItemPrices.some(values =>
        identifierFieldsItemPrices.every((field, index) => values[index] === doc[field])
      )
    );
  
    // Delete Firestore documents that are not in SQL Server results
    for (const docToDelete of documentsToDeleteItemPrices) {
      const identifierValuesToDelete = identifierFieldsItemPrices.map(field => docToDelete[field]);
      await deleteFirestoreOnSqlServerDelete('ItemsPrices', identifierFieldsItemPrices, ...identifierValuesToDelete);
    }
  }
  
  

if (rowsItemBrand && rowsItemBrand.length) {
  const identifierFieldItemBrand = 'brandCode'; // Change this to the correct identifier field for 'ItemBrand'
  let identifierValuesItemBrand = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsItemBrand.length; i++) {
    const updatedRecord = rowsItemBrand[i];
    const identifierValue = updatedRecord.brandCode; // Assuming 'brandCode' is the identifier field for 'ItemBrand'

    identifierValuesItemBrand.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('ItemBrand', updatedRecord, identifierFieldItemBrand, identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionItemBrand = admin.firestore().collection('ItemBrand');
  const firestoreQueryItemBrand = await firestoreCollectionItemBrand.get();
  const firestoreDocumentsItemBrand = firestoreQueryItemBrand.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteItemBrand = firestoreDocumentsItemBrand.filter(doc =>
    !identifierValuesItemBrand.includes(doc[identifierFieldItemBrand])
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteItemBrand) {
    await deleteFirestoreOnSqlServerDelete('ItemBrand', identifierFieldItemBrand, docToDelete[identifierFieldItemBrand]);
  }
}

if (rowsItemCateg && rowsItemCateg.length) {
  const identifierFieldItemCateg = 'categCode'; // Change this to the correct identifier field for 'ItemCateg'
  let identifierValuesItemCateg = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsItemCateg.length; i++) {
    const updatedRecord = rowsItemCateg[i];
    const identifierValue = updatedRecord.categCode; // Assuming 'categCode' is the identifier field for 'ItemCateg'

    identifierValuesItemCateg.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('ItemCateg', updatedRecord, identifierFieldItemCateg, identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionItemCateg = admin.firestore().collection('ItemCateg');
  const firestoreQueryItemCateg = await firestoreCollectionItemCateg.get();
  const firestoreDocumentsItemCateg = firestoreQueryItemCateg.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteItemCateg = firestoreDocumentsItemCateg.filter(doc =>
    !identifierValuesItemCateg.includes(doc[identifierFieldItemCateg])
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteItemCateg) {
    await deleteFirestoreOnSqlServerDelete('ItemCateg', identifierFieldItemCateg, docToDelete[identifierFieldItemCateg]);
  }
}

if (rowsItemAttach && rowsItemAttach.length) {
  const identifierFieldItemAttach = 'attachmentPath'; // Change this to the correct identifier field for 'ItemAttach'
  let identifierValuesItemAttach = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsItemAttach.length; i++) {
    const updatedRecord = rowsItemAttach[i];
    const identifierValue = updatedRecord.attachmentPath; // Assuming 'attachmentPath' is the identifier field for 'ItemAttach'

    identifierValuesItemAttach.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('ItemAttach', updatedRecord, identifierFieldItemAttach, identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionItemAttach = admin.firestore().collection('ItemAttach');
  const firestoreQueryItemAttach = await firestoreCollectionItemAttach.get();
  const firestoreDocumentsItemAttach = firestoreQueryItemAttach.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteItemAttach = firestoreDocumentsItemAttach.filter(doc =>
    !identifierValuesItemAttach.includes(doc[identifierFieldItemAttach])
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteItemAttach) {
    await deleteFirestoreOnSqlServerDelete('ItemAttach', identifierFieldItemAttach, docToDelete[identifierFieldItemAttach]);
  }
}

if (rowsItemGroup && rowsItemGroup.length) {
  const identifierFieldItemGroup = 'groupCode'; // Change this to the correct identifier field for 'ItemGroup'
  let identifierValuesItemGroup = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsItemGroup.length; i++) {
    const updatedRecord = rowsItemGroup[i];
    const identifierValue = updatedRecord.groupCode; // Assuming 'groupCode' is the identifier field for 'ItemGroup'

    identifierValuesItemGroup.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('ItemGroup', updatedRecord, identifierFieldItemGroup, identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionItemGroup = admin.firestore().collection('ItemGroup');
  const firestoreQueryItemGroup = await firestoreCollectionItemGroup.get();
  const firestoreDocumentsItemGroup = firestoreQueryItemGroup.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteItemGroup = firestoreDocumentsItemGroup.filter(doc =>
    !identifierValuesItemGroup.includes(doc[identifierFieldItemGroup])
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteItemGroup) {
    await deleteFirestoreOnSqlServerDelete('ItemGroup', identifierFieldItemGroup, docToDelete[identifierFieldItemGroup]);
  }
}

if (rowsItemUOM && rowsItemUOM.length) {
  const identifierFieldItemUOM = 'uom'; // Change this to the correct identifier field for 'ItemUOM'
  let identifierValuesItemUOM = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsItemUOM.length; i++) {
    const updatedRecord = rowsItemUOM[i];
    const identifierValue = updatedRecord[identifierFieldItemUOM]; // Assuming 'uom' is the identifier field for 'ItemUOM'

    identifierValuesItemUOM.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('ItemUOM', updatedRecord, [identifierFieldItemUOM], identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionItemUOM = admin.firestore().collection('ItemUOM');
  const firestoreQueryItemUOM = await firestoreCollectionItemUOM.get();
  const firestoreDocumentsItemUOM = firestoreQueryItemUOM.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteItemUOM = firestoreDocumentsItemUOM.filter(doc =>
    !identifierValuesItemUOM.includes(doc[identifierFieldItemUOM])
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteItemUOM) {
    await deleteFirestoreOnSqlServerDelete('ItemUOM', [identifierFieldItemUOM], docToDelete[identifierFieldItemUOM]);
  }
}



          console.log(`Document added to Items collection with IDs: ${docRefItems?.id}, ${docRefItemPrices?.id}, ${docRefItemBrand?.id}, ${docRefItemCateg?.id}, ${docRefItemAttach?.id}, ${docRefItemGroup?.id}, ${docRefItemUOM?.id}`);
        }
      
    

        if (priceListsTable === 'PriceList') {
          if (rowsPriceList && rowsPriceList.length) {
            const identifierFieldPriceLists = 'plCode'; // Change this to the correct identifier field for 'PriceLists'
            let identifierValuesPriceLists = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsPriceList.length; i++) {
              const updatedRecord = rowsPriceList[i];
              const identifierValue = updatedRecord[identifierFieldPriceLists] // Assuming 'plCode' is the identifier field for 'PriceLists'
          
              identifierValuesPriceLists.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('PriceList', updatedRecord, [identifierFieldPriceLists], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionPriceLists = admin.firestore().collection('PriceList');
            const firestoreQueryPriceLists = await firestoreCollectionPriceLists.get();
            const firestoreDocumentsPriceLists = firestoreQueryPriceLists.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeletePriceLists = firestoreDocumentsPriceLists.filter(doc =>
              !identifierValuesPriceLists.includes(doc[identifierFieldPriceLists])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeletePriceLists) {
              await deleteFirestoreOnSqlServerDelete('PriceList', [identifierFieldPriceLists], docToDelete[identifierFieldPriceLists]);
            }
          }
          
        }

        if(customersTable === 'Customers'){
          if (rowsCustomers && rowsCustomers.length) {
            const identifierFieldCustomers = 'custCode'; // Change this to the correct identifier field for 'Customers'
            let identifierValuesCustomers = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomers.length; i++) {
              const updatedRecord = rowsCustomers[i];
              const identifierValue = updatedRecord[identifierFieldCustomers]; // Assuming 'custCode' is the identifier field for 'Customers'
          
              identifierValuesCustomers.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('Customers', updatedRecord, [identifierFieldCustomers], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomers = admin.firestore().collection('Customers');
            const firestoreQueryCustomers = await firestoreCollectionCustomers.get();
            const firestoreDocumentsCustomers = firestoreQueryCustomers.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomers = firestoreDocumentsCustomers.filter(doc =>
              !identifierValuesCustomers.includes(doc[identifierFieldCustomers])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomers) {
              await deleteFirestoreOnSqlServerDelete('Customers', [identifierFieldCustomers], docToDelete[identifierFieldCustomers]);
            }
          }
          
          if (rowsCustomerAddresses && rowsCustomerAddresses.length) {
            const identifierFieldCustomerAddresses = 'addressID'; // Change this to the correct identifier field for 'CustomerAddresses'
            let identifierValuesCustomerAddresses = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerAddresses.length; i++) {
              const updatedRecord = rowsCustomerAddresses[i];
              const identifierValue = updatedRecord[identifierFieldCustomerAddresses]; // Assuming 'addressID' is the identifier field for 'CustomerAddresses'
          
              identifierValuesCustomerAddresses.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerAddresses', updatedRecord, [identifierFieldCustomerAddresses], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerAddresses = admin.firestore().collection('CustomerAddresses');
            const firestoreQueryCustomerAddresses = await firestoreCollectionCustomerAddresses.get();
            const firestoreDocumentsCustomerAddresses = firestoreQueryCustomerAddresses.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerAddresses = firestoreDocumentsCustomerAddresses.filter(doc =>
              !identifierValuesCustomerAddresses.includes(doc[identifierFieldCustomerAddresses])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerAddresses) {
              await deleteFirestoreOnSqlServerDelete('CustomerAddresses', [identifierFieldCustomerAddresses], docToDelete[identifierFieldCustomerAddresses]);
            }
          }
          
          if (rowsCustomerContacts && rowsCustomerContacts.length) {
            const identifierFieldCustomerContacts = 'contactID'; // Change this to the correct identifier field for 'CustomerContacts'
            let identifierValuesCustomerContacts = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerContacts.length; i++) {
              const updatedRecord = rowsCustomerContacts[i];
              const identifierValue = updatedRecord[identifierFieldCustomerContacts]; // Assuming 'contactID' is the identifier field for 'CustomerContacts'
          
              identifierValuesCustomerContacts.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerContacts', updatedRecord, [identifierFieldCustomerContacts], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerContacts = admin.firestore().collection('CustomerContacts');
            const firestoreQueryCustomerContacts = await firestoreCollectionCustomerContacts.get();
            const firestoreDocumentsCustomerContacts = firestoreQueryCustomerContacts.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerContacts = firestoreDocumentsCustomerContacts.filter(doc =>
              !identifierValuesCustomerContacts.includes(doc[identifierFieldCustomerContacts])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerContacts) {
              await deleteFirestoreOnSqlServerDelete('CustomerContacts', [identifierFieldCustomerContacts], docToDelete[identifierFieldCustomerContacts]);
            }
          }
          
          if (rowsCustomerProperties && rowsCustomerProperties.length) {
            const identifierFieldCustomerProperties = 'propCode'; // Change this to the correct identifier field for 'CustomerProperties'
            let identifierValuesCustomerProperties = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerProperties.length; i++) {
              const updatedRecord = rowsCustomerProperties[i];
              const identifierValue = updatedRecord[identifierFieldCustomerProperties]; // Assuming 'propCode' is the identifier field for 'CustomerProperties'
          
              identifierValuesCustomerProperties.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerProperties', updatedRecord, [identifierFieldCustomerProperties], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerProperties = admin.firestore().collection('CustomerProperties');
            const firestoreQueryCustomerProperties = await firestoreCollectionCustomerProperties.get();
            const firestoreDocumentsCustomerProperties = firestoreQueryCustomerProperties.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerProperties = firestoreDocumentsCustomerProperties.filter(doc =>
              !identifierValuesCustomerProperties.includes(doc[identifierFieldCustomerProperties])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerProperties) {
              await deleteFirestoreOnSqlServerDelete('CustomerProperties', [identifierFieldCustomerProperties], docToDelete[identifierFieldCustomerProperties]);
            }
          }
          
          if (rowsCustomerAttachments && rowsCustomerAttachments.length) {
            const identifierFieldCustomerAttachments = 'attach'; // Change this to the correct identifier field for 'CustomerAttachments'
            let identifierValuesCustomerAttachments = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerAttachments.length; i++) {
              const updatedRecord = rowsCustomerAttachments[i];
            const identifierFieldCustomerAttachments = 'attach'; // Change this to the correct identifier field for 'CustomerAttachments'
              const identifierValue = updatedRecord[identifierFieldCustomerAttachments]; // Assuming 'attach' is the identifier field for 'CustomerAttachments'
          
              identifierValuesCustomerAttachments.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerAttachments', updatedRecord, [identifierFieldCustomerAttachments], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerAttachments = admin.firestore().collection('CustomerAttachments');
            const firestoreQueryCustomerAttachments = await firestoreCollectionCustomerAttachments.get();
            const firestoreDocumentsCustomerAttachments = firestoreQueryCustomerAttachments.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerAttachments = firestoreDocumentsCustomerAttachments.filter(doc =>
              !identifierValuesCustomerAttachments.includes(doc[identifierFieldCustomerAttachments])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerAttachments) {
              await deleteFirestoreOnSqlServerDelete('CustomerAttachments', [identifierFieldCustomerAttachments], docToDelete[identifierFieldCustomerAttachments]);
            }
          }
          
          if (rowsCustomerItemsSpecialPrice && rowsCustomerItemsSpecialPrice.length) {
            const identifierFieldsCustomerItemsSpecialPrice = ['itemCode', 'cmpCode', 'custCode', 'uom']; // Change this to the correct identifier fields for 'CustomerItemsSpecialPrice'
            let identifierValuesCustomerItemsSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerItemsSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerItemsSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.itemCode,updatedRecord.cmpCode,updatedRecord.custCode,updatedRecord.uom]
          
              identifierValuesCustomerItemsSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerItemsSpecialPrice', updatedRecord, identifierFieldsCustomerItemsSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerItemsSpecialPrice = admin.firestore().collection('CustomerItemsSpecialPrice');
            const firestoreQueryCustomerItemsSpecialPrice = await firestoreCollectionCustomerItemsSpecialPrice.get();
            const firestoreDocumentsCustomerItemsSpecialPrice = firestoreQueryCustomerItemsSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerItemsSpecialPrice = firestoreDocumentsCustomerItemsSpecialPrice.filter(doc =>
              !identifierValuesCustomerItemsSpecialPrice.some(values =>
                identifierFieldsCustomerItemsSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerItemsSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerItemsSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerItemsSpecialPrice', identifierFieldsCustomerItemsSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerBrandSpecialPrice && rowsCustomerBrandSpecialPrice.length) {
            const identifierFieldsCustomerBrandSpecialPrice = ['brandCode', 'cmpCode', 'custCode']; // Change this to the correct identifier fields for 'CustomerBrandSpecialPrice'
            let identifierValuesCustomerBrandSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerBrandSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerBrandSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.brandCode,updatedRecord.cmpCode,updatedRecord.custCode]
          
              identifierValuesCustomerBrandSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerBrandSpecialPrice', updatedRecord, identifierFieldsCustomerBrandSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerBrandSpecialPrice = admin.firestore().collection('CustomerBrandSpecialPrice');
            const firestoreQueryCustomerBrandSpecialPrice = await firestoreCollectionCustomerBrandSpecialPrice.get();
            const firestoreDocumentsCustomerBrandSpecialPrice = firestoreQueryCustomerBrandSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerBrandSpecialPrice = firestoreDocumentsCustomerBrandSpecialPrice.filter(doc =>
              !identifierValuesCustomerBrandSpecialPrice.some(values =>
                identifierFieldsCustomerBrandSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerBrandSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerBrandSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerBrandSpecialPrice', identifierFieldsCustomerBrandSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerGroupSpecialPrice && rowsCustomerGroupSpecialPrice.length) {
            const identifierFieldsCustomerGroupSpecialPrice = ['groupCode', 'cmpCode', 'custCode']; // Change this to the correct identifier fields for 'CustomerGroupSpecialPrice'
            let identifierValuesCustomerGroupSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerGroupSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerGroupSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.groupCode,updatedRecord.cmpCode,updatedRecord.custCode];
          
              identifierValuesCustomerGroupSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerGroupSpecialPrice', updatedRecord, identifierFieldsCustomerGroupSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerGroupSpecialPrice = admin.firestore().collection('CustomerGroupSpecialPrice');
            const firestoreQueryCustomerGroupSpecialPrice = await firestoreCollectionCustomerGroupSpecialPrice.get();
            const firestoreDocumentsCustomerGroupSpecialPrice = firestoreQueryCustomerGroupSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerGroupSpecialPrice = firestoreDocumentsCustomerGroupSpecialPrice.filter(doc =>
              !identifierValuesCustomerGroupSpecialPrice.some(values =>
                identifierFieldsCustomerGroupSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerGroupSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerGroupSpecialPrice', identifierFieldsCustomerGroupSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerCategSpecialPrice && rowsCustomerCategSpecialPrice.length) {
            const identifierFieldsCustomerCategSpecialPrice = ['categCode', 'cmpCode', 'custCode']; // Change this to the correct identifier fields for 'CustomerCategSpecialPrice'
            let identifierValuesCustomerCategSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerCategSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerCategSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.categCode , updatedRecord.cmpCode , updatedRecord.custCode];
          
              identifierValuesCustomerCategSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerCategSpecialPrice', updatedRecord, identifierFieldsCustomerCategSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerCategSpecialPrice = admin.firestore().collection('CustomerCategSpecialPrice');
            const firestoreQueryCustomerCategSpecialPrice = await firestoreCollectionCustomerCategSpecialPrice.get();
            const firestoreDocumentsCustomerCategSpecialPrice = firestoreQueryCustomerCategSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerCategSpecialPrice = firestoreDocumentsCustomerCategSpecialPrice.filter(doc =>
              !identifierValuesCustomerCategSpecialPrice.some(values =>
                identifierFieldsCustomerCategSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerCategSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerCategSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerCategSpecialPrice', identifierFieldsCustomerCategSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerGroupItemsSpecialPrice && rowsCustomerGroupItemsSpecialPrice.length) {
            const identifierFieldsCustomerGroupItemsSpecialPrice = ['cmpCode', 'custGroupCode', 'itemCode', 'uom']; // Change this to the correct identifier fields for 'CustomerGroupItemsSpecialPrice'
            let identifierValuesCustomerGroupItemsSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerGroupItemsSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerGroupItemsSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.itemCode , updatedRecord.uom];
          
              identifierValuesCustomerGroupItemsSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerGroupItemsSpecialPrice', updatedRecord, identifierFieldsCustomerGroupItemsSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerGroupItemsSpecialPrice = admin.firestore().collection('CustomerGroupItemsSpecialPrice');
            const firestoreQueryCustomerGroupItemsSpecialPrice = await firestoreCollectionCustomerGroupItemsSpecialPrice.get();
            const firestoreDocumentsCustomerGroupItemsSpecialPrice = firestoreQueryCustomerGroupItemsSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerGroupItemsSpecialPrice = firestoreDocumentsCustomerGroupItemsSpecialPrice.filter(doc =>
              !identifierValuesCustomerGroupItemsSpecialPrice.some(values =>
                identifierFieldsCustomerGroupItemsSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerGroupItemsSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupItemsSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerGroupItemsSpecialPrice', identifierFieldsCustomerGroupItemsSpecialPrice, compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerGroupBrandSpecialPrice && rowsCustomerGroupBrandSpecialPrice.length) {
            const identifierFieldsCustomerGroupBrandSpecialPrice = ['cmpCode', 'custGroupCode', 'brandCode']; // Change this to the correct identifier fields for 'CustomerGroupBrandSpecialPrice'
            let identifierValuesCustomerGroupBrandSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerGroupBrandSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerGroupBrandSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.brandCode];
          
              identifierValuesCustomerGroupBrandSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerGroupBrandSpecialPrice', updatedRecord, identifierFieldsCustomerGroupBrandSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerGroupBrandSpecialPrice = admin.firestore().collection('CustomerGroupBrandSpecialPrice');
            const firestoreQueryCustomerGroupBrandSpecialPrice = await firestoreCollectionCustomerGroupBrandSpecialPrice.get();
            const firestoreDocumentsCustomerGroupBrandSpecialPrice = firestoreQueryCustomerGroupBrandSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerGroupBrandSpecialPrice = firestoreDocumentsCustomerGroupBrandSpecialPrice.filter(doc =>
              !identifierValuesCustomerGroupBrandSpecialPrice.some(values =>
                identifierFieldsCustomerGroupBrandSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerGroupBrandSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupBrandSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerGroupBrandSpecialPrice', identifierFieldsCustomerGroupBrandSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerGroupGroupSpecialPrice && rowsCustomerGroupGroupSpecialPrice.length) {
            const identifierFieldsCustomerGroupGroupSpecialPrice = ['cmpCode', 'custGroupCode', 'groupCode']; // Change this to the correct identifier fields for 'CustomerGroupGroupSpecialPrice'
            let identifierValuesCustomerGroupGroupSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerGroupGroupSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerGroupGroupSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.groupCode];
          
              identifierValuesCustomerGroupGroupSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerGroupGroupSpecialPrice', updatedRecord, identifierFieldsCustomerGroupGroupSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerGroupGroupSpecialPrice = admin.firestore().collection('CustomerGroupGroupSpecialPrice');
            const firestoreQueryCustomerGroupGroupSpecialPrice = await firestoreCollectionCustomerGroupGroupSpecialPrice.get();
            const firestoreDocumentsCustomerGroupGroupSpecialPrice = firestoreQueryCustomerGroupGroupSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerGroupGroupSpecialPrice = firestoreDocumentsCustomerGroupGroupSpecialPrice.filter(doc =>
              !identifierValuesCustomerGroupGroupSpecialPrice.some(values =>
                identifierFieldsCustomerGroupGroupSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerGroupGroupSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupGroupSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerGroupGroupSpecialPrice', identifierFieldsCustomerGroupGroupSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerGroupCategSpecialPrice && rowsCustomerGroupCategSpecialPrice.length) {
            const identifierFieldsCustomerGroupCategSpecialPrice = ['cmpCode', 'custGroupCode', 'categCode']; // Change this to the correct identifier fields for 'CustomerGroupCategSpecialPrice'
            let identifierValuesCustomerGroupCategSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerGroupCategSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerGroupCategSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.categCode];
          
              identifierValuesCustomerGroupCategSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerGroupCategSpecialPrice', updatedRecord, identifierFieldsCustomerGroupCategSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerGroupCategSpecialPrice = admin.firestore().collection('CustomerGroupCategSpecialPrice');
            const firestoreQueryCustomerGroupCategSpecialPrice = await firestoreCollectionCustomerGroupCategSpecialPrice.get();
            const firestoreDocumentsCustomerGroupCategSpecialPrice = firestoreQueryCustomerGroupCategSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerGroupCategSpecialPrice = firestoreDocumentsCustomerGroupCategSpecialPrice.filter(doc =>
              !identifierValuesCustomerGroupCategSpecialPrice.some(values =>
                identifierFieldsCustomerGroupCategSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerGroupCategSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupCategSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerGroupCategSpecialPrice', identifierFieldsCustomerGroupCategSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerPropItemsSpecialPrice && rowsCustomerPropItemsSpecialPrice.length) {
            const identifierFieldsCustomerPropItemsSpecialPrice = ['cmpCode', 'custPropCode', 'itemCode', 'uom']; // Change this to the correct identifier fields for 'CustomerPropItemsSpecialPrice'
            let identifierValuesCustomerPropItemsSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerPropItemsSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerPropItemsSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.itemCode , updatedRecord.uom];
          
              identifierValuesCustomerPropItemsSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerPropItemsSpecialPrice', updatedRecord, identifierFieldsCustomerPropItemsSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerPropItemsSpecialPrice = admin.firestore().collection('CustomerPropItemsSpecialPrice');
            const firestoreQueryCustomerPropItemsSpecialPrice = await firestoreCollectionCustomerPropItemsSpecialPrice.get();
            const firestoreDocumentsCustomerPropItemsSpecialPrice = firestoreQueryCustomerPropItemsSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerPropItemsSpecialPrice = firestoreDocumentsCustomerPropItemsSpecialPrice.filter(doc =>
              !identifierValuesCustomerPropItemsSpecialPrice.some(values =>
                identifierFieldsCustomerPropItemsSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerPropItemsSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerPropItemsSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerPropItemsSpecialPrice', identifierFieldsCustomerPropItemsSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerPropBrandSpecialPrice && rowsCustomerPropBrandSpecialPrice.length) {
            const identifierFieldsCustomerPropBrandSpecialPrice = ['cmpCode', 'custPropCode', 'brandCode']; // Change this to the correct identifier fields for 'CustomerPropBrandSpecialPrice'
            let identifierValuesCustomerPropBrandSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerPropBrandSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerPropBrandSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custPropCode , updatedRecord.brandCode];
          
              identifierValuesCustomerPropBrandSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerPropBrandSpecialPrice', updatedRecord, identifierFieldsCustomerPropBrandSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerPropBrandSpecialPrice = admin.firestore().collection('CustomerPropBrandSpecialPrice');
            const firestoreQueryCustomerPropBrandSpecialPrice = await firestoreCollectionCustomerPropBrandSpecialPrice.get();
            const firestoreDocumentsCustomerPropBrandSpecialPrice = firestoreQueryCustomerPropBrandSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerPropBrandSpecialPrice = firestoreDocumentsCustomerPropBrandSpecialPrice.filter(doc =>
              !identifierValuesCustomerPropBrandSpecialPrice.some(values =>
                identifierFieldsCustomerPropBrandSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerPropBrandSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerPropBrandSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerPropBrandSpecialPrice', identifierFieldsCustomerPropBrandSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerPropGroupSpecialPrice && rowsCustomerPropGroupSpecialPrice.length) {
            const identifierFieldsCustomerPropGroupSpecialPrice = ['cmpCode', 'custGroupCode', 'propCode']; // Change this to the correct identifier fields for 'CustomerPropGroupSpecialPrice'
            let identifierValuesCustomerPropGroupSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerPropGroupSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerPropGroupSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.propCode];
          
              identifierValuesCustomerPropGroupSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerPropGroupSpecialPrice', updatedRecord, identifierFieldsCustomerPropGroupSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerPropGroupSpecialPrice = admin.firestore().collection('CustomerPropGroupSpecialPrice');
            const firestoreQueryCustomerPropGroupSpecialPrice = await firestoreCollectionCustomerPropGroupSpecialPrice.get();
            const firestoreDocumentsCustomerPropGroupSpecialPrice = firestoreQueryCustomerPropGroupSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerPropGroupSpecialPrice = firestoreDocumentsCustomerPropGroupSpecialPrice.filter(doc =>
              !identifierValuesCustomerPropGroupSpecialPrice.some(values =>
                identifierFieldsCustomerPropGroupSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerPropGroupSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerPropGroupSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerPropGroupSpecialPrice', identifierFieldsCustomerPropGroupSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
          if (rowsCustomerPropCategSpecialPrice && rowsCustomerPropCategSpecialPrice.length) {
            const identifierFieldsCustomerPropCategSpecialPrice = ['cmpCode', 'custPropCode', 'categCode']; // Change this to the correct identifier fields for 'CustomerPropCategSpecialPrice'
            let identifierValuesCustomerPropCategSpecialPrice = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustomerPropCategSpecialPrice.length; i++) {
              const updatedRecord = rowsCustomerPropCategSpecialPrice[i];
              const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custPropCode , updatedRecord.categCode];
          
              identifierValuesCustomerPropCategSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustomerPropCategSpecialPrice', updatedRecord, identifierFieldsCustomerPropCategSpecialPrice, ...compositeIdentifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustomerPropCategSpecialPrice = admin.firestore().collection('CustomerPropCategSpecialPrice');
            const firestoreQueryCustomerPropCategSpecialPrice = await firestoreCollectionCustomerPropCategSpecialPrice.get();
            const firestoreDocumentsCustomerPropCategSpecialPrice = firestoreQueryCustomerPropCategSpecialPrice.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustomerPropCategSpecialPrice = firestoreDocumentsCustomerPropCategSpecialPrice.filter(doc =>
              !identifierValuesCustomerPropCategSpecialPrice.some(values =>
                identifierFieldsCustomerPropCategSpecialPrice.every((field, index) => values[index] === doc[field]))
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustomerPropCategSpecialPrice) {
              const compositeIdentifierValueToDelete = identifierFieldsCustomerPropCategSpecialPrice.map(field => docToDelete[field]);
              await deleteFirestoreOnSqlServerDelete('CustomerPropCategSpecialPrice', identifierFieldsCustomerPropCategSpecialPrice, ...compositeIdentifierValueToDelete);
            }
          }
          
        
            console.log(`Document added to Customers collection with IDs: ${docRefCustomers?.id}, ${docRefCustomerAddresses?.id}, ${docRefCustomerContacts?.id}, ${docRefCustomerProperties?.id}, ${docRefCustomerAttachments?.id}, ${docRefCustomerItemsSpecialPrice?.id}, ${docRefCustomerBrandSpecialPrice?.id}, ${docRefCustomerGroupSpecialPrice?.id}, ${docRefCustomerCategSpecialPrice?.id}, ${docRefCustomerGroupItemsSpecialPrice?.id}, ${docRefCustomerGroupBrandSpecialPrice?.id}, ${docRefCustomerGroupGroupSpecialPrice?.id}, ${docRefCustomerGroupCategSpecialPrice?.id}, ${docRefCustomerPropItemsSpecialPrice?.id}, ${docRefCustomerPropBrandSpecialPrice?.id}, ${docRefCustomerPropGroupSpecialPrice?.id}, ${docRefCustomerPropCategSpecialPrice?.id}`);
          }
        
        if(systemTables === 'System' ){
          if (rowsCompanies && rowsCompanies.length) {
            const identifierFieldCompanies = 'cmpCode'; // Change this to the correct identifier field for 'Companies'
            let identifierValuesCompanies = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCompanies.length; i++) {
              const updatedRecord = rowsCompanies[i];
              const identifierValue = updatedRecord[identifierFieldCompanies]; // Assuming 'cmpCode' is the identifier value for 'Companies'
          
              identifierValuesCompanies.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('Companies', updatedRecord, [identifierFieldCompanies], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCompanies = admin.firestore().collection('Companies');
            const firestoreQueryCompanies = await firestoreCollectionCompanies.get();
            const firestoreDocumentsCompanies = firestoreQueryCompanies.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCompanies = firestoreDocumentsCompanies.filter(doc =>
              !identifierValuesCompanies.includes(doc[identifierFieldCompanies])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCompanies) {
              await deleteFirestoreOnSqlServerDelete('Companies', [identifierFieldCompanies], docToDelete[identifierFieldCompanies]);
            }
          }
          
          if (rowsDepartments && rowsDepartments.length) {
            const identifierFieldDepartments = 'depCode'; // Change this to the correct identifier field for 'Departments'
            let identifierValuesDepartments = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsDepartments.length; i++) {
              const updatedRecord = rowsDepartments[i];
              const identifierValue = updatedRecord[identifierFieldDepartments]; // Assuming 'depCode' is the identifier value for 'Departments'
          
              identifierValuesDepartments.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('Departments', updatedRecord, [identifierFieldDepartments], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionDepartments = admin.firestore().collection('Departments');
            const firestoreQueryDepartments = await firestoreCollectionDepartments.get();
            const firestoreDocumentsDepartments = firestoreQueryDepartments.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteDepartments = firestoreDocumentsDepartments.filter(doc =>
              !identifierValuesDepartments.includes(doc[identifierFieldDepartments])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteDepartments) {
              await deleteFirestoreOnSqlServerDelete('Departments', [identifierFieldDepartments], docToDelete[identifierFieldDepartments]);
            }
          }
          
          if (rowsExchangeRate && rowsExchangeRate.length) {
            const identifierFieldExchangeRate = 'curCode'; // Change this to the correct identifier field for 'ExchangeRate'
            let identifierValuesExchangeRate = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsExchangeRate.length; i++) {
              const updatedRecord = rowsExchangeRate[i];
              const identifierValue = updatedRecord[identifierFieldExchangeRate]; // Assuming 'curCode' is the identifier value for 'ExchangeRate'
          
              identifierValuesExchangeRate.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('ExchangeRate', updatedRecord, [identifierFieldExchangeRate], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionExchangeRate = admin.firestore().collection('ExchangeRate');
            const firestoreQueryExchangeRate = await firestoreCollectionExchangeRate.get();
            const firestoreDocumentsExchangeRate = firestoreQueryExchangeRate.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteExchangeRate = firestoreDocumentsExchangeRate.filter(doc =>
              !identifierValuesExchangeRate.includes(doc[identifierFieldExchangeRate])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteExchangeRate) {
              await deleteFirestoreOnSqlServerDelete('ExchangeRate', [identifierFieldExchangeRate], docToDelete[identifierFieldExchangeRate]);
            }
          }
          
          if (rowsCurrencies && rowsCurrencies.length) {
            const identifierFieldCurrencies = 'curCode'; // Change this to the correct identifier field for 'Currencies'
            let identifierValuesCurrencies = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCurrencies.length; i++) {
              const updatedRecord = rowsCurrencies[i];
              const identifierValue = updatedRecord[identifierFieldCurrencies]; // Assuming 'curCode' is the identifier value for 'Currencies'
          
              identifierValuesCurrencies.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('Currencies', updatedRecord, [identifierFieldCurrencies], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCurrencies = admin.firestore().collection('Currencies');
            const firestoreQueryCurrencies = await firestoreCollectionCurrencies.get();
            const firestoreDocumentsCurrencies = firestoreQueryCurrencies.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCurrencies = firestoreDocumentsCurrencies.filter(doc =>
              !identifierValuesCurrencies.includes(doc[identifierFieldCurrencies])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCurrencies) {
              await deleteFirestoreOnSqlServerDelete('Currencies', [identifierFieldCurrencies], docToDelete[identifierFieldCurrencies]);
            }
          }
          
          if (rowsVATGroups && rowsVATGroups.length) {
            const identifierFieldVATGroups = 'vatCode'; // Change this to the correct identifier field for 'VATGroups'
            let identifierValuesVATGroups = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsVATGroups.length; i++) {
              const updatedRecord = rowsVATGroups[i];
              const identifierValue = updatedRecord[identifierFieldVATGroups]; // Assuming 'vatCode' is the identifier value for 'VATGroups'
          
              identifierValuesVATGroups.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('VATGroups', updatedRecord, [identifierFieldVATGroups], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionVATGroups = admin.firestore().collection('VATGroups');
            const firestoreQueryVATGroups = await firestoreCollectionVATGroups.get();
            const firestoreDocumentsVATGroups = firestoreQueryVATGroups.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteVATGroups = firestoreDocumentsVATGroups.filter(doc =>
              !identifierValuesVATGroups.includes(doc[identifierFieldVATGroups])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteVATGroups) {
              await deleteFirestoreOnSqlServerDelete('VATGroups', [identifierFieldVATGroups], docToDelete[identifierFieldVATGroups]);
            }
          }
          
          if (rowsCustGroups && rowsCustGroups.length) {
            const identifierFieldCustGroups = 'grpCode'; // Change this to the correct identifier field for 'CustGroups'
            let identifierValuesCustGroups = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustGroups.length; i++) {
              const updatedRecord = rowsCustGroups[i];
              const identifierValue = updatedRecord[identifierFieldCustGroups]; // Assuming 'grpCode' is the identifier value for 'CustGroups'
          
              identifierValuesCustGroups.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustGroups', updatedRecord, [identifierFieldCustGroups], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustGroups = admin.firestore().collection('CustGroups');
            const firestoreQueryCustGroups = await firestoreCollectionCustGroups.get();
            const firestoreDocumentsCustGroups = firestoreQueryCustGroups.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustGroups = firestoreDocumentsCustGroups.filter(doc =>
              !identifierValuesCustGroups.includes(doc[identifierFieldCustGroups])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustGroups) {
              await deleteFirestoreOnSqlServerDelete('CustGroups', [identifierFieldCustGroups], docToDelete[identifierFieldCustGroups]);
            }
          }
          
          if (rowsCustProperties && rowsCustProperties.length) {
            const identifierFieldCustProperties = 'propCode'; // Change this to the correct identifier field for 'CustProperties'
            let identifierValuesCustProperties = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsCustProperties.length; i++) {
              const updatedRecord = rowsCustProperties[i];
              const identifierValue = updatedRecord[identifierFieldCustProperties]; // Assuming 'propCode' is the identifier value for 'CustProperties'
          
              identifierValuesCustProperties.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('CustProperties', updatedRecord, [identifierFieldCustProperties], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionCustProperties = admin.firestore().collection('CustProperties');
            const firestoreQueryCustProperties = await firestoreCollectionCustProperties.get();
            const firestoreDocumentsCustProperties = firestoreQueryCustProperties.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteCustProperties = firestoreDocumentsCustProperties.filter(doc =>
              !identifierValuesCustProperties.includes(doc[identifierFieldCustProperties])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteCustProperties) {
              await deleteFirestoreOnSqlServerDelete('CustProperties', [identifierFieldCustProperties], docToDelete[identifierFieldCustProperties]);
            }
          }
          
          if (rowsRegions && rowsRegions.length) {
            const identifierFieldRegions = 'regCode'; // Change this to the correct identifier field for 'Regions'
            let identifierValuesRegions = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsRegions.length; i++) {
              const updatedRecord = rowsRegions[i];
              const identifierValue = updatedRecord[identifierFieldRegions]; // Assuming 'regCode' is the identifier value for 'Regions'
          
              identifierValuesRegions.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('Regions', updatedRecord, [identifierFieldRegions], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionRegions = admin.firestore().collection('Regions');
            const firestoreQueryRegions = await firestoreCollectionRegions.get();
            const firestoreDocumentsRegions = firestoreQueryRegions.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteRegions = firestoreDocumentsRegions.filter(doc =>
              !identifierValuesRegions.includes(doc[identifierFieldRegions])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteRegions) {
              await deleteFirestoreOnSqlServerDelete('Regions', [identifierFieldRegions], docToDelete[identifierFieldRegions]);
            }
          }
          
          if (rowsWarehouses && rowsWarehouses.length) {
            const identifierFieldWarehouses = 'whsCode'; // Change this to the correct identifier field for 'Warehouses'
            let identifierValuesWarehouses = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsWarehouses.length; i++) {
              const updatedRecord = rowsWarehouses[i];
              const identifierValue = updatedRecord[identifierFieldWarehouses]; // Assuming 'whsCode' is the identifier value for 'Warehouses'
          
              identifierValuesWarehouses.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('Warehouses', updatedRecord, [identifierFieldWarehouses], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionWarehouses = admin.firestore().collection('Warehouses');
            const firestoreQueryWarehouses = await firestoreCollectionWarehouses.get();
            const firestoreDocumentsWarehouses = firestoreQueryWarehouses.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteWarehouses = firestoreDocumentsWarehouses.filter(doc =>
              !identifierValuesWarehouses.includes(doc[identifierFieldWarehouses])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteWarehouses) {
              await deleteFirestoreOnSqlServerDelete('Warehouses', [identifierFieldWarehouses], docToDelete[identifierFieldWarehouses]);
            }
          }
          
          if (rowsPaymentTerms && rowsPaymentTerms.length) {
            const identifierFieldPaymentTerms = 'ptCode'; // Change this to the correct identifier field for 'PaymentTerms'
            let identifierValuesPaymentTerms = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsPaymentTerms.length; i++) {
              const updatedRecord = rowsPaymentTerms[i];
              const identifierValue = updatedRecord[identifierFieldPaymentTerms]; // Assuming 'ptCode' is the identifier value for 'PaymentTerms'
          
              identifierValuesPaymentTerms.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('PaymentTerms', updatedRecord, [identifierFieldPaymentTerms], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionPaymentTerms = admin.firestore().collection('PaymentTerms');
            const firestoreQueryPaymentTerms = await firestoreCollectionPaymentTerms.get();
            const firestoreDocumentsPaymentTerms = firestoreQueryPaymentTerms.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeletePaymentTerms = firestoreDocumentsPaymentTerms.filter(doc =>
              !identifierValuesPaymentTerms.includes(doc[identifierFieldPaymentTerms])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeletePaymentTerms) {
              await deleteFirestoreOnSqlServerDelete('PaymentTerms', [identifierFieldPaymentTerms], docToDelete[identifierFieldPaymentTerms]);
            }
          }
          
          if (rowsSalesEmployees && rowsSalesEmployees.length) {
            const identifierFieldSalesEmployees = 'seCode'; // Change this to the correct identifier field for 'SalesEmployees'
            let identifierValuesSalesEmployees = [];
          
            // Update or add documents in Firestore
            for (let i = 0; i < rowsSalesEmployees.length; i++) {
              const updatedRecord = rowsSalesEmployees[i];
              const identifierValue = updatedRecord[identifierFieldSalesEmployees]; // Assuming 'seCode' is the identifier value for 'SalesEmployees'
          
              identifierValuesSalesEmployees.push(identifierValue); // Store identifier values for later comparison
          
              // Update or add the document in Firestore
              await updateFirestoreOnSqlServerUpdate('SalesEmployees', updatedRecord, [identifierFieldSalesEmployees], identifierValue);
            }
          
            // Fetch documents from Firestore
            const firestoreCollectionSalesEmployees = admin.firestore().collection('SalesEmployees');
            const firestoreQuerySalesEmployees = await firestoreCollectionSalesEmployees.get();
            const firestoreDocumentsSalesEmployees = firestoreQuerySalesEmployees.docs.map(doc => doc.data());
          
            // Identify documents in Firestore that are not in SQL Server results
            const documentsToDeleteSalesEmployees = firestoreDocumentsSalesEmployees.filter(doc =>
              !identifierValuesSalesEmployees.includes(doc[identifierFieldSalesEmployees])
            );
          
            // Delete Firestore documents that are not in SQL Server results
            for (const docToDelete of documentsToDeleteSalesEmployees) {
              await deleteFirestoreOnSqlServerDelete('SalesEmployees', [identifierFieldSalesEmployees], docToDelete[identifierFieldSalesEmployees]);
            }
          }
          
          if (rowsSalesEmployeesCustomers && rowsSalesEmployeesCustomers.length) {
  const identifierFieldsSalesEmployeesCustomers = ['seCode', 'custCode', 'cmpCode']; // Change this to the correct identifier fields for 'SalesEmployeesCustomers'
  let identifierValuesSalesEmployeesCustomers = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsSalesEmployeesCustomers.length; i++) {
    const updatedRecord = rowsSalesEmployeesCustomers[i];
    const identifierValue = [updatedRecord.seCode , updatedRecord.custCode , updatedRecord.cmpCode];

    identifierValuesSalesEmployeesCustomers.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('SalesEmployeesCustomers', updatedRecord, identifierFieldsSalesEmployeesCustomers, ...identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionSalesEmployeesCustomers = admin.firestore().collection('SalesEmployeesCustomers');
  const firestoreQuerySalesEmployeesCustomers = await firestoreCollectionSalesEmployeesCustomers.get();
  const firestoreDocumentsSalesEmployeesCustomers = firestoreQuerySalesEmployeesCustomers.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteSalesEmployeesCustomers = firestoreDocumentsSalesEmployeesCustomers.filter(doc =>
    !identifierValuesSalesEmployeesCustomers.some(values =>
      identifierFieldsSalesEmployeesCustomers.every((field, index) => values[index] === doc[field]))
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteSalesEmployeesCustomers) {
    const identifierValue = identifierFieldsSalesEmployeesCustomers.map(field => docToDelete[field]);
    await deleteFirestoreOnSqlServerDelete('SalesEmployeesCustomers', identifierFieldsSalesEmployeesCustomers, ...identifierValue);
  }
}

if (rowsSalesEmployeesDepartments && rowsSalesEmployeesDepartments.length) {
  const identifierFieldsSalesEmployeesDepartments = ['cmpCode', 'seCode', 'deptCode']; // Change this to the correct identifier fields for 'SalesEmployeesDepartments'
  let identifierValuesSalesEmployeesDepartments = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsSalesEmployeesDepartments.length; i++) {
    const updatedRecord = rowsSalesEmployeesDepartments[i];
    const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.deptCode];

    identifierValuesSalesEmployeesDepartments.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('SalesEmployeesDepartments', updatedRecord, identifierFieldsSalesEmployeesDepartments, ...identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionSalesEmployeesDepartments = admin.firestore().collection('SalesEmployeesDepartments');
  const firestoreQuerySalesEmployeesDepartments = await firestoreCollectionSalesEmployeesDepartments.get();
  const firestoreDocumentsSalesEmployeesDepartments = firestoreQuerySalesEmployeesDepartments.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteSalesEmployeesDepartments = firestoreDocumentsSalesEmployeesDepartments.filter(doc =>
    !identifierValuesSalesEmployeesDepartments.some(values =>
      identifierFieldsSalesEmployeesDepartments.every((field, index) => values[index] === doc[field])
    )
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteSalesEmployeesDepartments) {
    const identifierValue = identifierFieldsSalesEmployeesDepartments.map(field => docToDelete[field]);
    await deleteFirestoreOnSqlServerDelete('SalesEmployeesDepartments', identifierFieldsSalesEmployeesDepartments, ...identifierValue);
  }
}
if (rowsSalesEmployeesItemsBrands && rowsSalesEmployeesItemsBrands.length) {
  const identifierFieldsSalesEmployeesItemsBrands = ['cmpCode', 'seCode', 'brandCode']; // Change this to the correct identifier fields for 'SalesEmployeesItemsBrands'
  let identifierValuesSalesEmployeesItemsBrands = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsSalesEmployeesItemsBrands.length; i++) {
    const updatedRecord = rowsSalesEmployeesItemsBrands[i];
    const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.brandCode];
    identifierValuesSalesEmployeesItemsBrands.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('SalesEmployeesItemsBrands', updatedRecord, identifierFieldsSalesEmployeesItemsBrands, ...identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionSalesEmployeesItemsBrands = admin.firestore().collection('SalesEmployeesItemsBrands');
  const firestoreQuerySalesEmployeesItemsBrands = await firestoreCollectionSalesEmployeesItemsBrands.get();
  const firestoreDocumentsSalesEmployeesItemsBrands = firestoreQuerySalesEmployeesItemsBrands.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteSalesEmployeesItemsBrands = firestoreDocumentsSalesEmployeesItemsBrands.filter(doc =>
    !identifierValuesSalesEmployeesItemsBrands.some(values =>
      identifierFieldsSalesEmployeesItemsBrands.every((field, index) => values[index] === doc[field]))
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteSalesEmployeesItemsBrands) {
    const identifierValue = identifierFieldsSalesEmployeesItemsBrands.map(field => docToDelete[field]);
    await deleteFirestoreOnSqlServerDelete('SalesEmployeesItemsBrands', identifierFieldsSalesEmployeesItemsBrands, ...identifierValue);
  }
}

if (rowsSalesEmployeesItemsCategories && rowsSalesEmployeesItemsCategories.length) {
  const identifierFieldsSalesEmployeesItemsCategories = ['cmpCode', 'seCode', 'categCode']; // Change this to the correct identifier fields for 'SalesEmployeesItemsCategories'
  let identifierValuesSalesEmployeesItemsCategories = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsSalesEmployeesItemsCategories.length; i++) {
    const updatedRecord = rowsSalesEmployeesItemsCategories[i];
    const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.categCode];

    identifierValuesSalesEmployeesItemsCategories.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('SalesEmployeesItemsCategories', updatedRecord, identifierFieldsSalesEmployeesItemsCategories, ...identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionSalesEmployeesItemsCategories = admin.firestore().collection('SalesEmployeesItemsCategories');
  const firestoreQuerySalesEmployeesItemsCategories = await firestoreCollectionSalesEmployeesItemsCategories.get();
  const firestoreDocumentsSalesEmployeesItemsCategories = firestoreQuerySalesEmployeesItemsCategories.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteSalesEmployeesItemsCategories = firestoreDocumentsSalesEmployeesItemsCategories.filter(doc =>
    !identifierValuesSalesEmployeesItemsCategories.some(values =>
      identifierFieldsSalesEmployeesItemsCategories.every((field, index) => values[index] === doc[field])
    )
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteSalesEmployeesItemsCategories) {
    const identifierValue = identifierFieldsSalesEmployeesItemsCategories.map(field => docToDelete[field]);
    await deleteFirestoreOnSqlServerDelete('SalesEmployeesItemsCategories', identifierFieldsSalesEmployeesItemsCategories, ...identifierValue);
  }
}

if (rowsSalesEmployeesItemsGroups && rowsSalesEmployeesItemsGroups.length) {
  const identifierFieldsSalesEmployeesItemsGroups = ['cmpCode', 'seCode', 'groupCode']; // Change this to the correct identifier fields for 'SalesEmployeesItemsGroups'
  let identifierValuesSalesEmployeesItemsGroups = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsSalesEmployeesItemsGroups.length; i++) {
    const updatedRecord = rowsSalesEmployeesItemsGroups[i];
    const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.groupCode];

    identifierValuesSalesEmployeesItemsGroups.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('SalesEmployeesItemsGroups', updatedRecord, identifierFieldsSalesEmployeesItemsGroups, ...identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionSalesEmployeesItemsGroups = admin.firestore().collection('SalesEmployeesItemsGroups');
  const firestoreQuerySalesEmployeesItemsGroups = await firestoreCollectionSalesEmployeesItemsGroups.get();
  const firestoreDocumentsSalesEmployeesItemsGroups = firestoreQuerySalesEmployeesItemsGroups.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteSalesEmployeesItemsGroups = firestoreDocumentsSalesEmployeesItemsGroups.filter(doc =>
    !identifierValuesSalesEmployeesItemsGroups.some(values =>
      identifierFieldsSalesEmployeesItemsGroups.every((field, index) => values[index] === doc[field])
    )
  );

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteSalesEmployeesItemsGroups) {
    const identifierValue = identifierFieldsSalesEmployeesItemsGroups.map(field => docToDelete[field]);
    await deleteFirestoreOnSqlServerDelete('SalesEmployeesItemsGroups', identifierFieldsSalesEmployeesItemsGroups, ...identifierValue);
  }
}

if (rowsSalesEmployeesItems && rowsSalesEmployeesItems.length) {
  const identifierFieldsSalesEmployeesItems = ['cmpCode', 'seCode', 'itemCode']; // Change this to the correct identifier fields for 'SalesEmployeesItems'
  let identifierValuesSalesEmployeesItems = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsSalesEmployeesItems.length; i++) {
    const updatedRecord = rowsSalesEmployeesItems[i];
    const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.itemCode];

    identifierValuesSalesEmployeesItems.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('SalesEmployeesItems', updatedRecord, identifierFieldsSalesEmployeesItems,...identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionSalesEmployeesItems = admin.firestore().collection('SalesEmployeesItems');
  const firestoreQuerySalesEmployeesItems = await firestoreCollectionSalesEmployeesItems.get();
  const firestoreDocumentsSalesEmployeesItems = firestoreQuerySalesEmployeesItems.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteSalesEmployeesItems = firestoreDocumentsSalesEmployeesItems.filter(doc =>
    !identifierValuesSalesEmployeesItems.some(values =>
      identifierFieldsSalesEmployeesItems.every((field, index) => values[index] === doc[field])
    ));

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteSalesEmployeesItems) {
    const identifierValue = identifierFieldsSalesEmployeesItems.map(field => docToDelete[field]);
    await deleteFirestoreOnSqlServerDelete('SalesEmployeesItems', identifierFieldsSalesEmployeesItems, ...identifierValue);
  }
}

if (rowsUsersSalesEmployees && rowsUsersSalesEmployees.length) {
  const identifierFieldsUsersSalesEmployees = ['userCode', 'cmpCode', 'seCode']; // Change this to the correct identifier fields for 'UsersSalesEmployees'
  let identifierValuesUsersSalesEmployees = [];

  // Update or add documents in Firestore
  for (let i = 0; i < rowsUsersSalesEmployees.length; i++) {
    const updatedRecord = rowsUsersSalesEmployees[i];
    const identifierValue = [updatedRecord.userCode , updatedRecord.cmpCode , updatedRecord.seCode];

    identifierValuesUsersSalesEmployees.push(identifierValue); // Store identifier values for later comparison

    // Update or add the document in Firestore
    await updateFirestoreOnSqlServerUpdate('UsersSalesEmployees', updatedRecord, identifierFieldsUsersSalesEmployees, ...identifierValue);
  }

  // Fetch documents from Firestore
  const firestoreCollectionUsersSalesEmployees = admin.firestore().collection('UsersSalesEmployees');
  const firestoreQueryUsersSalesEmployees = await firestoreCollectionUsersSalesEmployees.get();
  const firestoreDocumentsUsersSalesEmployees = firestoreQueryUsersSalesEmployees.docs.map(doc => doc.data());

  // Identify documents in Firestore that are not in SQL Server results
  const documentsToDeleteUsersSalesEmployees = firestoreDocumentsUsersSalesEmployees.filter(doc =>
    !identifierValuesUsersSalesEmployees.some(values =>
      identifierFieldsUsersSalesEmployees.every((field, index) => values[index] === doc[field])
    ));

  // Delete Firestore documents that are not in SQL Server results
  for (const docToDelete of documentsToDeleteUsersSalesEmployees) {
    const identifierValue = identifierFieldsUsersSalesEmployees.map(field => docToDelete[field]);
    await deleteFirestoreOnSqlServerDelete('UsersSalesEmployees', identifierFieldsUsersSalesEmployees, ...identifierValue);
  }
}

            console.log(`Document added to System collection with IDs: ${docRefCompanies?.id}, ${docRefDepartments?.id}, ${docRefExchangeRate?.id}, ${docRefCurrencies?.id}, ${docRefVATGroups?.id}, ${docRefCustGroups?.id}, ${docRefCustProperties?.id}, ${docRefRegions?.id}, ${docRefWarehouses?.id}, ${docRefPaymentTerms?.id}, ${docRefSalesEmployees?.id}, ${docRefSalesEmployeesCustomers?.id}, ${docRefSalesEmployeesDepartments?.id}, ${docRefSalesEmployeesItemsBrands?.id}, ${docRefSalesEmployeesItemsCategories?.id}, ${docRefSalesEmployeesItemsGroups?.id}, ${docRefSalesEmployeesItems?.id}, ${docRefUsersSalesEmployees?.id}`);
          }

        



  async function selectALL(){

      if (rowsItems && rowsItems.length) {
        const identifierFieldItems = 'itemCode'; // Change this to the correct identifier field for 'Items'
        let identifierValues = []; // Array to store identifier values for documents in Firestore
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsItems.length; i++) {
          const updatedRecord = rowsItems[i];
          const identifierValue = updatedRecord.itemCode; // Assuming 'itemCode' is the identifier value for 'Items'
      
          identifierValues.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('Items', updatedRecord, identifierFieldItems, identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollection = admin.firestore().collection('Items');
        const firestoreQuery = await firestoreCollection.get();
        const firestoreDocuments = firestoreQuery.docs.map(doc => doc.data());
        
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDelete = firestoreDocuments.filter(doc => !identifierValues.includes(doc[identifierFieldItems]));
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDelete) {
          await deleteFirestoreOnSqlServerDelete('Items', identifierFieldItems, docToDelete[identifierFieldItems]);
        }
      } else {
        // Handle the case where there are no rowsItems from SQL Server
        console.error('No data retrieved from SQL Server.');
      }
     
      
// Example for 'ItemPrices'
if (rowsItemPrices && rowsItemPrices.length) {
const identifierFieldsItemPrices = ['plCode', 'itemCode'];
let identifierValuesItemPrices = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsItemPrices.length; i++) {
  const updatedRecord = rowsItemPrices[i];
  const identifierValue = [updatedRecord.plCode, updatedRecord.itemCode];

  identifierValuesItemPrices.push(identifierValue);

  // Update or add the document in Firestore
  await updateFirestoreOnSqlServerUpdate('ItemsPrices', updatedRecord, identifierFieldsItemPrices, ...identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionItemPrices = admin.firestore().collection('ItemsPrices');
const firestoreQueryItemPrices = await firestoreCollectionItemPrices.get();
const firestoreDocumentsItemPrices = firestoreQueryItemPrices.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteItemPrices = firestoreDocumentsItemPrices.filter(doc =>
  !identifierValuesItemPrices.some(values =>
    identifierFieldsItemPrices.every((field, index) => values[index] === doc[field])
  )
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteItemPrices) {
  const identifierValuesToDelete = identifierFieldsItemPrices.map(field => docToDelete[field]);
  await deleteFirestoreOnSqlServerDelete('ItemsPrices', identifierFieldsItemPrices, ...identifierValuesToDelete);
}
}



if (rowsItemBrand && rowsItemBrand.length) {
const identifierFieldItemBrand = 'brandCode'; // Change this to the correct identifier field for 'ItemBrand'
let identifierValuesItemBrand = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsItemBrand.length; i++) {
const updatedRecord = rowsItemBrand[i];
const identifierValue = updatedRecord.brandCode; // Assuming 'brandCode' is the identifier field for 'ItemBrand'

identifierValuesItemBrand.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('ItemBrand', updatedRecord, identifierFieldItemBrand, identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionItemBrand = admin.firestore().collection('ItemBrand');
const firestoreQueryItemBrand = await firestoreCollectionItemBrand.get();
const firestoreDocumentsItemBrand = firestoreQueryItemBrand.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteItemBrand = firestoreDocumentsItemBrand.filter(doc =>
!identifierValuesItemBrand.includes(doc[identifierFieldItemBrand])
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteItemBrand) {
await deleteFirestoreOnSqlServerDelete('ItemBrand', identifierFieldItemBrand, docToDelete[identifierFieldItemBrand]);
}
}

if (rowsItemCateg && rowsItemCateg.length) {
const identifierFieldItemCateg = 'categCode'; // Change this to the correct identifier field for 'ItemCateg'
let identifierValuesItemCateg = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsItemCateg.length; i++) {
const updatedRecord = rowsItemCateg[i];
const identifierValue = updatedRecord.categCode; // Assuming 'categCode' is the identifier field for 'ItemCateg'

identifierValuesItemCateg.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('ItemCateg', updatedRecord, identifierFieldItemCateg, identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionItemCateg = admin.firestore().collection('ItemCateg');
const firestoreQueryItemCateg = await firestoreCollectionItemCateg.get();
const firestoreDocumentsItemCateg = firestoreQueryItemCateg.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteItemCateg = firestoreDocumentsItemCateg.filter(doc =>
!identifierValuesItemCateg.includes(doc[identifierFieldItemCateg])
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteItemCateg) {
await deleteFirestoreOnSqlServerDelete('ItemCateg', identifierFieldItemCateg, docToDelete[identifierFieldItemCateg]);
}
}

if (rowsItemAttach && rowsItemAttach.length) {
const identifierFieldItemAttach = 'attachmentPath'; // Change this to the correct identifier field for 'ItemAttach'
let identifierValuesItemAttach = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsItemAttach.length; i++) {
const updatedRecord = rowsItemAttach[i];
const identifierValue = updatedRecord.attachmentPath; // Assuming 'attachmentPath' is the identifier field for 'ItemAttach'

identifierValuesItemAttach.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('ItemAttach', updatedRecord, identifierFieldItemAttach, identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionItemAttach = admin.firestore().collection('ItemAttach');
const firestoreQueryItemAttach = await firestoreCollectionItemAttach.get();
const firestoreDocumentsItemAttach = firestoreQueryItemAttach.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteItemAttach = firestoreDocumentsItemAttach.filter(doc =>
!identifierValuesItemAttach.includes(doc[identifierFieldItemAttach])
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteItemAttach) {
await deleteFirestoreOnSqlServerDelete('ItemAttach', identifierFieldItemAttach, docToDelete[identifierFieldItemAttach]);
}
}

if (rowsItemGroup && rowsItemGroup.length) {
const identifierFieldItemGroup = 'groupCode'; // Change this to the correct identifier field for 'ItemGroup'
let identifierValuesItemGroup = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsItemGroup.length; i++) {
const updatedRecord = rowsItemGroup[i];
const identifierValue = updatedRecord.groupCode; // Assuming 'groupCode' is the identifier field for 'ItemGroup'

identifierValuesItemGroup.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('ItemGroup', updatedRecord, identifierFieldItemGroup, identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionItemGroup = admin.firestore().collection('ItemGroup');
const firestoreQueryItemGroup = await firestoreCollectionItemGroup.get();
const firestoreDocumentsItemGroup = firestoreQueryItemGroup.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteItemGroup = firestoreDocumentsItemGroup.filter(doc =>
!identifierValuesItemGroup.includes(doc[identifierFieldItemGroup])
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteItemGroup) {
await deleteFirestoreOnSqlServerDelete('ItemGroup', identifierFieldItemGroup, docToDelete[identifierFieldItemGroup]);
}
}

if (rowsItemUOM && rowsItemUOM.length) {
const identifierFieldItemUOM = 'uom'; // Change this to the correct identifier field for 'ItemUOM'
let identifierValuesItemUOM = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsItemUOM.length; i++) {
const updatedRecord = rowsItemUOM[i];
const identifierValue = updatedRecord[identifierFieldItemUOM]; // Assuming 'uom' is the identifier field for 'ItemUOM'

identifierValuesItemUOM.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('ItemUOM', updatedRecord, [identifierFieldItemUOM], identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionItemUOM = admin.firestore().collection('ItemUOM');
const firestoreQueryItemUOM = await firestoreCollectionItemUOM.get();
const firestoreDocumentsItemUOM = firestoreQueryItemUOM.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteItemUOM = firestoreDocumentsItemUOM.filter(doc =>
!identifierValuesItemUOM.includes(doc[identifierFieldItemUOM])
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteItemUOM) {
await deleteFirestoreOnSqlServerDelete('ItemUOM', [identifierFieldItemUOM], docToDelete[identifierFieldItemUOM]);
}
}



      console.log(`Document added to Items collection with IDs: ${docRefItems?.id}, ${docRefItemPrices?.id}, ${docRefItemBrand?.id}, ${docRefItemCateg?.id}, ${docRefItemAttach?.id}, ${docRefItemGroup?.id}, ${docRefItemUOM?.id}`);
    
  

      if (rowsPriceList && rowsPriceList.length) {
        const identifierFieldPriceLists = 'plCode'; // Change this to the correct identifier field for 'PriceLists'
        let identifierValuesPriceLists = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsPriceList.length; i++) {
          const updatedRecord = rowsPriceList[i];
          const identifierValue = updatedRecord[identifierFieldPriceLists] // Assuming 'plCode' is the identifier field for 'PriceLists'
      
          identifierValuesPriceLists.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('PriceList', updatedRecord, [identifierFieldPriceLists], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionPriceLists = admin.firestore().collection('PriceList');
        const firestoreQueryPriceLists = await firestoreCollectionPriceLists.get();
        const firestoreDocumentsPriceLists = firestoreQueryPriceLists.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeletePriceLists = firestoreDocumentsPriceLists.filter(doc =>
          !identifierValuesPriceLists.includes(doc[identifierFieldPriceLists])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeletePriceLists) {
          await deleteFirestoreOnSqlServerDelete('PriceList', [identifierFieldPriceLists], docToDelete[identifierFieldPriceLists]);
        }
      }
      
    


      if (rowsCustomers && rowsCustomers.length) {
        const identifierFieldCustomers = 'custCode'; // Change this to the correct identifier field for 'Customers'
        let identifierValuesCustomers = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomers.length; i++) {
          const updatedRecord = rowsCustomers[i];
          const identifierValue = updatedRecord[identifierFieldCustomers]; // Assuming 'custCode' is the identifier field for 'Customers'
      
          identifierValuesCustomers.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('Customers', updatedRecord, [identifierFieldCustomers], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomers = admin.firestore().collection('Customers');
        const firestoreQueryCustomers = await firestoreCollectionCustomers.get();
        const firestoreDocumentsCustomers = firestoreQueryCustomers.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomers = firestoreDocumentsCustomers.filter(doc =>
          !identifierValuesCustomers.includes(doc[identifierFieldCustomers])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomers) {
          await deleteFirestoreOnSqlServerDelete('Customers', [identifierFieldCustomers], docToDelete[identifierFieldCustomers]);
        }
      }
      
      if (rowsCustomerAddresses && rowsCustomerAddresses.length) {
        const identifierFieldCustomerAddresses = 'addressID'; // Change this to the correct identifier field for 'CustomerAddresses'
        let identifierValuesCustomerAddresses = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerAddresses.length; i++) {
          const updatedRecord = rowsCustomerAddresses[i];
          const identifierValue = updatedRecord[identifierFieldCustomerAddresses]; // Assuming 'addressID' is the identifier field for 'CustomerAddresses'
      
          identifierValuesCustomerAddresses.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerAddresses', updatedRecord, [identifierFieldCustomerAddresses], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerAddresses = admin.firestore().collection('CustomerAddresses');
        const firestoreQueryCustomerAddresses = await firestoreCollectionCustomerAddresses.get();
        const firestoreDocumentsCustomerAddresses = firestoreQueryCustomerAddresses.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerAddresses = firestoreDocumentsCustomerAddresses.filter(doc =>
          !identifierValuesCustomerAddresses.includes(doc[identifierFieldCustomerAddresses])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerAddresses) {
          await deleteFirestoreOnSqlServerDelete('CustomerAddresses', [identifierFieldCustomerAddresses], docToDelete[identifierFieldCustomerAddresses]);
        }
      }
      
      if (rowsCustomerContacts && rowsCustomerContacts.length) {
        const identifierFieldCustomerContacts = 'contactID'; // Change this to the correct identifier field for 'CustomerContacts'
        let identifierValuesCustomerContacts = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerContacts.length; i++) {
          const updatedRecord = rowsCustomerContacts[i];
          const identifierValue = updatedRecord[identifierFieldCustomerContacts]; // Assuming 'contactID' is the identifier field for 'CustomerContacts'
      
          identifierValuesCustomerContacts.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerContacts', updatedRecord, [identifierFieldCustomerContacts], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerContacts = admin.firestore().collection('CustomerContacts');
        const firestoreQueryCustomerContacts = await firestoreCollectionCustomerContacts.get();
        const firestoreDocumentsCustomerContacts = firestoreQueryCustomerContacts.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerContacts = firestoreDocumentsCustomerContacts.filter(doc =>
          !identifierValuesCustomerContacts.includes(doc[identifierFieldCustomerContacts])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerContacts) {
          await deleteFirestoreOnSqlServerDelete('CustomerContacts', [identifierFieldCustomerContacts], docToDelete[identifierFieldCustomerContacts]);
        }
      }
      
      if (rowsCustomerProperties && rowsCustomerProperties.length) {
        const identifierFieldCustomerProperties = 'propCode'; // Change this to the correct identifier field for 'CustomerProperties'
        let identifierValuesCustomerProperties = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerProperties.length; i++) {
          const updatedRecord = rowsCustomerProperties[i];
          const identifierValue = updatedRecord[identifierFieldCustomerProperties]; // Assuming 'propCode' is the identifier field for 'CustomerProperties'
      
          identifierValuesCustomerProperties.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerProperties', updatedRecord, [identifierFieldCustomerProperties], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerProperties = admin.firestore().collection('CustomerProperties');
        const firestoreQueryCustomerProperties = await firestoreCollectionCustomerProperties.get();
        const firestoreDocumentsCustomerProperties = firestoreQueryCustomerProperties.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerProperties = firestoreDocumentsCustomerProperties.filter(doc =>
          !identifierValuesCustomerProperties.includes(doc[identifierFieldCustomerProperties])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerProperties) {
          await deleteFirestoreOnSqlServerDelete('CustomerProperties', [identifierFieldCustomerProperties], docToDelete[identifierFieldCustomerProperties]);
        }
      }
      
      if (rowsCustomerAttachments && rowsCustomerAttachments.length) {
        const identifierFieldCustomerAttachments = 'attach'; // Change this to the correct identifier field for 'CustomerAttachments'
        let identifierValuesCustomerAttachments = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerAttachments.length; i++) {
          const updatedRecord = rowsCustomerAttachments[i];
        const identifierFieldCustomerAttachments = 'attach'; // Change this to the correct identifier field for 'CustomerAttachments'
          const identifierValue = updatedRecord[identifierFieldCustomerAttachments]; // Assuming 'attach' is the identifier field for 'CustomerAttachments'
      
          identifierValuesCustomerAttachments.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerAttachments', updatedRecord, [identifierFieldCustomerAttachments], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerAttachments = admin.firestore().collection('CustomerAttachments');
        const firestoreQueryCustomerAttachments = await firestoreCollectionCustomerAttachments.get();
        const firestoreDocumentsCustomerAttachments = firestoreQueryCustomerAttachments.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerAttachments = firestoreDocumentsCustomerAttachments.filter(doc =>
          !identifierValuesCustomerAttachments.includes(doc[identifierFieldCustomerAttachments])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerAttachments) {
          await deleteFirestoreOnSqlServerDelete('CustomerAttachments', [identifierFieldCustomerAttachments], docToDelete[identifierFieldCustomerAttachments]);
        }
      }
      
      if (rowsCustomerItemsSpecialPrice && rowsCustomerItemsSpecialPrice.length) {
        const identifierFieldsCustomerItemsSpecialPrice = ['itemCode', 'cmpCode', 'custCode', 'uom']; // Change this to the correct identifier fields for 'CustomerItemsSpecialPrice'
        let identifierValuesCustomerItemsSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerItemsSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerItemsSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.itemCode,updatedRecord.cmpCode,updatedRecord.custCode,updatedRecord.uom]
      
          identifierValuesCustomerItemsSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerItemsSpecialPrice', updatedRecord, identifierFieldsCustomerItemsSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerItemsSpecialPrice = admin.firestore().collection('CustomerItemsSpecialPrice');
        const firestoreQueryCustomerItemsSpecialPrice = await firestoreCollectionCustomerItemsSpecialPrice.get();
        const firestoreDocumentsCustomerItemsSpecialPrice = firestoreQueryCustomerItemsSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerItemsSpecialPrice = firestoreDocumentsCustomerItemsSpecialPrice.filter(doc =>
          !identifierValuesCustomerItemsSpecialPrice.some(values =>
            identifierFieldsCustomerItemsSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerItemsSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerItemsSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerItemsSpecialPrice', identifierFieldsCustomerItemsSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerBrandSpecialPrice && rowsCustomerBrandSpecialPrice.length) {
        const identifierFieldsCustomerBrandSpecialPrice = ['brandCode', 'cmpCode', 'custCode']; // Change this to the correct identifier fields for 'CustomerBrandSpecialPrice'
        let identifierValuesCustomerBrandSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerBrandSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerBrandSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.brandCode,updatedRecord.cmpCode,updatedRecord.custCode]
      
          identifierValuesCustomerBrandSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerBrandSpecialPrice', updatedRecord, identifierFieldsCustomerBrandSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerBrandSpecialPrice = admin.firestore().collection('CustomerBrandSpecialPrice');
        const firestoreQueryCustomerBrandSpecialPrice = await firestoreCollectionCustomerBrandSpecialPrice.get();
        const firestoreDocumentsCustomerBrandSpecialPrice = firestoreQueryCustomerBrandSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerBrandSpecialPrice = firestoreDocumentsCustomerBrandSpecialPrice.filter(doc =>
          !identifierValuesCustomerBrandSpecialPrice.some(values =>
            identifierFieldsCustomerBrandSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerBrandSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerBrandSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerBrandSpecialPrice', identifierFieldsCustomerBrandSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerGroupSpecialPrice && rowsCustomerGroupSpecialPrice.length) {
        const identifierFieldsCustomerGroupSpecialPrice = ['groupCode', 'cmpCode', 'custCode']; // Change this to the correct identifier fields for 'CustomerGroupSpecialPrice'
        let identifierValuesCustomerGroupSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerGroupSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerGroupSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.groupCode,updatedRecord.cmpCode,updatedRecord.custCode];
      
          identifierValuesCustomerGroupSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerGroupSpecialPrice', updatedRecord, identifierFieldsCustomerGroupSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerGroupSpecialPrice = admin.firestore().collection('CustomerGroupSpecialPrice');
        const firestoreQueryCustomerGroupSpecialPrice = await firestoreCollectionCustomerGroupSpecialPrice.get();
        const firestoreDocumentsCustomerGroupSpecialPrice = firestoreQueryCustomerGroupSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerGroupSpecialPrice = firestoreDocumentsCustomerGroupSpecialPrice.filter(doc =>
          !identifierValuesCustomerGroupSpecialPrice.some(values =>
            identifierFieldsCustomerGroupSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerGroupSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerGroupSpecialPrice', identifierFieldsCustomerGroupSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerCategSpecialPrice && rowsCustomerCategSpecialPrice.length) {
        const identifierFieldsCustomerCategSpecialPrice = ['categCode', 'cmpCode', 'custCode']; // Change this to the correct identifier fields for 'CustomerCategSpecialPrice'
        let identifierValuesCustomerCategSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerCategSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerCategSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.categCode , updatedRecord.cmpCode , updatedRecord.custCode];
      
          identifierValuesCustomerCategSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerCategSpecialPrice', updatedRecord, identifierFieldsCustomerCategSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerCategSpecialPrice = admin.firestore().collection('CustomerCategSpecialPrice');
        const firestoreQueryCustomerCategSpecialPrice = await firestoreCollectionCustomerCategSpecialPrice.get();
        const firestoreDocumentsCustomerCategSpecialPrice = firestoreQueryCustomerCategSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerCategSpecialPrice = firestoreDocumentsCustomerCategSpecialPrice.filter(doc =>
          !identifierValuesCustomerCategSpecialPrice.some(values =>
            identifierFieldsCustomerCategSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerCategSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerCategSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerCategSpecialPrice', identifierFieldsCustomerCategSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerGroupItemsSpecialPrice && rowsCustomerGroupItemsSpecialPrice.length) {
        const identifierFieldsCustomerGroupItemsSpecialPrice = ['cmpCode', 'custGroupCode', 'itemCode', 'uom']; // Change this to the correct identifier fields for 'CustomerGroupItemsSpecialPrice'
        let identifierValuesCustomerGroupItemsSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerGroupItemsSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerGroupItemsSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.itemCode , updatedRecord.uom];
      
          identifierValuesCustomerGroupItemsSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerGroupItemsSpecialPrice', updatedRecord, identifierFieldsCustomerGroupItemsSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerGroupItemsSpecialPrice = admin.firestore().collection('CustomerGroupItemsSpecialPrice');
        const firestoreQueryCustomerGroupItemsSpecialPrice = await firestoreCollectionCustomerGroupItemsSpecialPrice.get();
        const firestoreDocumentsCustomerGroupItemsSpecialPrice = firestoreQueryCustomerGroupItemsSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerGroupItemsSpecialPrice = firestoreDocumentsCustomerGroupItemsSpecialPrice.filter(doc =>
          !identifierValuesCustomerGroupItemsSpecialPrice.some(values =>
            identifierFieldsCustomerGroupItemsSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerGroupItemsSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupItemsSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerGroupItemsSpecialPrice', identifierFieldsCustomerGroupItemsSpecialPrice, compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerGroupBrandSpecialPrice && rowsCustomerGroupBrandSpecialPrice.length) {
        const identifierFieldsCustomerGroupBrandSpecialPrice = ['cmpCode', 'custGroupCode', 'brandCode']; // Change this to the correct identifier fields for 'CustomerGroupBrandSpecialPrice'
        let identifierValuesCustomerGroupBrandSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerGroupBrandSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerGroupBrandSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.brandCode];
      
          identifierValuesCustomerGroupBrandSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerGroupBrandSpecialPrice', updatedRecord, identifierFieldsCustomerGroupBrandSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerGroupBrandSpecialPrice = admin.firestore().collection('CustomerGroupBrandSpecialPrice');
        const firestoreQueryCustomerGroupBrandSpecialPrice = await firestoreCollectionCustomerGroupBrandSpecialPrice.get();
        const firestoreDocumentsCustomerGroupBrandSpecialPrice = firestoreQueryCustomerGroupBrandSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerGroupBrandSpecialPrice = firestoreDocumentsCustomerGroupBrandSpecialPrice.filter(doc =>
          !identifierValuesCustomerGroupBrandSpecialPrice.some(values =>
            identifierFieldsCustomerGroupBrandSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerGroupBrandSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupBrandSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerGroupBrandSpecialPrice', identifierFieldsCustomerGroupBrandSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerGroupGroupSpecialPrice && rowsCustomerGroupGroupSpecialPrice.length) {
        const identifierFieldsCustomerGroupGroupSpecialPrice = ['cmpCode', 'custGroupCode', 'groupCode']; // Change this to the correct identifier fields for 'CustomerGroupGroupSpecialPrice'
        let identifierValuesCustomerGroupGroupSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerGroupGroupSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerGroupGroupSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.groupCode];
      
          identifierValuesCustomerGroupGroupSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerGroupGroupSpecialPrice', updatedRecord, identifierFieldsCustomerGroupGroupSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerGroupGroupSpecialPrice = admin.firestore().collection('CustomerGroupGroupSpecialPrice');
        const firestoreQueryCustomerGroupGroupSpecialPrice = await firestoreCollectionCustomerGroupGroupSpecialPrice.get();
        const firestoreDocumentsCustomerGroupGroupSpecialPrice = firestoreQueryCustomerGroupGroupSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerGroupGroupSpecialPrice = firestoreDocumentsCustomerGroupGroupSpecialPrice.filter(doc =>
          !identifierValuesCustomerGroupGroupSpecialPrice.some(values =>
            identifierFieldsCustomerGroupGroupSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerGroupGroupSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupGroupSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerGroupGroupSpecialPrice', identifierFieldsCustomerGroupGroupSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerGroupCategSpecialPrice && rowsCustomerGroupCategSpecialPrice.length) {
        const identifierFieldsCustomerGroupCategSpecialPrice = ['cmpCode', 'custGroupCode', 'categCode']; // Change this to the correct identifier fields for 'CustomerGroupCategSpecialPrice'
        let identifierValuesCustomerGroupCategSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerGroupCategSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerGroupCategSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.categCode];
      
          identifierValuesCustomerGroupCategSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerGroupCategSpecialPrice', updatedRecord, identifierFieldsCustomerGroupCategSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerGroupCategSpecialPrice = admin.firestore().collection('CustomerGroupCategSpecialPrice');
        const firestoreQueryCustomerGroupCategSpecialPrice = await firestoreCollectionCustomerGroupCategSpecialPrice.get();
        const firestoreDocumentsCustomerGroupCategSpecialPrice = firestoreQueryCustomerGroupCategSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerGroupCategSpecialPrice = firestoreDocumentsCustomerGroupCategSpecialPrice.filter(doc =>
          !identifierValuesCustomerGroupCategSpecialPrice.some(values =>
            identifierFieldsCustomerGroupCategSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerGroupCategSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerGroupCategSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerGroupCategSpecialPrice', identifierFieldsCustomerGroupCategSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerPropItemsSpecialPrice && rowsCustomerPropItemsSpecialPrice.length) {
        const identifierFieldsCustomerPropItemsSpecialPrice = ['cmpCode', 'custPropCode', 'itemCode', 'uom']; // Change this to the correct identifier fields for 'CustomerPropItemsSpecialPrice'
        let identifierValuesCustomerPropItemsSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerPropItemsSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerPropItemsSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.itemCode , updatedRecord.uom];
      
          identifierValuesCustomerPropItemsSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerPropItemsSpecialPrice', updatedRecord, identifierFieldsCustomerPropItemsSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerPropItemsSpecialPrice = admin.firestore().collection('CustomerPropItemsSpecialPrice');
        const firestoreQueryCustomerPropItemsSpecialPrice = await firestoreCollectionCustomerPropItemsSpecialPrice.get();
        const firestoreDocumentsCustomerPropItemsSpecialPrice = firestoreQueryCustomerPropItemsSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerPropItemsSpecialPrice = firestoreDocumentsCustomerPropItemsSpecialPrice.filter(doc =>
          !identifierValuesCustomerPropItemsSpecialPrice.some(values =>
            identifierFieldsCustomerPropItemsSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerPropItemsSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerPropItemsSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerPropItemsSpecialPrice', identifierFieldsCustomerPropItemsSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerPropBrandSpecialPrice && rowsCustomerPropBrandSpecialPrice.length) {
        const identifierFieldsCustomerPropBrandSpecialPrice = ['cmpCode', 'custPropCode', 'brandCode']; // Change this to the correct identifier fields for 'CustomerPropBrandSpecialPrice'
        let identifierValuesCustomerPropBrandSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerPropBrandSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerPropBrandSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custPropCode , updatedRecord.brandCode];
      
          identifierValuesCustomerPropBrandSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerPropBrandSpecialPrice', updatedRecord, identifierFieldsCustomerPropBrandSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerPropBrandSpecialPrice = admin.firestore().collection('CustomerPropBrandSpecialPrice');
        const firestoreQueryCustomerPropBrandSpecialPrice = await firestoreCollectionCustomerPropBrandSpecialPrice.get();
        const firestoreDocumentsCustomerPropBrandSpecialPrice = firestoreQueryCustomerPropBrandSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerPropBrandSpecialPrice = firestoreDocumentsCustomerPropBrandSpecialPrice.filter(doc =>
          !identifierValuesCustomerPropBrandSpecialPrice.some(values =>
            identifierFieldsCustomerPropBrandSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerPropBrandSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerPropBrandSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerPropBrandSpecialPrice', identifierFieldsCustomerPropBrandSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerPropGroupSpecialPrice && rowsCustomerPropGroupSpecialPrice.length) {
        const identifierFieldsCustomerPropGroupSpecialPrice = ['cmpCode', 'custGroupCode', 'propCode']; // Change this to the correct identifier fields for 'CustomerPropGroupSpecialPrice'
        let identifierValuesCustomerPropGroupSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerPropGroupSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerPropGroupSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.propCode];
      
          identifierValuesCustomerPropGroupSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerPropGroupSpecialPrice', updatedRecord, identifierFieldsCustomerPropGroupSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerPropGroupSpecialPrice = admin.firestore().collection('CustomerPropGroupSpecialPrice');
        const firestoreQueryCustomerPropGroupSpecialPrice = await firestoreCollectionCustomerPropGroupSpecialPrice.get();
        const firestoreDocumentsCustomerPropGroupSpecialPrice = firestoreQueryCustomerPropGroupSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerPropGroupSpecialPrice = firestoreDocumentsCustomerPropGroupSpecialPrice.filter(doc =>
          !identifierValuesCustomerPropGroupSpecialPrice.some(values =>
            identifierFieldsCustomerPropGroupSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerPropGroupSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerPropGroupSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerPropGroupSpecialPrice', identifierFieldsCustomerPropGroupSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
      if (rowsCustomerPropCategSpecialPrice && rowsCustomerPropCategSpecialPrice.length) {
        const identifierFieldsCustomerPropCategSpecialPrice = ['cmpCode', 'custPropCode', 'categCode']; // Change this to the correct identifier fields for 'CustomerPropCategSpecialPrice'
        let identifierValuesCustomerPropCategSpecialPrice = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustomerPropCategSpecialPrice.length; i++) {
          const updatedRecord = rowsCustomerPropCategSpecialPrice[i];
          const compositeIdentifierValue = [updatedRecord.cmpCode , updatedRecord.custGroupCode , updatedRecord.categCode];
      
          identifierValuesCustomerPropCategSpecialPrice.push(compositeIdentifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustomerPropCategSpecialPrice', updatedRecord, identifierFieldsCustomerPropCategSpecialPrice, ...compositeIdentifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustomerPropCategSpecialPrice = admin.firestore().collection('CustomerPropCategSpecialPrice');
        const firestoreQueryCustomerPropCategSpecialPrice = await firestoreCollectionCustomerPropCategSpecialPrice.get();
        const firestoreDocumentsCustomerPropCategSpecialPrice = firestoreQueryCustomerPropCategSpecialPrice.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustomerPropCategSpecialPrice = firestoreDocumentsCustomerPropCategSpecialPrice.filter(doc =>
          !identifierValuesCustomerPropCategSpecialPrice.some(values =>
            identifierFieldsCustomerPropCategSpecialPrice.every((field, index) => values[index] === doc[field]))
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustomerPropCategSpecialPrice) {
          const compositeIdentifierValueToDelete = identifierFieldsCustomerPropCategSpecialPrice.map(field => docToDelete[field]);
          await deleteFirestoreOnSqlServerDelete('CustomerPropCategSpecialPrice', identifierFieldsCustomerPropCategSpecialPrice, ...compositeIdentifierValueToDelete);
        }
      }
      
    
        console.log(`Document added to Customers collection with IDs: ${docRefCustomers?.id}, ${docRefCustomerAddresses?.id}, ${docRefCustomerContacts?.id}, ${docRefCustomerProperties?.id}, ${docRefCustomerAttachments?.id}, ${docRefCustomerItemsSpecialPrice?.id}, ${docRefCustomerBrandSpecialPrice?.id}, ${docRefCustomerGroupSpecialPrice?.id}, ${docRefCustomerCategSpecialPrice?.id}, ${docRefCustomerGroupItemsSpecialPrice?.id}, ${docRefCustomerGroupBrandSpecialPrice?.id}, ${docRefCustomerGroupGroupSpecialPrice?.id}, ${docRefCustomerGroupCategSpecialPrice?.id}, ${docRefCustomerPropItemsSpecialPrice?.id}, ${docRefCustomerPropBrandSpecialPrice?.id}, ${docRefCustomerPropGroupSpecialPrice?.id}, ${docRefCustomerPropCategSpecialPrice?.id}`);
      
 
      if (rowsCompanies && rowsCompanies.length) {
        const identifierFieldCompanies = 'cmpCode'; // Change this to the correct identifier field for 'Companies'
        let identifierValuesCompanies = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCompanies.length; i++) {
          const updatedRecord = rowsCompanies[i];
          const identifierValue = updatedRecord[identifierFieldCompanies]; // Assuming 'cmpCode' is the identifier value for 'Companies'
      
          identifierValuesCompanies.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('Companies', updatedRecord, [identifierFieldCompanies], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCompanies = admin.firestore().collection('Companies');
        const firestoreQueryCompanies = await firestoreCollectionCompanies.get();
        const firestoreDocumentsCompanies = firestoreQueryCompanies.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCompanies = firestoreDocumentsCompanies.filter(doc =>
          !identifierValuesCompanies.includes(doc[identifierFieldCompanies])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCompanies) {
          await deleteFirestoreOnSqlServerDelete('Companies', [identifierFieldCompanies], docToDelete[identifierFieldCompanies]);
        }
      }
      
      if (rowsDepartments && rowsDepartments.length) {
        const identifierFieldDepartments = 'depCode'; // Change this to the correct identifier field for 'Departments'
        let identifierValuesDepartments = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsDepartments.length; i++) {
          const updatedRecord = rowsDepartments[i];
          const identifierValue = updatedRecord[identifierFieldDepartments]; // Assuming 'depCode' is the identifier value for 'Departments'
      
          identifierValuesDepartments.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('Departments', updatedRecord, [identifierFieldDepartments], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionDepartments = admin.firestore().collection('Departments');
        const firestoreQueryDepartments = await firestoreCollectionDepartments.get();
        const firestoreDocumentsDepartments = firestoreQueryDepartments.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteDepartments = firestoreDocumentsDepartments.filter(doc =>
          !identifierValuesDepartments.includes(doc[identifierFieldDepartments])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteDepartments) {
          await deleteFirestoreOnSqlServerDelete('Departments', [identifierFieldDepartments], docToDelete[identifierFieldDepartments]);
        }
      }
      
      if (rowsExchangeRate && rowsExchangeRate.length) {
        const identifierFieldExchangeRate = 'curCode'; // Change this to the correct identifier field for 'ExchangeRate'
        let identifierValuesExchangeRate = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsExchangeRate.length; i++) {
          const updatedRecord = rowsExchangeRate[i];
          const identifierValue = updatedRecord[identifierFieldExchangeRate]; // Assuming 'curCode' is the identifier value for 'ExchangeRate'
      
          identifierValuesExchangeRate.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('ExchangeRate', updatedRecord, [identifierFieldExchangeRate], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionExchangeRate = admin.firestore().collection('ExchangeRate');
        const firestoreQueryExchangeRate = await firestoreCollectionExchangeRate.get();
        const firestoreDocumentsExchangeRate = firestoreQueryExchangeRate.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteExchangeRate = firestoreDocumentsExchangeRate.filter(doc =>
          !identifierValuesExchangeRate.includes(doc[identifierFieldExchangeRate])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteExchangeRate) {
          await deleteFirestoreOnSqlServerDelete('ExchangeRate', [identifierFieldExchangeRate], docToDelete[identifierFieldExchangeRate]);
        }
      }
      
      if (rowsCurrencies && rowsCurrencies.length) {
        const identifierFieldCurrencies = 'curCode'; // Change this to the correct identifier field for 'Currencies'
        let identifierValuesCurrencies = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCurrencies.length; i++) {
          const updatedRecord = rowsCurrencies[i];
          const identifierValue = updatedRecord[identifierFieldCurrencies]; // Assuming 'curCode' is the identifier value for 'Currencies'
      
          identifierValuesCurrencies.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('Currencies', updatedRecord, [identifierFieldCurrencies], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCurrencies = admin.firestore().collection('Currencies');
        const firestoreQueryCurrencies = await firestoreCollectionCurrencies.get();
        const firestoreDocumentsCurrencies = firestoreQueryCurrencies.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCurrencies = firestoreDocumentsCurrencies.filter(doc =>
          !identifierValuesCurrencies.includes(doc[identifierFieldCurrencies])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCurrencies) {
          await deleteFirestoreOnSqlServerDelete('Currencies', [identifierFieldCurrencies], docToDelete[identifierFieldCurrencies]);
        }
      }
      
      if (rowsVATGroups && rowsVATGroups.length) {
        const identifierFieldVATGroups = 'vatCode'; // Change this to the correct identifier field for 'VATGroups'
        let identifierValuesVATGroups = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsVATGroups.length; i++) {
          const updatedRecord = rowsVATGroups[i];
          const identifierValue = updatedRecord[identifierFieldVATGroups]; // Assuming 'vatCode' is the identifier value for 'VATGroups'
      
          identifierValuesVATGroups.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('VATGroups', updatedRecord, [identifierFieldVATGroups], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionVATGroups = admin.firestore().collection('VATGroups');
        const firestoreQueryVATGroups = await firestoreCollectionVATGroups.get();
        const firestoreDocumentsVATGroups = firestoreQueryVATGroups.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteVATGroups = firestoreDocumentsVATGroups.filter(doc =>
          !identifierValuesVATGroups.includes(doc[identifierFieldVATGroups])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteVATGroups) {
          await deleteFirestoreOnSqlServerDelete('VATGroups', [identifierFieldVATGroups], docToDelete[identifierFieldVATGroups]);
        }
      }
      
      if (rowsCustGroups && rowsCustGroups.length) {
        const identifierFieldCustGroups = 'grpCode'; // Change this to the correct identifier field for 'CustGroups'
        let identifierValuesCustGroups = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustGroups.length; i++) {
          const updatedRecord = rowsCustGroups[i];
          const identifierValue = updatedRecord[identifierFieldCustGroups]; // Assuming 'grpCode' is the identifier value for 'CustGroups'
      
          identifierValuesCustGroups.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustGroups', updatedRecord, [identifierFieldCustGroups], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustGroups = admin.firestore().collection('CustGroups');
        const firestoreQueryCustGroups = await firestoreCollectionCustGroups.get();
        const firestoreDocumentsCustGroups = firestoreQueryCustGroups.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustGroups = firestoreDocumentsCustGroups.filter(doc =>
          !identifierValuesCustGroups.includes(doc[identifierFieldCustGroups])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustGroups) {
          await deleteFirestoreOnSqlServerDelete('CustGroups', [identifierFieldCustGroups], docToDelete[identifierFieldCustGroups]);
        }
      }
      
      if (rowsCustProperties && rowsCustProperties.length) {
        const identifierFieldCustProperties = 'propCode'; // Change this to the correct identifier field for 'CustProperties'
        let identifierValuesCustProperties = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsCustProperties.length; i++) {
          const updatedRecord = rowsCustProperties[i];
          const identifierValue = updatedRecord[identifierFieldCustProperties]; // Assuming 'propCode' is the identifier value for 'CustProperties'
      
          identifierValuesCustProperties.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('CustProperties', updatedRecord, [identifierFieldCustProperties], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionCustProperties = admin.firestore().collection('CustProperties');
        const firestoreQueryCustProperties = await firestoreCollectionCustProperties.get();
        const firestoreDocumentsCustProperties = firestoreQueryCustProperties.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteCustProperties = firestoreDocumentsCustProperties.filter(doc =>
          !identifierValuesCustProperties.includes(doc[identifierFieldCustProperties])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteCustProperties) {
          await deleteFirestoreOnSqlServerDelete('CustProperties', [identifierFieldCustProperties], docToDelete[identifierFieldCustProperties]);
        }
      }
      
      if (rowsRegions && rowsRegions.length) {
        const identifierFieldRegions = 'regCode'; // Change this to the correct identifier field for 'Regions'
        let identifierValuesRegions = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsRegions.length; i++) {
          const updatedRecord = rowsRegions[i];
          const identifierValue = updatedRecord[identifierFieldRegions]; // Assuming 'regCode' is the identifier value for 'Regions'
      
          identifierValuesRegions.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('Regions', updatedRecord, [identifierFieldRegions], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionRegions = admin.firestore().collection('Regions');
        const firestoreQueryRegions = await firestoreCollectionRegions.get();
        const firestoreDocumentsRegions = firestoreQueryRegions.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteRegions = firestoreDocumentsRegions.filter(doc =>
          !identifierValuesRegions.includes(doc[identifierFieldRegions])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteRegions) {
          await deleteFirestoreOnSqlServerDelete('Regions', [identifierFieldRegions], docToDelete[identifierFieldRegions]);
        }
      }
      
      if (rowsWarehouses && rowsWarehouses.length) {
        const identifierFieldWarehouses = 'whsCode'; // Change this to the correct identifier field for 'Warehouses'
        let identifierValuesWarehouses = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsWarehouses.length; i++) {
          const updatedRecord = rowsWarehouses[i];
          const identifierValue = updatedRecord[identifierFieldWarehouses]; // Assuming 'whsCode' is the identifier value for 'Warehouses'
      
          identifierValuesWarehouses.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('Warehouses', updatedRecord, [identifierFieldWarehouses], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionWarehouses = admin.firestore().collection('Warehouses');
        const firestoreQueryWarehouses = await firestoreCollectionWarehouses.get();
        const firestoreDocumentsWarehouses = firestoreQueryWarehouses.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteWarehouses = firestoreDocumentsWarehouses.filter(doc =>
          !identifierValuesWarehouses.includes(doc[identifierFieldWarehouses])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteWarehouses) {
          await deleteFirestoreOnSqlServerDelete('Warehouses', [identifierFieldWarehouses], docToDelete[identifierFieldWarehouses]);
        }
      }
      
      if (rowsPaymentTerms && rowsPaymentTerms.length) {
        const identifierFieldPaymentTerms = 'ptCode'; // Change this to the correct identifier field for 'PaymentTerms'
        let identifierValuesPaymentTerms = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsPaymentTerms.length; i++) {
          const updatedRecord = rowsPaymentTerms[i];
          const identifierValue = updatedRecord[identifierFieldPaymentTerms]; // Assuming 'ptCode' is the identifier value for 'PaymentTerms'
      
          identifierValuesPaymentTerms.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('PaymentTerms', updatedRecord, [identifierFieldPaymentTerms], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionPaymentTerms = admin.firestore().collection('PaymentTerms');
        const firestoreQueryPaymentTerms = await firestoreCollectionPaymentTerms.get();
        const firestoreDocumentsPaymentTerms = firestoreQueryPaymentTerms.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeletePaymentTerms = firestoreDocumentsPaymentTerms.filter(doc =>
          !identifierValuesPaymentTerms.includes(doc[identifierFieldPaymentTerms])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeletePaymentTerms) {
          await deleteFirestoreOnSqlServerDelete('PaymentTerms', [identifierFieldPaymentTerms], docToDelete[identifierFieldPaymentTerms]);
        }
      }
      
      if (rowsSalesEmployees && rowsSalesEmployees.length) {
        const identifierFieldSalesEmployees = 'seCode'; // Change this to the correct identifier field for 'SalesEmployees'
        let identifierValuesSalesEmployees = [];
      
        // Update or add documents in Firestore
        for (let i = 0; i < rowsSalesEmployees.length; i++) {
          const updatedRecord = rowsSalesEmployees[i];
          const identifierValue = updatedRecord[identifierFieldSalesEmployees]; // Assuming 'seCode' is the identifier value for 'SalesEmployees'
      
          identifierValuesSalesEmployees.push(identifierValue); // Store identifier values for later comparison
      
          // Update or add the document in Firestore
          await updateFirestoreOnSqlServerUpdate('SalesEmployees', updatedRecord, [identifierFieldSalesEmployees], identifierValue);
        }
      
        // Fetch documents from Firestore
        const firestoreCollectionSalesEmployees = admin.firestore().collection('SalesEmployees');
        const firestoreQuerySalesEmployees = await firestoreCollectionSalesEmployees.get();
        const firestoreDocumentsSalesEmployees = firestoreQuerySalesEmployees.docs.map(doc => doc.data());
      
        // Identify documents in Firestore that are not in SQL Server results
        const documentsToDeleteSalesEmployees = firestoreDocumentsSalesEmployees.filter(doc =>
          !identifierValuesSalesEmployees.includes(doc[identifierFieldSalesEmployees])
        );
      
        // Delete Firestore documents that are not in SQL Server results
        for (const docToDelete of documentsToDeleteSalesEmployees) {
          await deleteFirestoreOnSqlServerDelete('SalesEmployees', [identifierFieldSalesEmployees], docToDelete[identifierFieldSalesEmployees]);
        }
      }
      
      if (rowsSalesEmployeesCustomers && rowsSalesEmployeesCustomers.length) {
const identifierFieldsSalesEmployeesCustomers = ['seCode', 'custCode', 'cmpCode']; // Change this to the correct identifier fields for 'SalesEmployeesCustomers'
let identifierValuesSalesEmployeesCustomers = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsSalesEmployeesCustomers.length; i++) {
const updatedRecord = rowsSalesEmployeesCustomers[i];
const identifierValue = [updatedRecord.seCode , updatedRecord.custCode , updatedRecord.cmpCode];

identifierValuesSalesEmployeesCustomers.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('SalesEmployeesCustomers', updatedRecord, identifierFieldsSalesEmployeesCustomers, ...identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionSalesEmployeesCustomers = admin.firestore().collection('SalesEmployeesCustomers');
const firestoreQuerySalesEmployeesCustomers = await firestoreCollectionSalesEmployeesCustomers.get();
const firestoreDocumentsSalesEmployeesCustomers = firestoreQuerySalesEmployeesCustomers.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteSalesEmployeesCustomers = firestoreDocumentsSalesEmployeesCustomers.filter(doc =>
!identifierValuesSalesEmployeesCustomers.some(values =>
  identifierFieldsSalesEmployeesCustomers.every((field, index) => values[index] === doc[field]))
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteSalesEmployeesCustomers) {
const identifierValue = identifierFieldsSalesEmployeesCustomers.map(field => docToDelete[field]);
await deleteFirestoreOnSqlServerDelete('SalesEmployeesCustomers', identifierFieldsSalesEmployeesCustomers, ...identifierValue);
}
}

if (rowsSalesEmployeesDepartments && rowsSalesEmployeesDepartments.length) {
const identifierFieldsSalesEmployeesDepartments = ['cmpCode', 'seCode', 'deptCode']; // Change this to the correct identifier fields for 'SalesEmployeesDepartments'
let identifierValuesSalesEmployeesDepartments = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsSalesEmployeesDepartments.length; i++) {
const updatedRecord = rowsSalesEmployeesDepartments[i];
const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.deptCode];

identifierValuesSalesEmployeesDepartments.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('SalesEmployeesDepartments', updatedRecord, identifierFieldsSalesEmployeesDepartments, ...identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionSalesEmployeesDepartments = admin.firestore().collection('SalesEmployeesDepartments');
const firestoreQuerySalesEmployeesDepartments = await firestoreCollectionSalesEmployeesDepartments.get();
const firestoreDocumentsSalesEmployeesDepartments = firestoreQuerySalesEmployeesDepartments.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteSalesEmployeesDepartments = firestoreDocumentsSalesEmployeesDepartments.filter(doc =>
!identifierValuesSalesEmployeesDepartments.some(values =>
  identifierFieldsSalesEmployeesDepartments.every((field, index) => values[index] === doc[field])
)
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteSalesEmployeesDepartments) {
const identifierValue = identifierFieldsSalesEmployeesDepartments.map(field => docToDelete[field]);
await deleteFirestoreOnSqlServerDelete('SalesEmployeesDepartments', identifierFieldsSalesEmployeesDepartments, ...identifierValue);
}
}
if (rowsSalesEmployeesItemsBrands && rowsSalesEmployeesItemsBrands.length) {
const identifierFieldsSalesEmployeesItemsBrands = ['cmpCode', 'seCode', 'brandCode']; // Change this to the correct identifier fields for 'SalesEmployeesItemsBrands'
let identifierValuesSalesEmployeesItemsBrands = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsSalesEmployeesItemsBrands.length; i++) {
const updatedRecord = rowsSalesEmployeesItemsBrands[i];
const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.brandCode];
identifierValuesSalesEmployeesItemsBrands.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('SalesEmployeesItemsBrands', updatedRecord, identifierFieldsSalesEmployeesItemsBrands, ...identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionSalesEmployeesItemsBrands = admin.firestore().collection('SalesEmployeesItemsBrands');
const firestoreQuerySalesEmployeesItemsBrands = await firestoreCollectionSalesEmployeesItemsBrands.get();
const firestoreDocumentsSalesEmployeesItemsBrands = firestoreQuerySalesEmployeesItemsBrands.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteSalesEmployeesItemsBrands = firestoreDocumentsSalesEmployeesItemsBrands.filter(doc =>
!identifierValuesSalesEmployeesItemsBrands.some(values =>
  identifierFieldsSalesEmployeesItemsBrands.every((field, index) => values[index] === doc[field]))
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteSalesEmployeesItemsBrands) {
const identifierValue = identifierFieldsSalesEmployeesItemsBrands.map(field => docToDelete[field]);
await deleteFirestoreOnSqlServerDelete('SalesEmployeesItemsBrands', identifierFieldsSalesEmployeesItemsBrands, ...identifierValue);
}
}

if (rowsSalesEmployeesItemsCategories && rowsSalesEmployeesItemsCategories.length) {
const identifierFieldsSalesEmployeesItemsCategories = ['cmpCode', 'seCode', 'categCode']; // Change this to the correct identifier fields for 'SalesEmployeesItemsCategories'
let identifierValuesSalesEmployeesItemsCategories = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsSalesEmployeesItemsCategories.length; i++) {
const updatedRecord = rowsSalesEmployeesItemsCategories[i];
const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.categCode];

identifierValuesSalesEmployeesItemsCategories.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('SalesEmployeesItemsCategories', updatedRecord, identifierFieldsSalesEmployeesItemsCategories, ...identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionSalesEmployeesItemsCategories = admin.firestore().collection('SalesEmployeesItemsCategories');
const firestoreQuerySalesEmployeesItemsCategories = await firestoreCollectionSalesEmployeesItemsCategories.get();
const firestoreDocumentsSalesEmployeesItemsCategories = firestoreQuerySalesEmployeesItemsCategories.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteSalesEmployeesItemsCategories = firestoreDocumentsSalesEmployeesItemsCategories.filter(doc =>
!identifierValuesSalesEmployeesItemsCategories.some(values =>
  identifierFieldsSalesEmployeesItemsCategories.every((field, index) => values[index] === doc[field])
)
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteSalesEmployeesItemsCategories) {
const identifierValue = identifierFieldsSalesEmployeesItemsCategories.map(field => docToDelete[field]);
await deleteFirestoreOnSqlServerDelete('SalesEmployeesItemsCategories', identifierFieldsSalesEmployeesItemsCategories, ...identifierValue);
}
}

if (rowsSalesEmployeesItemsGroups && rowsSalesEmployeesItemsGroups.length) {
const identifierFieldsSalesEmployeesItemsGroups = ['cmpCode', 'seCode', 'groupCode']; // Change this to the correct identifier fields for 'SalesEmployeesItemsGroups'
let identifierValuesSalesEmployeesItemsGroups = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsSalesEmployeesItemsGroups.length; i++) {
const updatedRecord = rowsSalesEmployeesItemsGroups[i];
const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.groupCode];

identifierValuesSalesEmployeesItemsGroups.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('SalesEmployeesItemsGroups', updatedRecord, identifierFieldsSalesEmployeesItemsGroups, ...identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionSalesEmployeesItemsGroups = admin.firestore().collection('SalesEmployeesItemsGroups');
const firestoreQuerySalesEmployeesItemsGroups = await firestoreCollectionSalesEmployeesItemsGroups.get();
const firestoreDocumentsSalesEmployeesItemsGroups = firestoreQuerySalesEmployeesItemsGroups.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteSalesEmployeesItemsGroups = firestoreDocumentsSalesEmployeesItemsGroups.filter(doc =>
!identifierValuesSalesEmployeesItemsGroups.some(values =>
  identifierFieldsSalesEmployeesItemsGroups.every((field, index) => values[index] === doc[field])
)
);

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteSalesEmployeesItemsGroups) {
const identifierValue = identifierFieldsSalesEmployeesItemsGroups.map(field => docToDelete[field]);
await deleteFirestoreOnSqlServerDelete('SalesEmployeesItemsGroups', identifierFieldsSalesEmployeesItemsGroups, ...identifierValue);
}
}

if (rowsSalesEmployeesItems && rowsSalesEmployeesItems.length) {
const identifierFieldsSalesEmployeesItems = ['cmpCode', 'seCode', 'itemCode']; // Change this to the correct identifier fields for 'SalesEmployeesItems'
let identifierValuesSalesEmployeesItems = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsSalesEmployeesItems.length; i++) {
const updatedRecord = rowsSalesEmployeesItems[i];
const identifierValue = [updatedRecord.cmpCode , updatedRecord.seCode , updatedRecord.itemCode];

identifierValuesSalesEmployeesItems.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('SalesEmployeesItems', updatedRecord, identifierFieldsSalesEmployeesItems,...identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionSalesEmployeesItems = admin.firestore().collection('SalesEmployeesItems');
const firestoreQuerySalesEmployeesItems = await firestoreCollectionSalesEmployeesItems.get();
const firestoreDocumentsSalesEmployeesItems = firestoreQuerySalesEmployeesItems.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteSalesEmployeesItems = firestoreDocumentsSalesEmployeesItems.filter(doc =>
!identifierValuesSalesEmployeesItems.some(values =>
  identifierFieldsSalesEmployeesItems.every((field, index) => values[index] === doc[field])
));

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteSalesEmployeesItems) {
const identifierValue = identifierFieldsSalesEmployeesItems.map(field => docToDelete[field]);
await deleteFirestoreOnSqlServerDelete('SalesEmployeesItems', identifierFieldsSalesEmployeesItems, ...identifierValue);
}
}

if (rowsUsersSalesEmployees && rowsUsersSalesEmployees.length) {
const identifierFieldsUsersSalesEmployees = ['userCode', 'cmpCode', 'seCode']; // Change this to the correct identifier fields for 'UsersSalesEmployees'
let identifierValuesUsersSalesEmployees = [];

// Update or add documents in Firestore
for (let i = 0; i < rowsUsersSalesEmployees.length; i++) {
const updatedRecord = rowsUsersSalesEmployees[i];
const identifierValue = [updatedRecord.userCode , updatedRecord.cmpCode , updatedRecord.seCode];

identifierValuesUsersSalesEmployees.push(identifierValue); // Store identifier values for later comparison

// Update or add the document in Firestore
await updateFirestoreOnSqlServerUpdate('UsersSalesEmployees', updatedRecord, identifierFieldsUsersSalesEmployees, ...identifierValue);
}

// Fetch documents from Firestore
const firestoreCollectionUsersSalesEmployees = admin.firestore().collection('UsersSalesEmployees');
const firestoreQueryUsersSalesEmployees = await firestoreCollectionUsersSalesEmployees.get();
const firestoreDocumentsUsersSalesEmployees = firestoreQueryUsersSalesEmployees.docs.map(doc => doc.data());

// Identify documents in Firestore that are not in SQL Server results
const documentsToDeleteUsersSalesEmployees = firestoreDocumentsUsersSalesEmployees.filter(doc =>
!identifierValuesUsersSalesEmployees.some(values =>
  identifierFieldsUsersSalesEmployees.every((field, index) => values[index] === doc[field])
));

// Delete Firestore documents that are not in SQL Server results
for (const docToDelete of documentsToDeleteUsersSalesEmployees) {
const identifierValue = identifierFieldsUsersSalesEmployees.map(field => docToDelete[field]);
await deleteFirestoreOnSqlServerDelete('UsersSalesEmployees', identifierFieldsUsersSalesEmployees, ...identifierValue);
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