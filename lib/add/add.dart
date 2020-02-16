import 'dart:io';

import 'package:acai_flutter/model/Classification.dart';
import 'package:acai_flutter/model/MoneyRecord.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class AddRecordWidget extends StatefulWidget {
  final String code;
  final String title;
  final int id;

  AddRecordWidget({Key key, this.title, this.code, this.id}) : super(key: key);

  @override
  AddRecordWidgetState createState() => new AddRecordWidgetState();
}

class AddRecordWidgetState extends State<AddRecordWidget> {
  final TextEditingController moneyController = new TextEditingController();
  final TextEditingController remarkController = new TextEditingController();
  final TextEditingController dateController = new TextEditingController();
  File image;
  String fileName;
  double money;
  int classificationType;
  List<Classification> classificationList = new List<Classification>();
  Classification classification;
  final format = DateFormat("yyyy-MM-dd");
  DateTime dateTxt;
  MoneyRecord moneyRecord;

  @override
  void initState() {
    classificationType = 2;
    findClassification();
    super.initState();
  }

  findClassification() async {
    var url = '/api/classification';
    var dio = await DioUtils.getDio();
    var response =
        await dio.get(url, queryParameters: {"type": classificationType});
    classificationList.clear();
    var data = response.data;
    data["data"].forEach((f) {
      Classification c = new Classification(f["code"], f["name"]);
      classificationList.add(c);
    });
    setState(() {
      classificationList = classificationList;
      String code = widget.code;
//      if (code == 'add') {
      if (classificationList != null && classificationList.length > 0) {
        classification = classificationList.elementAt(0);
      }
//      }
    });
  }

  saveMoneyRecord() async {
    String moneyTxt = moneyController.text;
    String remarkTxt = remarkController.text;
    if (moneyTxt == '' ||
        remarkTxt == '' ||
        moneyTxt == '' ||
        dateTxt == null) {
      showToast("请补全信息");
      return;
    }
    money = double.parse(moneyTxt);

    var url = '/api/moneyRecord';
    var dio = await DioUtils.getDio();
    var param = {
      'classification_code': classification.code,
      'classification_name': classification.name,
      'record_date_time': dateTxt.toString(),
      'money': money,
      'type': classificationType,
      'remark': remarkTxt,
      'pic_url': fileName,
    };
    var response;
    if (widget.code == 'add') {
      response = await dio.post(url, data: param);
    } else if (widget.code == 'update') {
      response = await dio.put(url + "/" + widget.id.toString(), data: param);
    }
    var data = response.data;
    var code = data['code'];
    var msg = data['message'];
    if (code == 0) {
      Navigator.of(context).pop();
      showToast(msg);
    } else {
      showToast(msg);
    }
  }

  Future openCamera() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    upLoadImage(file);
    setState(() {
      image = file;
    });
  }

  findMoneyRecordById(int id) async {
    var dio = await DioUtils.getDio();
    var response = await dio.get('/api/moneyRecord/' + id.toString());
    var data = response.data;
    var code = data['code'];
    if (code == 0) {
      setState(() {
        moneyRecord = MoneyRecord.fromMap(data['data']);
        classificationType = moneyRecord.type;
        classification = new Classification(
            moneyRecord.classificationCode, moneyRecord.classificationName);
        moneyController.text = moneyRecord.money.toString();
        dateController.text = moneyRecord.recordDateTime;
        remarkController.text = moneyRecord.remark;
      });
      findImageByUrl(moneyRecord.picUrl);
    }
  }

  findImageByUrl(String picUrl) async {
    if (picUrl == "") {
      return;
    }
    var dio = await DioUtils.getDio();
    var response = await dio
        .get('/api/moneyRecord/download', queryParameters: {"picUrl": picUrl});
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath/$picUrl');
    file
        .writeAsBytes(Uint8List.fromList(response.data.codeUnits))
        .then((onValue) {
      setState(() {
        image = file;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String code = widget.code;
    if (code == 'update') {
      int id = widget.id;
      findMoneyRecordById(id);
    }
    // 获取图片
//    findImageByUrl(moneyRecord.picUrl);
    print("build:");
    print(classification.name);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text("类型："),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text("支出"),
                        Radio(
                          value: 2,
                          groupValue: classificationType,
                          activeColor: Colors.blue,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (value) {
                            setState(() {
                              classificationType = value;
                            });
                            findClassification();
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text("收入"),
                        Radio(
                          value: 1,
                          groupValue: classificationType,
                          activeColor: Colors.blue,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (value) {
                            setState(() {
                              classificationType = value;
                            });
                            findClassification();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text("用途："),
              Expanded(
                child: DropdownButton<Classification>(
                  hint: Text('选一个吧'),
                  value: classification,
                  onChanged: (Classification newValue) {
                    setState(() {
                      classification = newValue;
                    });
                  },
                  items: classificationList.map((Classification map) {
                    return DropdownMenuItem<Classification>(
                      value: map,
                      child: Text(map.name),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: moneyController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '金额',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text("时间："),
              Expanded(
                child: DateTimeField(
                  controller: dateController,
                  onChanged: (value) {
                    setState(() {
                      dateTxt = value;
                    });
                  },
                  format: format,
                  onShowPicker: (context, currentValue) {
                    currentValue = dateTxt;
                    return showDatePicker(
                        context: context,
                        locale: Locale('zh'),
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: remarkController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '备注',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: image == null
                    ? Text('木有照片')
                    : Image.file(image, width: 100, height: 100),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: new RaisedButton(
                  child: Text('上传图片'),
                  elevation: 1,
                  highlightElevation: 1,
                  onPressed: openCamera,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: new RaisedButton(
                  child: Text('确定'),
                  elevation: 1,
                  highlightElevation: 1,
                  onPressed: saveMoneyRecord,
                ),
              ),
              Expanded(
                child: new RaisedButton(
                  child: Text('取消'),
                  elevation: 2,
                  highlightElevation: 2,
                  onPressed: () {
                    Navigator.pop(context, '');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  upLoadImage(File image) async {
    var url = '/api/moneyRecord/upload';
    Dio dio = await DioUtils.getDio();
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path, filename: "xxx.png")
    });
    try {
      var response = await dio.post(url, data: formData);
      if (response.statusCode == HttpStatus.ok) {
        var data = response.data;
        setState(() {
          fileName = data['data'];
        });
        showToast('上传成功');
      } else {
        showToast('上传失败:Http status ${response.statusCode}');
      }
    } catch (e) {
      showToast('上传失败');
    }
  }
}
