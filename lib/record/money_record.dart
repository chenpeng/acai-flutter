import 'package:acai_flutter/add/attach_money.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
      setState(() {
        items = data['data'];
      });
    }
  }

  @override
  void initState() {
    print('home initState');
    super.initState();
    findMoneyRecordList();
  }

  @override
  Widget build(BuildContext context) {
    print('home build');
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 30,
                    width: 30,
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
                  child: Text('收入：'),
                ),
                Expanded(
                  child: Text('支出：'),
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
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        navToUpdate(context, items[index]['id']);
                      },
                      child: Text('时间：${items[index]['record_date_time']}  ' +
                          '金额：${items[index]['money']}  ' +
                          '用途：${items[index]['classification_name']}  ' +
                          '备注：${items[index]['remark']}'),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
