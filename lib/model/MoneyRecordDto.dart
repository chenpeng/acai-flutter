class MoneyRecordDto {
  // 日期
  String recordDateStr;
  // 星期
  String weekStr;
  // 支出
  double payMoney;
  // 收入
  double incomeMoney;
  // 子数据
  List list;

  MoneyRecordDto(this.recordDateStr, this.weekStr,this.payMoney, this.incomeMoney, this.list);

  @override
  String toString() {
    return 'MoneyRecordDto{recordDateStr: $recordDateStr, weekStr: $weekStr, payMoney: $payMoney, incomeMoney: $incomeMoney, list: $list}';
  }

//  factory MoneyRecordDto.fromMap(Map map) {
//    MoneyRecordDto moneyRecord = MoneyRecordDto(
//      map['record_date_time'],
//      double.parse(map['money'].toString()),
//      double.parse(map['money'].toString()),
//    );
//    return moneyRecord;
//  }
}
