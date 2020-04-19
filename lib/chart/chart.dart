import 'package:acai_flutter/util/DioUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChartPage extends StatefulWidget {
  ChartPage({Key key, this.title = '阿财'}) : super(key: key);

  final String title;

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  List items = new List();
  int year = DateTime.now().year;
  int month = DateTime.now().month;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body: Column(
//          mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            hint: Text('年'),
            value: year,
            onChanged: (int newValue) {
              setState(() {
                year = newValue;
              });
              findMoneyRecordChartList();
            },
            items: [2020].map((int y) {
              return DropdownMenuItem<int>(
                value: y,
                child: Text(y.toString()),
              );
            }).toList(),
          ),
          DropdownButton<int>(
            hint: Text('月'),
            value: month,
            onChanged: (int newValue) {
              setState(() {
                month = newValue;
              });
              findMoneyRecordChartList();
            },
            items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map((int m) {
              return DropdownMenuItem<int>(
                value: m,
                child: Text(m.toString()),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => Card(
                  child: Center(
                      child: new ListTile(
                title: new Text('日期：${items[index]['date']}'),
                subtitle: new Text('金额：${items[index]['money']}'),
              ))),
              itemCount: items?.length ?? 0,
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
