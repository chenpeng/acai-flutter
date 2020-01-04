import 'dart:convert';
import 'dart:io';

import 'package:acai_flutter/add/add.dart';
import 'package:acai_flutter/config/config.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List items = new List();

  _findMoneyRecordList() async {
    var url = baseUrl + '/api/moneyRecord';
    var httpClient = new HttpClient();
    httpClient.findProxy = (uri) {
      return "PROXY $proxy;";
    };
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        items = data['Data'];
      } else {
        showToast('查询失败:Http status ${response.statusCode}');
      }
    } catch (exception) {
      showToast('查询失败:$exception');
    }
    setState(() {
      items = items;
    });
  }

  @override
  void initState() {
    _findMoneyRecordList();
    super.initState();
  }

  @override
  void deactivate() {
    _findMoneyRecordList();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new ListView.builder(
        itemCount: items?.length ?? 0,
        itemBuilder: (context, index) {
          return new ListTile(
            title: new Text('金额：${items[index]['Money']}'),
            subtitle: new Text('用途：${items[index]['ClassificationName']}' +
                '       ' +
                '备注：${items[index]['Remark']}'
                '       ' +
                '时间：${items[index]['RecordDateTime']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new AddRecordWidget(title: '新增')),
          );
        },
        // onPressed: _findMoneyRecordList,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
