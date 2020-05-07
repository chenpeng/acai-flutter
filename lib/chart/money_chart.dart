import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';

class MoneyChartPage extends StatefulWidget {
  MoneyChartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MoneyChartState createState() => MoneyChartState();
}

class MoneyChartState extends State<MoneyChartPage> {
  List yearList = [2020];
  List monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  // "类型"数据源(写死)
  var classificationTypeMap = {1: Text('收入'), 2: Text('支出')};

  // param classificationType
  int classificationType = 2;
  List items = new List();
  int year = DateTime.now().year;
  int month = DateTime.now().month;

  findMoneyRecordChartList() async {
    var dio = await DioUtils.getDio();
    var response = await dio.get('/api/chart', queryParameters: {
      'year': year,
      'month': month,
      'classificationType': classificationType
    });
    var data = response.data;
    if (data['data'] != null && data['data'].length > 0) {
      setState(() {
        items = data['data'];
      });
    } else {
      setState(() {
        items.clear();
      });
    }
  }

  changeClassification(int classificationType) async {
    // 更新UI
    setState(() {
      classificationType = classificationType;
    });
    findMoneyRecordChartList();
  }

  @override
  void initState() {
    print('money_chart initState');
    super.initState();
    findMoneyRecordChartList();
  }

  @override
  Widget build(BuildContext context) {
    print('money_chart build');
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
                    height: 30,
                    child: CupertinoPicker(
                      itemExtent: 30.0,
                      onSelectedItemChanged: (index) {
                        year = yearList[index];
                        findMoneyRecordChartList();
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
                        findMoneyRecordChartList();
                      },
                      children:
                          monthList.map((e) => Text(e.toString())).toList(),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('类型：'),
                Container(
                  height: 60,
                  child: CupertinoSegmentedControl(
                    padding: EdgeInsets.all(10),
                    children: classificationTypeMap,
                    onValueChanged: (value) {
                      classificationType = value;
                      changeClassification(classificationType);
                    },
                    groupValue: classificationType,
                    unselectedColor: CupertinoColors.white,
                    selectedColor: CupertinoColors.activeBlue,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (context, index) => Container(
                  child: Center(
                    child: Text('用途：${items[index]['classification_name']}  ' +
                        '金额：${items[index]['money']}'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
