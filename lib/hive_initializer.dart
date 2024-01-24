// hive_initializer.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project/hive/companiesconnection_hive.dart';
import 'package:project/hive/pricelistauthorization_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/companies_hive.dart';
import 'package:project/hive/currencies_hive.dart';
import 'package:project/hive/custgroups_hive.dart';
import 'package:project/hive/customeraddresses_hive.dart';
import 'package:project/hive/customerattachments_hive.dart';
import 'package:project/hive/customerbrandsspecialprice_hive.dart';
import 'package:project/hive/customercategspecialprice_hive.dart';
import 'package:project/hive/customercontacts_hive.dart';
import 'package:project/hive/customergroupbrandspecialprice_hive.dart';
import 'package:project/hive/customergroupcategspecialprice_hive.dart';
import 'package:project/hive/customergroupgroupspecialprice_hive.dart';
import 'package:project/hive/customergroupitemsspecialprice_hive.dart';
import 'package:project/hive/customergroupsspecialprice_hive.dart';
import 'package:project/hive/customeritemsspecialprice_hive.dart';
import 'package:project/hive/customerpropbrandspecialprice_hive.dart';
import 'package:project/hive/customerpropcategspecialprice_hive.dart';
import 'package:project/hive/customerproperties_hive.dart';
import 'package:project/hive/customerpropgroupspecialprice_hive.dart';
import 'package:project/hive/customerpropitemsspecialprice_hive.dart';
import 'package:project/hive/customers_hive.dart';
import 'package:project/hive/custproperties_hive.dart';
import 'package:project/hive/departements_hive.dart';
import 'package:project/hive/exchangerate_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/itemattach_hive.dart';
import 'package:project/hive/itembrand_hive.dart';
import 'package:project/hive/itemcateg_hive.dart';
import 'package:project/hive/itemgroup_hive.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:project/hive/itemuom_hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/paymentterms_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/regions_hive.dart';
import 'package:project/hive/salesemployees_hive.dart';
import 'package:project/hive/salesemployeescustomers_hive.dart';
import 'package:project/hive/salesemployeesdepartments_hive.dart';
import 'package:project/hive/salesemployeesitems_hive.dart';
import 'package:project/hive/salesemployeesitemsbrands_hive.dart';
import 'package:project/hive/salesemployeesitemscategories_hive.dart';
import 'package:project/hive/salesemployeesitemsgroups_hive.dart';
import 'package:project/hive/syncronizesubmenu_hive.dart';
import 'package:project/hive/systemadmin_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/hive/userpl_hive.dart';
import 'package:project/hive/userssalesemployees_hive.dart';
import 'package:project/hive/vatgroups_hive.dart';
import 'package:project/hive/warehouses_hive.dart';
import 'package:project/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'package:provider/provider.dart';

// Add other imports for your Hive adapters

Future<void> initializeHive() async {
  await Hive.initFlutter();

  Hive
    ..registerAdapter(UserGroupAdapter())
    ..registerAdapter(TranslationsAdapter())
    ..registerAdapter(UserAdapter())
    ..registerAdapter(ItemsAdapter())
    ..registerAdapter(PriceListAdapter())
    ..registerAdapter(ItemsPricesAdapter())
    ..registerAdapter(ItemAttachAdapter())
    ..registerAdapter(ItemGroupAdapter())
    ..registerAdapter(ItemCategAdapter())
    ..registerAdapter(ItemBrandAdapter())
    ..registerAdapter(ItemUOMAdapter())
    ..registerAdapter(UserPLAdapter())
    ..registerAdapter(AuthorizationAdapter())
    ..registerAdapter(MenuAdapter())
    ..registerAdapter(AdminSubMenuAdapter())
    ..registerAdapter(SynchronizeSubMenuAdapter())
    ..registerAdapter(SystemAdminAdapter())
    ..registerAdapter(CompaniesAdapter())
    ..registerAdapter(DepartementsAdapter())
    ..registerAdapter(ExchangeRateAdapter())
    ..registerAdapter(CurrenciesAdapter())
    ..registerAdapter(VATGroupsAdapter())
    ..registerAdapter(CustGroupsAdapter())
    ..registerAdapter(CustPropertiesAdapter())
    ..registerAdapter(RegionsAdapter())
    ..registerAdapter(WarehousesAdapter())
    ..registerAdapter(PaymentTermsAdapter())
    ..registerAdapter(SalesEmployeesAdapter())
  
  
    ..registerAdapter(SalesEmployeesCustomersAdapter())
    ..registerAdapter(SalesEmployeesDepartementsAdapter())
    ..registerAdapter(SalesEmployeesItemsBrandsAdapter())
    ..registerAdapter(SalesEmployeesItemsCategoriesAdapter())
    ..registerAdapter(SalesEmployeesItemsGroupsAdapter())
    ..registerAdapter(SalesEmployeesItemsAdapter())
    ..registerAdapter(UserSalesEmployeesAdapter())
    ..registerAdapter(CustomersAdapter())
    ..registerAdapter(CustomerAddressesAdapter())
    ..registerAdapter(CustomerContactsAdapter())
    ..registerAdapter(CustomerPropertiesAdapter())
    ..registerAdapter(CustomerAttachmentsAdapter())
    ..registerAdapter(CustomerItemsSpecialPriceAdapter())
    ..registerAdapter(CustomerBrandsSpecialPriceAdapter())
    ..registerAdapter(CustomerGroupsSpecialPriceAdapter())
    ..registerAdapter(CustomerCategSpecialPriceAdapter())
    ..registerAdapter(CustomerGroupItemsSpecialPriceAdapter())
    ..registerAdapter(CustomerGroupBrandSpecialPriceAdapter())
    ..registerAdapter(CustomerGroupGroupSpecialPriceAdapter())
    ..registerAdapter(CustomerGroupCategSpecialPriceAdapter())
    ..registerAdapter(CustomerPropItemsSpecialPriceAdapter())
    ..registerAdapter(CustomerPropBrandSpecialPriceAdapter())
    ..registerAdapter(CustomerPropGroupSpecialPriceAdapter())
    ..registerAdapter(CustomerPropCategSpecialPriceAdapter())

    ..registerAdapter(CompaniesConnectionAdapter())
    ..registerAdapter(PriceListAuthorizationAdapter());
}

