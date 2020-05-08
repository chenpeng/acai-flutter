class MoneyRecordDto {
  int id;
  int classificationCode;
  String classificationName;
  String recordDateTime;
  double money;
  int type;
  String remark;
  String picUrl;

  MoneyRecordDto(this.id, this.classificationCode, this.classificationName, this.recordDateTime, this.money,
      this.type, this.remark, this.picUrl);

  factory MoneyRecordDto.fromMap(Map map) {
    MoneyRecordDto moneyRecord = MoneyRecordDto(
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
