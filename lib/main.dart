import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project/app_notifier.dart';
import 'package:project/firebase_options.dart';
import 'package:project/hive/translations_hive.dart';
import 'package:project/hive/usergroup_hive.dart';
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
      home: Consumer<AppNotifier>(
        builder: (context, appNotifier, child) {
          return FutureBuilder(
            // Use FutureBuilder to wait for both 'userBox' and 'userGroupBox' to be opened
            future: Future.wait([
              Hive.openBox('userBox'),
              Hive.openBox('userGroupBox'),
              Hive.openBox('translationsBox'),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return LoginPage(appNotifier: appNotifier);
              } else {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
