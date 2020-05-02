import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';

class MoneyChartPage extends StatefulWidget {
  MoneyChartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MoneyChartState createState() => MoneyChartState();
}

class MoneyChartState extends State<MoneyChartPage> {
  List items = new List();
  int year = DateTime.now().year;
  int month = DateTime.now().month - 1;

  findMoneyRecordChartList() async {
    var dio = await DioUtils.getDio();
    var response = await dio
        .get('/api/chart', queryParameters: {'year': year, 'month': month});
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

  @override
  void initState() {
    super.initState();
    findMoneyRecordChartList();
  }

  @override
  Widget build(BuildContext context) {
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
                      onSelectedItemChanged: (index) {},
                      children: [2020].map((e) => Text(e.toString())).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 30,
                    child: CupertinoPicker(
                      itemExtent: 30.0,
                      onSelectedItemChanged: (index) {},
                      children: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
                          .map((e) => Text(e.toString()))
                          .toList(),
                    ),
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
