import 'package:acai_flutter/add/add.dart';
import 'package:acai_flutter/chart/chart.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title = '阿财'}) : super(key: key);

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
      items = new List();
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
    var response = await dio.get('/api/moneyRecord',
        queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize});
    var data = response.data;
    if (data['data'].length > 0) {
      setState(() {
        if (pageIndex == 1) {
          items = data['data'];
        } else {
          items.addAll(data['data']);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    findMoneyRecordList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
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
            onTap: () {
              int id = items[index]['id'];
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) =>
                      new AddRecordWidget(code: 'update', title: '修改', id: id),
                ),
              );
            },
            title: new Text('金额：${items[index]['money']}'),
            subtitle: new Text('用途：${items[index]['classification_name']}' +
                '             ' +
                '时间：${DateFormat("yyyy-MM-dd").parse(items[index]['record_date_time'].toString())}'
                    '                  ' +
                '备注：${items[index]['remark']}'),
          ))),
          itemExtent: 100.0,
          itemCount: items?.length ?? 0,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new RaisedButton(
                child: Text('报表'),
                elevation: 1,
                highlightElevation: 1,
                onPressed: () {
                  navToChart(context);
                },
              ),
              new RaisedButton(
                child: Text('新增'),
                elevation: 1,
                highlightElevation: 1,
                onPressed: () {
                  navToAdd(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navToAdd(BuildContext context) async {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new AddRecordWidget(code: 'add', title: '新增'),
      ),
    ).then((data) {
      if (mounted) {
        onRefresh();
      }
    });
  }

  void navToChart(BuildContext context) async {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new ChartPage(title: '报表'),
      ),
    ).then((data) {
      if (mounted) {
        onRefresh();
      }
    });
  }
}
