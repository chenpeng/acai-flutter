import 'dart:io';

import 'package:acai_flutter/model/Classification.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';

class AddRecordWidget extends StatefulWidget {
  final String title;

  AddRecordWidget({Key key, this.title}) : super(key: key);

  @override
  AddRecordWidgetState createState() => new AddRecordWidgetState();
}

class AddRecordWidgetState extends State<AddRecordWidget> {
  final TextEditingController moneyController = new TextEditingController();
  final TextEditingController remarkController = new TextEditingController();
  File image;
  String fileName;
  double money;
  int classificationType;
  List<Classification> classificationList = new List<Classification>();
  Classification classification;

  @override
  void initState() {
    classificationType = 2;
    findClassification();
    super.initState();
  }

  findClassification() async {
    var url = '/api/classification';
    var dio = await DioUtils.getDio();
    try {
      var response =
          await dio.get(url, queryParameters: {"type": classificationType});
      if (response.statusCode == HttpStatus.ok) {
        classificationList.clear();
        var data = response.data;
        data["Data"].forEach((f) {
          Classification c = new Classification();
          c.Code = f["Code"];
          c.Name = f["Name"];
          classificationList.add(c);
        });
        if (classificationList != null && classificationList.length > 0) {
          classification = classificationList.elementAt(0);
        }
        setState(() {
          classificationList = classificationList;
          classification = classification;
        });
      } else {
        showToast('查询失败:${response.statusCode}');
      }
    } catch (e) {
      showToast('查询失败');
    }
  }

  saveMoneyRecord() async {
    String moneyTxt = moneyController.text;
    String remarkTxt = remarkController.text;

    money = double.parse(moneyTxt);

    var url = '/api/moneyRecord';
    var dio = await DioUtils.getDio();
    try {
      var response = await dio.post(url, data: {
        'ClassificationCode': classification.Code,
        'ClassificationName': classification.Name,
        'Money': money,
        'Type': classificationType,
        'Remark': remarkTxt,
        'PicUrl': fileName,
      });
      if (response.statusCode == HttpStatus.ok) {
        Navigator.of(context).pop();
        showToast('添加成功');
      } else {
        showToast('添加失败:${response.statusCode}');
      }
    } catch (exception) {
      showToast('添加失败:$exception');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                      child: Text(map.Name),
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
                    Navigator.pop(context);
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
        fileName = data['Data'];
        showToast('上传成功');
      } else {
        showToast('上传失败:Http status ${response.statusCode}');
      }
    } catch (e) {
      showToast('上传失败');
    }
  }
}
