class Chart {
  String date;
  double money;

  Chart(this.date, this.money);

  factory Chart.fromMap(Map map) {
    String date = map['date'];
    double money = map['money'];
    Chart chart = Chart(
      date,
      money,
    );
    return chart;
  }
}
