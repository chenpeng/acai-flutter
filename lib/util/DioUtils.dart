import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioUtils {
  static Future<Dio> getDio() async {
    Dio dio = new Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dio.options.baseUrl = prefs.getString('baseUrl');
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
    return dio;
  }
}
