import 'package:acai_flutter/config/config.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class DioUtils {
  static Dio getDio(){
    Dio dio = new Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.findProxy = (uri) {
        return "PROXY localhost:6152";
      };
    };
    return dio;
  }
}