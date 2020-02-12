import 'package:acai_flutter/home/home.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  Login({this.text});

  final String text;

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController nicknameController = new TextEditingController();
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
    var response = await dio.get(url);
    var data = response.data;
    setState(() {
      var str = data['data'];
      final parser = RSAKeyParser();
      publicKey = parser.parse(str);
    });
  }

  Future signUp() async {
    String username = usernameController.text;
    String nickname = nicknameController.text;
    String password = passwordController.text;
    if (username == '' || nickname == '' || password == '') {
      return;
    }
    String text = username + ";" + nickname + ";" + password;
    var iv = IV.fromSecureRandom(256);
    var random = iv.base64;
    String encrypted =
        Encrypter(RSA(publicKey: publicKey)).encrypt(text, iv: iv).base64;
    var url = '/api/oauth/signUp';
    var dio = await DioUtils.getDio();
    var response =
        await dio.post(url, data: {'text': encrypted, 'random': random});
    var data = response.data;
    var code = data['code'];
    if (code == 0) {
      showToast("注册成功");
    } else {
      var message = data['message'];
      showToast(message);
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
    var response =
        await dio.post(url, data: {'text': encrypted, 'random': random});
    var data = response.data;
    var code = data['code'];
    if (code == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("accessToken", data['data']);
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new MyHomePage(title: '阿财'),
        ),
      );
    } else {
      var message = data['message'];
      showToast(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    DioUtils.ctx = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("登录注册"),
        automaticallyImplyLeading: false,
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
                    controller: nicknameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '昵称',
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
