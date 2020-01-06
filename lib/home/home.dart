import 'dart:io';

import 'package:acai_flutter/add/add.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List items = new List();

  findMoneyRecordList() async {
    var dio = DioUtils.getDio();
    try {
      var response = await dio.get('/api/moneyRecord');
      if (response.statusCode == HttpStatus.ok) {
        var data = response.data;
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
    findMoneyRecordList();
    super.initState();
  }

  @override
  void deactivate() {
    findMoneyRecordList();
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
                '时间：${items[index]['RecordDateTime']}'
                    '       ' +
                '备注：${items[index]['Remark']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new AddRecordWidget(title: '新增')),
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
