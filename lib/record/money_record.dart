import 'package:acai_flutter/add/attach_money.dart';
import 'package:acai_flutter/model/MoneyRecordDto.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import "package:collection/collection.dart";

class MoneyRecordPage extends StatefulWidget {
  MoneyRecordPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MoneyRecordState createState() => MoneyRecordState();
}

class MoneyRecordState extends State<MoneyRecordPage> {
  List yearList = [2020];
  List monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  List items = new List();
  double totalPayMoney = 0.0;
  double totalIncomeMoney = 0.0;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  int year = DateTime.now().year;
  int month = DateTime.now().month;

  void onRefresh() async {
    setState(() {
      items = new List();
    });
    await findMoneyRecordList();
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    await findMoneyRecordList();
    refreshController.loadComplete();
  }

  findMoneyRecordList() async {
    var dio = await DioUtils.getDio();
    var response = await dio.get('/api/moneyRecord',
        queryParameters: {'year': year, 'month': month});
    var data = response.data;
    if (data['data'] != null && data['data'].length > 0) {
      List list = handleMoneyRecordList(data['data']);
      list.forEach((element) {
        totalPayMoney += element.payMoney;
        totalIncomeMoney += element.incomeMoney;
      });
      print(list);
      setState(() {
        items = list;
      });
    }else{
      setState(() {
        items = new List();
      });
    }
  }

  // 处理一下返回的数据，构造一个二级的结构。
  List handleMoneyRecordList(data) {
    List list = new List();
    groupBy(data, (obj) => obj['record_date_time']).forEach((key, value) {
      double payMoney = 0;
      double incomeMoney = 0;
      value.forEach((element) {
        if (element['type'] == 1) {
          incomeMoney += element['money'];
        } else if (element['type'] == 2) {
          payMoney += element['money'];
        }
      });
      MoneyRecordDto moneyRecordDto =
          new MoneyRecordDto(key, payMoney, incomeMoney, value);
      list.add(moneyRecordDto);
    });
    return list;
  }

  @override
  void initState() {
    print('money_record initState');
    super.initState();
    findMoneyRecordList();
  }

  @override
  Widget build(BuildContext context) {
    print('money_record build');
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      height: 30,
                      child: CupertinoPicker(
                        scrollController:
                            FixedExtentScrollController(initialItem: 0),
                        itemExtent: 30.0,
                        onSelectedItemChanged: (index) {
                          year = yearList[index];
                          findMoneyRecordList();
                        },
                        children:
                            yearList.map((e) => Text(e.toString())).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 30,
                      child: CupertinoPicker(
                        scrollController:
                            FixedExtentScrollController(initialItem: month - 1),
                        itemExtent: 30.0,
                        onSelectedItemChanged: (index) {
                          month = monthList[index];
                          findMoneyRecordList();
                        },
                        children:
                            monthList.map((e) => Text(e.toString())).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text('收入：+$totalIncomeMoney'),
                  ),
                  Expanded(
                    child: Text('支出：-$totalPayMoney'),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: items?.length ?? 0,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '时间：${items[index].recordDateStr}  ' +
                                '收入：+${items[index].incomeMoney}  ' +
                                '支出：-${items[index].payMoney}',
                            style: TextStyle(fontSize: 15),
                          ),
                          ListView.builder(
                            physics: new NeverScrollableScrollPhysics(),
                            itemCount: items[index].list?.length ?? 0,
                            shrinkWrap: true,
                            itemBuilder: (context, index2) => GestureDetector(
                              onTap: () {
                                navToUpdate(
                                    context, items[index].list[index2]['id']);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '${items[index].list[index2]['classification_name']}',
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    '${items[index].list[index2]['type'] == 1 ? '+' : '-'}${items[index].list[index2]['money']}',
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void navToUpdate(BuildContext context, int id) async {
  Navigator.push(
    context,
    new CupertinoPageRoute(
      builder: (context) => new AttachMoneyPage(
        code: 'update',
        title: '修改',
        id: id,
      ),
    ),
  );
}
