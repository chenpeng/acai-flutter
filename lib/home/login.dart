import 'dart:io';
import 'dart:typed_data';

import 'package:acai_flutter/util/DioUtils.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  Login({this.text});

  final String text;

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController textController = new TextEditingController();
  var publicKey;

  @override
  void initState() {
    super.initState();
    getPublicKey();
  }

  getPublicKey() async {
    var url = '/api/oauth/publicKey';
    var dio = await DioUtils.getDio();
    try {
      var response = await dio.get(url);
      if (response.statusCode == HttpStatus.ok) {
        var data = response.data;
        setState(() {
          var str = data['Data'];
          final parser = RSAKeyParser();
          publicKey = parser.parse(str);
          print("公钥：");
          print(str);
        });
      } else {
        print('查询失败:${response.statusCode}');
      }
    } catch (e) {
      print('查询失败');
    }
  }

  Future login() async {
    String text = textController.text;
    var iv = IV.fromSecureRandom(256);
    var random = iv.base64;
    String encrypted =
        Encrypter(RSA(publicKey: publicKey)).encrypt(text,iv: iv).base64;
    print(encrypted);
    var url = '/api/oauth/decrypt';
    var dio = await DioUtils.getDio();
    try {
      var response = await dio.post(url, data: {'Text': encrypted, 'Random': random});
      if (response.statusCode == HttpStatus.ok) {
        var data = response.data;
        print("返回时:");
        print(data['Data']);
      } else {
        print('查询失败:${response.statusCode}');
      }
    } catch (e) {
      print('查询失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("widget.title"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '备注',
                    )),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('加密'),
                elevation: 1,
                highlightElevation: 1,
                onPressed: login,
              )
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('获取公钥'),
                elevation: 1,
                highlightElevation: 1,
                onPressed: getPublicKey,
              )
            ],
          ),
        ],
      ),
    );
  }
}