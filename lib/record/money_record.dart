import 'package:acai_flutter/add/attach_money.dart';
import 'package:acai_flutter/model/MoneyRecordDto.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    totalPayMoney = 0.0;
    totalIncomeMoney = 0.0;
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
      setState(() {
        items = list;
      });
    } else {
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
      var weekday = DateTime.parse(key).weekday;
      var weekStr = "";
      switch (weekday) {
        case 1:
          weekStr = "星期一";
          break;
        case 2:
          weekStr = "星期二";
          break;
        case 3:
          weekStr = "星期三";
          break;
        case 4:
          weekStr = "星期四";
          break;
        case 5:
          weekStr = "星期五";
          break;
        case 6:
          weekStr = "星期六";
          break;
        case 7:
          weekStr = "星期日";
          break;
      }
      var recordDateStr = DateTime.parse(key).month.toString() +
          "-" +
          DateTime.parse(key).day.toString();
      MoneyRecordDto moneyRecordDto = new MoneyRecordDto(
          recordDateStr, weekStr, payMoney, incomeMoney, value);
      list.add(moneyRecordDto);
    });
    return list;
  }

  // 年份选择器
  showYearPicker(BuildContext context) {
    final picker = CupertinoPicker(
      backgroundColor: CupertinoColors.white,
      scrollController: FixedExtentScrollController(initialItem: 0),
      itemExtent: 30.0,
      onSelectedItemChanged: (index) {
        year = yearList[index];
        findMoneyRecordList();
      },
      children: yearList.map((e) {
        return Text(e.toString());
      }).toList(),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: picker,
        );
      },
    );
  }

  // 月份选择器
  showMonthPicker(BuildContext context) {
    final picker = CupertinoPicker(
      backgroundColor: CupertinoColors.white,
      scrollController: FixedExtentScrollController(initialItem: month - 1),
      itemExtent: 30.0,
      onSelectedItemChanged: (index) {
        month = monthList[index];
        findMoneyRecordList();
      },
      children: monthList.map((e) {
        return Text(e.toString());
      }).toList(),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: picker,
        );
      },
    );
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
        backgroundColor: Colors.lightBlue,
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.lightBlue,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showYearPicker(context);
                              },
                              child: Text('$year年'),
                            ),
                            GestureDetector(
                              onTap: () {
                                showMonthPicker(context);
                              },
                              child: Text('$month月'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('收入'),
                            Text('+${totalIncomeMoney.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('支出'),
                            Text('-${totalPayMoney.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return Container(
                          color: Colors.white,
                          height: 10,
                        );
                      },
                      physics: new NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(10),
                      itemCount: items?.length ?? 0,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: CupertinoColors.systemGrey6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${items[index].recordDateStr}  ${items[index].weekStr}  ',
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  '收入:+${items[index].incomeMoney.toStringAsFixed(2)}  ' +
                                      '支出:-${items[index].payMoney.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                                indent: 40.0,
                                color: CupertinoColors.systemGrey4,
                                height: 10.0),
                            physics: new NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(10),
                            itemCount: items[index].list?.length ?? 0,
                            shrinkWrap: true,
                            itemBuilder: (context, index2) => GestureDetector(
                              onTap: () {
                                navToUpdate(
                                    context, items[index].list[index2]['id']);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${items[index].list[index2]['classification_name']}',
                                  ),
                                  Text(
                                    '${items[index].list[index2]['type'] == 1 ? '+' : '-'}${items[index].list[index2]['money']}',
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
