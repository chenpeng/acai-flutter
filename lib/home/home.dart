import 'dart:io';

import 'package:acai_flutter/add/add.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List items = new List();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  int pageIndex = 1;
  int pageSize = 10;

  void onRefresh() async {
    setState(() {
      pageIndex = 1;
      items.clear();
    });
    // monitor network fetch
    await findMoneyRecordList();
    // if failed,use refreshFailed()
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    setState(() {
      pageIndex++;
    });
    // monitor network fetch
    await findMoneyRecordList();
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    refreshController.loadComplete();
  }

  findMoneyRecordList() async {
    var dio = await DioUtils.getDio();
    try {
      var response = await dio.get('/api/moneyRecord',
          queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize});
      if (response.statusCode == HttpStatus.ok) {
        var data = response.data;
        if (data['Data'].length > 0) {
          setState(() {
            items.addAll(data['Data']);
          });
        }
      } else {
        showToast('查询失败:Http status ${response.statusCode}');
      }
    } catch (exception) {
      showToast('查询失败:$exception');
    }
  }

  @override
  void initState() {
    super.initState();
    findMoneyRecordList();
  }

  @override
  void deactivate() {
    findMoneyRecordList();
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("松手,加载更多!");
            } else {
              body = Text("没有更多数据了!");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: refreshController,
        onRefresh: onRefresh,
        onLoading: onLoading,
        child: ListView.builder(
          itemBuilder: (context, index) => Card(
              child: Center(
                  child: new ListTile(
            title: new Text('金额：${items[index]['Money']}'),
            subtitle: new Text('用途：${items[index]['ClassificationName']}' +
                '             ' +
                '时间：${DateTime.parse(items[index]['RecordDateTime']).toLocal()}'
                    '                  ' +
                '备注：${items[index]['Remark']}'),
          ))),
          itemExtent: 100.0,
          itemCount: items?.length ?? 0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navToAdd(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void navToAdd(BuildContext context) async {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new AddRecordWidget(title: '新增'),
      ),
    );
  }
}
