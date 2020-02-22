class MoneyRecord {
  int id;
  int classificationCode;
  String classificationName;
  String recordDateTime;
  double money;
  int type;
  String remark;
  String picUrl;

  MoneyRecord(this.id, this.classificationCode, this.classificationName, this.recordDateTime, this.money,
      this.type, this.remark, this.picUrl);

  factory MoneyRecord.fromMap(Map map) {
    MoneyRecord moneyRecord = MoneyRecord(
      map['id'],
      map['classification_code'],
      map['classification_name'],
      map['record_date_time'],
      double.parse(map['money'].toString()),
      map['type'],
      map['remark'],
      map['pic_url'],
    );
    return moneyRecord;
  }
}
