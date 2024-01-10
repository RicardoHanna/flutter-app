import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/app_notifier.dart';
import 'package:project/firebase_options.dart';
import 'package:project/hive/adminsubmenu_hive.dart';
import 'package:project/hive/authorization_hive.dart';
import 'package:project/hive/hiveuser.dart';
import 'package:project/hive/itemattach_hive.dart';
import 'package:project/hive/itembrand_hive.dart';
import 'package:project/hive/itemcateg_hive.dart';
import 'package:project/hive/itemgroup_hive.dart';
import 'package:project/hive/items_hive.dart';
import 'package:project/hive/itemsprices_hive.dart';
import 'package:project/hive/itemuom_hive.dart';
import 'package:project/hive/menu_hive.dart';
import 'package:project/hive/pricelist_hive.dart';
import 'package:project/hive/syncronizesubmenu_hive.dart';
import 'package:project/hive/systemadmin_hive.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
import 'package:project/hive/userpl_hive.dart';
import 'package:project/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(UserGroupAdapter());
  Hive.registerAdapter(TranslationsAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ItemsAdapter());
  Hive.registerAdapter(PriceListAdapter());
  Hive.registerAdapter(ItemsPricesAdapter());
  Hive.registerAdapter(ItemAttachAdapter());
  Hive.registerAdapter(ItemGroupAdapter());
  Hive.registerAdapter(ItemCategAdapter());
  Hive.registerAdapter(ItemBrandAdapter());
    Hive.registerAdapter(ItemUOMAdapter());
Hive.registerAdapter(UserPLAdapter());
Hive.registerAdapter(AuthorizationAdapter());
Hive.registerAdapter(MenuAdapter());
Hive.registerAdapter(AdminSubMenuAdapter());
Hive.registerAdapter(SynchronizeSubMenuAdapter());
Hive.registerAdapter(SystemAdminAdapter());

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
   
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppNotifier>(
          create: (context) => AppNotifier(const Locale('en'), '', 22),
        ),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: L10n.all,
      locale: Provider.of<AppNotifier>(context).userLocale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LoginPage(appNotifier: Provider.of<AppNotifier>(context)),
    );
  }
}
