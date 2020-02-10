import 'package:acai_flutter/config/config.dart';
import 'package:acai_flutter/home/home.dart';
import 'package:acai_flutter/home/login.dart';
import 'package:acai_flutter/home/splash.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

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
          'login':(context) => Login(),
          'home':(context) => MyHomePage(title: "阿财",),
        },
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
