import 'package:acai_flutter/add/attach_money.dart';
import 'package:acai_flutter/chart/money_chart.dart';
import 'package:acai_flutter/record/money_record.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title = '阿财'}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    print('home build');
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              title: Text("账单"),
              icon: Icon(CupertinoIcons.home),
            ),
            BottomNavigationBarItem(
              title: Text("记账"),
              icon: Icon(CupertinoIcons.add),
            ),
            BottomNavigationBarItem(
              title: Text("报表"),
              icon: Icon(CupertinoIcons.book),
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              switch (index) {
                case 0:
                  return MoneyRecordPage(
                    title: '账单',
                  );
                  break;
                case 1:
                  return AttachMoneyPage(
                    title: '记账',
                    code: 'add',
                  );
                  break;
                case 2:
                  return MoneyChartPage(
                    title: '报表',
                  );
                  break;
              }
              return AttachMoneyPage(
                title: '记账',
              );
            },
          );
        });
  }
}
