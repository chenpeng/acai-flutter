import 'package:acai_flutter/config/config.dart';
import 'package:acai_flutter/home/home.dart';
import 'package:acai_flutter/home/login.dart';
import 'package:acai_flutter/home/splash.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_cupertino_localizations/flutter_cupertino_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.init('http://localhost:8000').then((e) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      dismissOtherOnShow: true,
      child: MaterialApp(
        title: '阿财DEV',
        routes: {
          'login': (context) => Login(),
          'home': (context) => MyHomePage(
                title: "阿财",
              ),
        },
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh'), // Chinese
          const Locale('en'), // English
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
//        home: MyHomePage(title: '阿财DEV'),
        home: SplashPage(),
      ),
    );
  }
}
