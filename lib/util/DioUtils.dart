import 'dart:io';
import 'package:acai_flutter/sign/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioUtils {
  static dynamic ctx;

  static Future<void> checkAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken");
    print(accessToken);
    if (accessToken == null || accessToken == '') {
      Navigator.of(ctx).pushNamed("login", arguments: "hi");
    } else {
      Navigator.of(ctx).pushNamed("home", arguments: "hi");
    }
  }

  static Future<Dio> getDio() async {
    Dio dio = new Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dio.options.baseUrl = prefs.getString('baseUrl');
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      String accessToken = prefs.getString("accessToken");
      options.headers.putIfAbsent("accessToken", () => accessToken);
      return options;
    }, onResponse: (Response response) async {
      if (response.statusCode == HttpStatus.ok) {
        Headers headers = response.headers;
        String value = headers.value("content-type");
        if (value == 'application/json; charset=utf-8') {
          var data = response.data;
          var code = data['code'];
          var message = data['message'];
          if (code == -1) {
            Navigator.push(
              ctx,
              new MaterialPageRoute(
                builder: (context) => new Login(text: '登录注册'),
              ),
            );
          }
          if (code != 0) {
            showToast(message);
          }
        }
      } else {
        showToast("未知错误" + response.statusCode.toString());
      }
      return response;
    }, onError: (DioError e) async {
      showToast("未知错误" + e.toString());
      return e;
    }));
    return dio;
  }
}