Future<void> openHiveBoxes() async {
  await Hive.openBox<Items>('items');
  await Hive.openBox<PriceList>('pricelists');
  await Hive.openBox('userBox');
  await Hive.openBox<Translations>('translationsBox');
  await Hive.openBox<UserGroup>('userGroupBox');
  await Hive.openBox<ItemAttach>('itemattach');
  await Hive.openBox<ItemsPrices>('itemprices');
  await Hive.openBox<ItemGroup>('itemgroup');
  await Hive.openBox<ItemCateg>('itemcateg');
  await Hive.openBox<ItemBrand>('itembrand');
  await Hive.openBox<ItemUOM>('itemuom');
  await Hive.openBox<UserPL>('userpl');
  await Hive.openBox<Authorization>('authorizationBox');
  await Hive.openBox<Menu>('menuBox');
  await Hive.openBox<AdminSubMenu>('adminSubMenuBox');
  await Hive.openBox<SynchronizeSubMenu>('synchronizeSubMenu');
  await Hive.openBox<SystemAdmin>('systemAdminBox');

  await Hive.openBox<Companies>('companiesBox');
  await Hive.openBox<Departements>('departmentsBox');
  await Hive.openBox<ExchangeRate>('exchangeRateBox');
  await Hive.openBox<Currencies>('currenciesBox');
  await Hive.openBox<VATGroups>('vatGroupsBox');
  await Hive.openBox<CustGroups>('custGroupsBox');
  await Hive.openBox<CustProperties>('custPropertiesBox');
  await Hive.openBox<Regions>('regionsBox');
  await Hive.openBox<Warehouses>('warehousesBox');
  await Hive.openBox<PaymentTerms>('paymentTermsBox');
  await Hive.openBox<SalesEmployees>('salesEmployeesBox');
  await Hive.openBox<SalesEmployeesCustomers>('salesEmployeesCustomersBox');
  await Hive.openBox<SalesEmployeesDepartements>('salesEmployeesDepartmentsBox');
  await Hive.openBox<SalesEmployeesItemsBrands>('salesEmployeesItemsBrandsBox');
  await Hive.openBox<SalesEmployeesItemsCategories>('salesEmployeesItemsCategoriesBox');
  await Hive.openBox<SalesEmployeesItemsGroups>('salesEmployeesItemsGroupsBox');
  await Hive.openBox<SalesEmployeesItems>('salesEmployeesItemsBox');

  await Hive.openBox<UserSalesEmployees>('userSalesEmployeesBox');
  await Hive.openBox<Customers>('customersBox');
  await Hive.openBox<CustomerAddresses>('customerAddressesBox');
  await Hive.openBox<CustomerContacts>('customerContactsBox');
  await Hive.openBox<CustomerProperties>('customerPropertiesBox');
  await Hive.openBox<CustomerAttachments>('customerAttachmentsBox');

  await Hive.openBox<CustomerItemsSpecialPrice>('customerItemsSpecialPriceBox');
  await Hive.openBox<CustomerBrandsSpecialPrice>('customerBrandsSpecialPriceBox');
  await Hive.openBox<CustomerGroupsSpecialPrice>('customerGroupsSpecialPriceBox');
  await Hive.openBox<CustomerCategSpecialPrice>('customerCategSpecialPriceBox');
  await Hive.openBox<CustomerGroupItemsSpecialPrice>('customerGroupItemsSpecialPriceBox');
  await Hive.openBox<CustomerGroupBrandSpecialPrice>('customerGroupBrandSpecialPriceBox');

  await Hive.openBox<CustomerGroupGroupSpecialPrice>('customerGroupGroupSpecialPriceBox');
  await Hive.openBox<CustomerGroupCategSpecialPrice>('customerGroupCategSpecialPriceBox');
  await Hive.openBox<CustomerPropItemsSpecialPrice>('customerPropItemsSpecialPriceBox');
  await Hive.openBox<CustomerPropBrandSpecialPrice>('customerPropBrandSpecialPriceBox');
  await Hive.openBox<CustomerPropGroupSpecialPrice>('customerPropGroupSpecialPriceBox');
  await Hive.openBox<CustomerPropCategSpecialPrice>('customerPropCategSpecialPriceBox');

  await Hive.openBox<CompaniesConnection>('companiesConnectionBox');

  await Hive.openBox<PriceListAuthorization>('pricelistAuthorizationBox');
  
}
