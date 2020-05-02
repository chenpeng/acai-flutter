import 'package:acai_flutter/config/config.dart';
import 'package:acai_flutter/home/home.dart';
import 'package:acai_flutter/sign/login.dart';
import 'package:acai_flutter/home/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.init('http://localhost:8000').then((e) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('main build');
    return OKToast(
      dismissOtherOnShow: true,
      child: CupertinoApp(
        title: '阿财DEV',
        routes: {
          'login': (context) => Login(),
          'splash': (context) => SplashPage(),
          'home': (context) => MyHomePage(
                title: "阿财",
              ),
        },
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh'),
          const Locale('en'),
        ],
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
        ),
        home: SplashPage(),
      ),
    );
  }
}
