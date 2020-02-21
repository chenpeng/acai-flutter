class Classification {
  int code;
  String name;

  Classification({this.code, this.name});

  factory Classification.fromJson(Map map) {
    return new Classification(
      code: map['code'],
      name: map['name'],
    );
  }
}
