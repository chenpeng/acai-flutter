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
  // "类型"数据源(写死)
  var classificationTypeMap = {1: Text('收入'), 2: Text('支出')};

  // "分类"数据源（接口获取）
  List<Classification> classificationList = new List<Classification>();

  // "记录"数据源（接口获取）
  MoneyRecord moneyRecord;

  // param classificationType
  int classificationType = 2;

  // param classification（新增时，取classificationList第一个。更新时，从接口获取对应的。）
  Classification classification = new Classification();

  // param recordDateTime
  DateTime recordDateTime = DateTime.now();

  // param money
  double money;

  // param remark
  String remark;

  // param fileName
  String fileName;
  File image;

  // 控制是否显示删除按钮
  bool hideDeleteBtn = true;

  loadData() async {
    print("attach_money loadData");
    var list = await findClassification(classificationType);
//    setState(() {
    classificationList = list;
//      classification = classificationList.elementAt(0);
//    });
    String code = widget.code;
    if (code == 'update') {
      int id = widget.id;
      var mr = await findMoneyRecordById(id);
      var picUrl = mr.picUrl;
      image = await findImageByUrl(picUrl);
//      setState(() {
      moneyRecord = mr;
      fileName = mr.picUrl;
      int code = moneyRecord.classificationCode;
      if (classificationList.length > 0) {
        classification =
            classificationList.firstWhere((value) => value.code == code);
      }
      classificationType = moneyRecord.type;
      money = moneyRecord.money;
      recordDateTime = DateTime.parse(moneyRecord.recordDateTime);
      remark = moneyRecord.remark;
//      });
    } else {
      recordDateTime = DateTime.now();
      if (classificationList.length > 0) {
        classification = classificationList.elementAt(0);
      }
    }
    // 更新UI
    setState(() {

    });
  }

  @override
  void initState() {
//    classificationType = 2;
    super.initState();
    print("attach_money initState");
    loadData();
    if (widget.code == 'update') {
      hideDeleteBtn = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("attach_money build");
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Text('类型：'),
                Container(
                  height: 60,
                  child: CupertinoSegmentedControl(
                    padding: EdgeInsets.all(10),
                    children: classificationTypeMap,
                    onValueChanged: (value) {
                      classificationType = value;
                      changeClassification(classificationType);
                    },
                    groupValue: classificationType,
                    unselectedColor: CupertinoColors.white,
                    selectedColor: CupertinoColors.activeBlue,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text("用途："),
                Expanded(
                  child: Container(
                    height: 60,
                    child: CupertinoButton(
                      onPressed: () {
                        showClassificationPicker(context);
                      },
                      child: Text(classification?.name == null ? '':classification.name),
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
                    height: 60,
                    child: CupertinoButton(
                      onPressed: () {
                        showRecordDatePicker(context);
                      },
                      child: Text(recordDateTime.year.toString() +
                          '-' +
                          recordDateTime.month.toString() +
                          '-' +
                          recordDateTime.day.toString()),
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
                    padding: EdgeInsets.all(10.0),
                    controller: TextEditingController(text: money?.toString()),
                    onChanged: (value) {
                      money = double.parse(value);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text("备注："),
                Expanded(
                  child: CupertinoTextField(
                    padding: EdgeInsets.all(10.0),
                    controller: TextEditingController(text: remark?.toString()),
                    onChanged: (value) {
                      remark = value;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: image == null
                        ? Text('木有照片')
                        : Image.file(image, width: 100, height: 100),
                  ),
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
                    child: Text(
                      '确定',
                    ),
                    onPressed: saveMoneyRecord,
                  ),
                ),
                Expanded(
                  child: new CupertinoButton(
                    child: Text(
                      '取消',
                      style: TextStyle(color: CupertinoColors.systemRed),
                    ),
                    onPressed: () {
                      Navigator.of(context,rootNavigator: true,).push(CupertinoPageRoute(
                        builder: (context) => new HomePage(title: '阿财'),
                      ));
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Offstage(
                    offstage: hideDeleteBtn,
                    child: CupertinoButton(
                      child: Text('删除'),
                      color: CupertinoColors.systemRed,
                      onPressed: alertDeleteDialog,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  saveMoneyRecord() async {
    if (money == 0.0 ||
        remark == '' ||
        fileName == '' ||
        recordDateTime == null) {
      showToast("请补全信息");
      return;
    }

    var url = '/api/moneyRecord';
    var dio = await DioUtils.getDio();
    var param = {
      'classification_code': classification.code,
      'classification_name': classification.name,
      'record_date_time': recordDateTime.toString(),
      'money': money,
      'type': classificationType,
      'remark': remark,
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
      Navigator.of(context,rootNavigator: true,).pushNamed("home", arguments: "hi");
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
    print('classificationType:' + classificationType.toString());
    // 根据"类型"，获取数据。
    var list = await findClassification(classificationType);
    // 更新UI
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
          builder: (context) => new HomePage(),
        ),
      );
    } else {
      showToast("删除失败");
    }
  }

  showClassificationPicker(BuildContext context) {
    final picker = CupertinoPicker(
      backgroundColor: CupertinoColors.white,
      itemExtent: 35.0,
      onSelectedItemChanged: (index) {
        classification = classificationList[index];
      },
      children: classificationList.map((Classification map) {
        return Text(map.name);
      }).toList(),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: picker,
        );
      },
    );
  }

  // 时间选择器
  showRecordDatePicker(BuildContext context) {
    final picker = CupertinoDatePicker(
      backgroundColor: CupertinoColors.white,
      mode: CupertinoDatePickerMode.date,
      use24hFormat: true,
      onDateTimeChanged: (value) {
        recordDateTime = value;
      },
    );
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: picker,
        );
      },
    );
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
