import 'package:acai_flutter/config/config.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'home/home.dart';

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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: '阿财DEV'),
      ),
    );
  }
}
