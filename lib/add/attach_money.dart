import 'dart:async';
import 'dart:io';

import 'package:acai_flutter/home/home.dart';
import 'package:acai_flutter/model/Classification.dart';
import 'package:acai_flutter/model/MoneyRecord.dart';
import 'package:acai_flutter/util/DioUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class AttachMoneyPage extends StatefulWidget {
  final int id;
  final String code;
  final String title;

  AttachMoneyPage({Key key, this.id, this.code, this.title}) : super(key: key);

  @override
  AttachMoneyState createState() => new AttachMoneyState();
}

class AttachMoneyState extends State<AttachMoneyPage> {
  final TextEditingController moneyController = new TextEditingController();
  final TextEditingController remarkController = new TextEditingController();
  final TextEditingController dateController = new TextEditingController();
  final FixedExtentScrollController classificationController =
      new FixedExtentScrollController();
  File image;
  String fileName;
  double money;
  int classificationType;
  List<Classification> classificationList = new List<Classification>();
  Classification classification = new Classification();
  final format = DateFormat("yyyy-MM-dd");
  DateTime dateTxt;
  MoneyRecord moneyRecord;

  loadData() async {
    print("attach_money loadData");
    classificationType = 2;
    var list = await findClassification(classificationType);
    setState(() {
      classificationList = list;
      classification = classificationList.elementAt(0);
    });
    String code = widget.code;
    if (code == 'update') {
      int id = widget.id;
      var mr = await findMoneyRecordById(id);
      var picUrl = mr.picUrl;
      File f = await findImageByUrl(picUrl);
      setState(() {
        image = f;
        moneyRecord = mr;
        fileName = mr.picUrl;
        int code = moneyRecord.classificationCode;
        if (classificationList.length > 0) {
          classification =
              classificationList.firstWhere((value) => value.code == code);
        }
        classificationType = moneyRecord.type;
        moneyController.text = moneyRecord.money.toString();
        dateController.text = moneyRecord.recordDateTime;
        remarkController.text = moneyRecord.remark;
      });
    } else {
      dateTxt = DateTime.now();
      if (classificationList.length > 0) {
        classification = classificationList.elementAt(0);
      }
    }
  }

  @override
  void initState() {
    classificationType = 2;
    super.initState();
    print("attach_money initState");
    loadData();
  }

  saveMoneyRecord() async {
    String moneyTxt = moneyController.text;
    String remarkTxt = remarkController.text;
    if (moneyTxt == '' ||
        remarkTxt == '' ||
        moneyTxt == '' ||
        fileName == '' ||
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
      Navigator.of(context).pushNamed("home", arguments: "hi");
      showToast(msg);
    } else {
      showToast(msg);
    }
  }

  Future openCamera() async {
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    upLoadImage(file);
    setState(() {
      image = file;
    });
  }

  Future openGallery() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    upLoadImage(file);
    setState(() {
      image = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("attach_money build");
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Text('类型：'),
                CupertinoSegmentedControl(
                  children: {1: Text('收入'), 2: Text('支出')},
                  onValueChanged: (value) {
                    setState(() {
                      classificationType = value;
                    });
                    changeClassification(classificationType);
                  },
                  groupValue: classificationType,
                  unselectedColor: CupertinoColors.white,
                  selectedColor: CupertinoColors.activeBlue,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text("用途："),
                Expanded(
                  child: Container(
                    height: 30,
                    child: CupertinoPicker(
                      scrollController: classificationController,
                      itemExtent: 30.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          classification = classificationList[index];
                        });
                      },
                      children: classificationList.map((Classification map) {
                        return Text(map.name);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text("时间："),
                Expanded(
                  child: Container(
                    height: 30,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      onDateTimeChanged: (value) {
                        setState(() {
                          dateTxt = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text("金额："),
                Expanded(
                  child: CupertinoTextField(
                    controller: moneyController,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text("备注："),
                Expanded(
                  child: CupertinoTextField(
                    controller: remarkController,
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
                  child: new CupertinoButton(
                    child: Icon(
                      CupertinoIcons.photo_camera,
                      semanticLabel: '拍照',
                    ),
                    onPressed: openCamera,
                  ),
                ),
                Expanded(
                  child: new CupertinoButton(
                    child: Icon(
                      CupertinoIcons.collections,
                      semanticLabel: '相册',
                    ),
                    onPressed: openGallery,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: new CupertinoButton(
                    child: Text('确定'),
                    onPressed: saveMoneyRecord,
                  ),
                ),
                Expanded(
                  child: new CupertinoButton(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => new MyHomePage(title: '阿财'),
                      ));
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: new CupertinoButton(
                    child: Text('删除'),
                    color: CupertinoColors.destructiveRed,
                    onPressed: alertDeleteDialog,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  upLoadImage(File image) async {
    var url = '/api/moneyRecord/upload';
    Dio dio = await DioUtils.getDio();
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path,
          filename: image.path.split("/").last)
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

  Future<void> changeClassification(int classificationType) async {
    var list = await findClassification(classificationType);
    setState(() {
      classificationList = list;
      if (widget.code == 'add') {
        classification = list.elementAt(0);
      } else if (widget.code == 'update') {
        classification = classificationList.firstWhere(
            (value) => value.code == moneyRecord.classificationCode);
      }
    });
  }

  Future<void> alertDeleteDialog() async {
    return CupertinoAlertDialog(
      title: Text('确认删除吗？'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('类别：' + moneyRecord.classificationName),
            Text('金额：' + moneyRecord.money.toString()),
            Text('备注：' + moneyRecord.remark),
            Text('时间：' + moneyRecord.recordDateTime),
          ],
        ),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text('删除'),
          onPressed: deleteMoneyRecord,
        ),
      ],
    );
  }

  Future<void> deleteMoneyRecord() async {
    var dio = await DioUtils.getDio();
    var url = "/api/moneyRecord";
    var response = await dio.delete(url + "/" + widget.id.toString());
    var data = response.data;
    var code = data['code'];
    if (code == 0) {
      showToast("删除成功");
      Navigator.push(
        context,
        new CupertinoPageRoute(
          builder: (context) => new MyHomePage(),
        ),
      );
    } else {
      showToast("删除失败");
    }
  }
}

Future<List<Classification>> findClassification(classificationType) async {
  var url = '/api/classification';
  var dio = await DioUtils.getDio();
  var response =
      await dio.get(url, queryParameters: {"type": classificationType});
  var classificationList = new List<Classification>();
  var data = response.data;
  data["data"].forEach((f) {
    Classification c = Classification.fromJson(f);
    classificationList.add(c);
  });
  return classificationList;
}

Future<MoneyRecord> findMoneyRecordById(int id) async {
  var dio = await DioUtils.getDio();
  var response = await dio.get('/api/moneyRecord/' + id.toString());
  var data = response.data;
  var code = data['code'];
  var moneyRecord;
  if (code == 0) {
    moneyRecord = MoneyRecord.fromMap(data['data']);
  }
  return moneyRecord;
}

Future<File> findImageByUrl(String picUrl) async {
  if (picUrl == "") {
    return null;
  }
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  var dio = await DioUtils.getDio();
  await dio.download('/api/moneyRecord/download', '$tempPath/$picUrl',
      queryParameters: {"picUrl": picUrl});
  File file = new File('$tempPath/$picUrl');
  return file;
}
