import 'dart:io';
import 'dart:typed_data';

import 'package:acai_flutter/util/DioUtils.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:oktoast/oktoast.dart';

class Login extends StatefulWidget {
  Login({this.text});

  final String text;

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
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
        var code = data['Code'];
        if (code == "0") {
          setState(() {
            var str = data['Data'];
            final parser = RSAKeyParser();
            publicKey = parser.parse(str);
            print("公钥：");
            print(str);
          });
        } else {
          showToast("获取公钥失败");
        }
      } else {
        print('查询失败:${response.statusCode}');
      }
    } catch (e) {
      print('查询失败');
    }
  }

  Future signUp() async {
    String username = usernameController.text;
    String password = passwordController.text;
    if (username == '' || password == '') {
      return;
    }
    String text = username + ";" + password;
    var iv = IV.fromSecureRandom(256);
    var random = iv.base64;
    String encrypted =
        Encrypter(RSA(publicKey: publicKey)).encrypt(text, iv: iv).base64;
    print(encrypted);
    var url = '/api/oauth/signUp';
    var dio = await DioUtils.getDio();
    try {
      var response =
          await dio.post(url, data: {'Text': encrypted, 'Random': random});
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

  Future signIn() async {
    String username = usernameController.text;
    String password = passwordController.text;
    if (username == '' || password == '') {
      return;
    }
    String text = username + ";" + password;
    var iv = IV.fromSecureRandom(256);
    var random = iv.base64;
    String encrypted =
        Encrypter(RSA(publicKey: publicKey)).encrypt(text, iv: iv).base64;
    print(encrypted);
    var url = '/api/oauth/signIn';
    var dio = await DioUtils.getDio();
    try {
      var response =
          await dio.post(url, data: {'Text': encrypted, 'Random': random});
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
                    controller: usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '账号',
                    )),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '密码',
                    )),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('登录'),
                elevation: 1,
                highlightElevation: 1,
                onPressed: signIn,
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
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('注册'),
                elevation: 1,
                highlightElevation: 1,
                onPressed: signUp,
              )
            ],
          ),
        ],
      ),
    );
  }
}
