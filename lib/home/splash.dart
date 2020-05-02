import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  State createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    print('splash initState');
    super.initState();
    DioUtils.checkAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    print('splash build');
    DioUtils.ctx = context;
    return Container();
  }
}
