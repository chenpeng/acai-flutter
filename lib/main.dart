import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'home/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return OKToast(
      dismissOtherOnShow: true,
      child: MaterialApp(
        title: '阿财',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: '阿财'),
      ),
    );
  }
}
