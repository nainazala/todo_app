import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';

import '../Model/ModelClass.dart';
import '../Model/ModelTODO.dart';
import '../Utils/DatabaseHelper.dart';
import '../Utils/GlobalColorCode.dart';
import '../Utils/GlobalConstant.dart';
import '../Utils/GlobalTextStyle.dart';
import 'TodoUpdatePage.dart';

class TodoHomePage extends StatefulWidget {
  @override
  State<TodoHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TodoHomePage> {
  List<DropdownMenuItem<String>>? _dropdownMenuItems;
  String? _selectedCaption;
  List<String> statusList = ['TODO', 'In-Progress', 'Done'];
  List<ModelTODO> fetchedList = [];
  TextEditingController textEditTitle = TextEditingController();
  TextEditingController textEditDescription = TextEditingController();
  TextEditingController textEditTime = TextEditingController();
  final GlobalKey<ScaffoldState> _modelScaffoldKey = GlobalKey<ScaffoldState>();
  bool isloading = true;

  Timer? _timer;
  int _start = 10;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _query();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Todo App'),
      ),
      body: isloading == true
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    itemCount: fetchedList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        shadowColor: Colors.black,
                        color: COLOR_CODE_WHITE,
                        surfaceTintColor: COLOR_CODE_WHITE,
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    fetchedList[index].title.toString(),
                                    style: TextStyle_PURPLE_W400_18,
                                  ),
                                  Expanded(child: Container()),
                                  InkWell(
                                      onTap: () {
                                        ModelTODO model = fetchedList[index];
                                        showBottomSheetUpdateTask(model);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.edit,
                                          color: COLOR_CODE_RED,
                                          size: 25,
                                        ),
                                      )),
                                  InkWell(
                                      onTap: () {
                                        _Deletequery(fetchedList[index].id);

                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.cancel,
                                          color: COLOR_CODE_RED,
                                          size: 25,
                                        ),
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fetchedList[index].status.toString(),
                                        style: TextStyle_BLACK_W400_14,
                                      ),
                                      Text(
                                        fetchedList[index]
                                            .description
                                            .toString(),
                                        style: TextStyle_BLACK_W400_14,
                                      ),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Text(
                                          fetchedList[index].timer.toString()+" (hh:mm)",
                                          style: TextStyle_PURPLE_W400_18,
                                        ),
                                      ),
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: fetchedList[index].isplay == false
                                              ? Icon(
                                                  Icons.play_arrow,
                                                  color: COLOR_CODE_PURPLE,
                                                  size: 30,
                                                )
                                              : Icon(
                                                  Icons.pause,
                                                  color: COLOR_CODE_PURPLE,
                                                  size: 30,
                                                ),
                                        ),
                                        onTap: () {
                                          fetchedList[index].isplay == false
                                              ? fetchedList[index].isplay = true
                                              : fetchedList[index].isplay = false;
                                          setState(() {});
                                          if (!fetchedList[index].isplay) {
                                            _start = 60;
                                            startTimer(index);
                                          } else {
                                            print(fetchedList[index].timer );
                                            _timer!.cancel();
                                            ModelClass modelClass = ModelClass(
                                                title: fetchedList[index].title,
                                                description: fetchedList[index].description,
                                                timer: fetchedList[index].timer,
                                                status: fetchedList[index].status);
                                            ModelTODO model = fetchedList[index];
                                            _Updatequery(modelClass, model);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          showBottomSheetAddTask();
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: COLOR_CODE_PURPLE),
                          child:
                              Text("Add TODO", style: TextStyle_BLACK_W500_16),
                        ),
                      ),
                    ))
              ],
            ),
    );
  }

  void startTimer(int index) {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          List<String> list = fetchedList[index].timer.toString().split(":");
          fetchedList[index].timer =
              list[0] + ":" + (int.parse(list[1]) + 1).toString();
          setState(() {
              _start = 60;
          });
        } else {
          print(_start);

          setState(() {
            _start--;

          });
        }
      },
    );
  }

  _query() async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    // get all rows
    List<Map> result = await db!.query(DatabaseHelper.table);
    // print the results
    result.forEach((row) => print(row));
    fetchedList = [];
    fetchedList = result.map((f) => ModelTODO.fromJson(f)).toList();
    isloading = false;
    setState(() {});
  }

  _Deletequery(int? id) async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    databaseHelper.delete(id!);
    _query();
  }

  _Insertquery(ModelClass modelClass) async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    databaseHelper.insert(modelClass);
    // get all rows
    List<Map> result = await db!.query(DatabaseHelper.table);
    // print the results
    result.forEach((row) => print(row));
    isloading = false;
    setState(() {
      fetchedList = result.map((f) => ModelTODO.fromJson(f)).toList();
    });
  }

  void showBottomSheetAddTask() {
    textEditTitle.text = "";
    textEditDescription.text = "";
    textEditTime.text = "0:0";
    _dropdownMenuItems = buildDropdownMenuItems(statusList);
    _selectedCaption = _dropdownMenuItems![0].value;
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(FIXED_SIZE_10))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
            return AnimatedPadding(
                padding: MediaQuery.of(context1).viewInsets,
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                child: Container(
                    padding: const EdgeInsets.only(
                      left: FIXED_SIZE_20,
                      right: FIXED_SIZE_20,
                      top: FIXED_SIZE_20,
                      bottom: FIXED_SIZE_10,
                    ),
                    margin: const EdgeInsets.only(bottom: FIXED_SIZE_10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(strTitle, style: TextStyle_BLACK_W500_16),
                          TextField(
                            controller: textEditTitle,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              filled: true,
                              fillColor: COLOR_CODE_WHITE,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: COLOR_CODE_PURPLE, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(strDescription, style: TextStyle_BLACK_W500_16),
                          TextField(
                            controller: textEditDescription,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              filled: true,
                              fillColor: COLOR_CODE_WHITE,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: COLOR_CODE_PURPLE, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(strStatus, style: TextStyle_BLACK_W500_16),
                          Container(
                            height: FIXED_SIZE_50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(FIXED_SIZE_8),
                              color: COLOR_CODE_WHITE,
                              border: Border.all(
                                  width: FIXED_SIZE_1,
                                  color: COLOR_CODE_BLACK,
                                  style: BorderStyle.solid),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                items: _dropdownMenuItems,
                                value: _selectedCaption,
                                onChanged: (value) {
                                  setState1(() {
                                    _selectedCaption = value;
                                  });
                                },
                                buttonHeight: FIXED_SIZE_40,
                                itemHeight: FIXED_SIZE_50,
                                isExpanded: true,
                                itemPadding: const EdgeInsets.only(
                                    left: FIXED_SIZE_7, right: FIXED_SIZE_5),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                                dropdownDecoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(FIXED_SIZE_14),
                                  color: COLOR_CODE_WHITE,
                                ),
                                buttonPadding: const EdgeInsets.only(
                                    left: FIXED_SIZE_7, right: FIXED_SIZE_5),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Timer", style: TextStyle_BLACK_W500_16),
                          InkWell(
                            onTap: () async {
                              List<String> list = textEditTime.text.split(":");
                              TimeOfDay initialTime = TimeOfDay(
                                  hour: int.parse(list[0]),
                                  minute: int.parse(list[1]));

                              // TimeOfDay initialTime = TimeOfDay.now();
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context1,
                                initialTime: initialTime,
                              );
                              textEditTime.text = pickedTime!.hour.toString() +
                                  ":" +
                                  pickedTime.minute.toString();
                            },
                            child: TextField(
                              controller: textEditTime,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                filled: true,
                                enabled: false,
                                prefixIcon: Icon(Icons.timer),
                                fillColor: COLOR_CODE_WHITE,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: COLOR_CODE_PURPLE, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  String validation = '';
                                  textEditTitle.text.isEmpty
                                      ? validation = 'Please enter Title'
                                      : textEditDescription.text.isEmpty
                                          ? validation =
                                              'Please enter Description'
                                          : '';
                                  if (validation == "") {
                                    ModelClass modelClass = ModelClass(
                                        title: textEditTitle.text,
                                        description: textEditDescription.text,
                                        timer: textEditTime.text,
                                        status: _selectedCaption);
                                    _Insertquery(modelClass);
                                    Navigator.of(context).pop(true);
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: validation,
                                      backgroundColor: COLOR_CODE_PURPLE,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width / 2 - 25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: COLOR_CODE_PURPLE),
                                  child: Text("Save",
                                      style: TextStyle_BLACK_W500_16),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width / 2 - 25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: COLOR_CODE_PURPLE),
                                  child: Text("Cancel",
                                      style: TextStyle_BLACK_W500_16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )));
          });
        }).then((value) => {
          if (value != null && value) {_query()}
        });
  }

  void showBottomSheetUpdateTask(ModelTODO model) {
    textEditTitle.text = model.title.toString();
    textEditDescription.text = model.description.toString();
    textEditTime.text = model.timer.toString();
    _dropdownMenuItems = buildDropdownMenuItems(statusList);
    _selectedCaption = model.status.toString();

    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(FIXED_SIZE_10))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
            return AnimatedPadding(
                padding: MediaQuery.of(context1).viewInsets,
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                child: Container(
                    padding: const EdgeInsets.only(
                      left: FIXED_SIZE_20,
                      right: FIXED_SIZE_20,
                      top: FIXED_SIZE_20,
                      bottom: FIXED_SIZE_10,
                    ),
                    margin: const EdgeInsets.only(bottom: FIXED_SIZE_10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(strTitle, style: TextStyle_BLACK_W500_16),
                          TextField(
                            controller: textEditTitle,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              filled: true,
                              fillColor: COLOR_CODE_WHITE,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: COLOR_CODE_PURPLE, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(strDescription, style: TextStyle_BLACK_W500_16),
                          TextField(
                            controller: textEditDescription,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(15),
                              filled: true,
                              fillColor: COLOR_CODE_WHITE,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: COLOR_CODE_PURPLE, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(strStatus, style: TextStyle_BLACK_W500_16),
                          Container(
                            height: FIXED_SIZE_50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(FIXED_SIZE_8),
                              color: COLOR_CODE_WHITE,
                              border: Border.all(
                                  width: FIXED_SIZE_1,
                                  color: COLOR_CODE_BLACK,
                                  style: BorderStyle.solid),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                items: _dropdownMenuItems,
                                value: _selectedCaption,
                                onChanged: (value) {
                                  setState1(() {
                                    _selectedCaption = value;
                                  });
                                },
                                buttonHeight: FIXED_SIZE_40,
                                itemHeight: FIXED_SIZE_50,
                                isExpanded: true,
                                itemPadding: const EdgeInsets.only(
                                    left: FIXED_SIZE_7, right: FIXED_SIZE_5),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                                dropdownDecoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(FIXED_SIZE_14),
                                  color: COLOR_CODE_WHITE,
                                ),
                                buttonPadding: const EdgeInsets.only(
                                    left: FIXED_SIZE_7, right: FIXED_SIZE_5),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Timer", style: TextStyle_BLACK_W500_16),
                          InkWell(
                            onTap: () async {
                              List<String> list = textEditTime.text.split(":");
                              TimeOfDay initialTime = TimeOfDay(
                                  hour: int.parse(list[0]),
                                  minute: int.parse(list[1]));

                              print(initialTime);

                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                              );
                              textEditTime.text = pickedTime!.hour.toString() +
                                  ":" +
                                  pickedTime.minute.toString();
                            },
                            child: TextField(
                              controller: textEditTime,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(15),
                                filled: true,
                                enabled: false,
                                prefixIcon: Icon(Icons.timer),
                                fillColor: COLOR_CODE_WHITE,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: COLOR_CODE_PURPLE, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  String validation = '';
                                  textEditTitle.text.isEmpty
                                      ? validation = 'Please enter Title'
                                      : textEditDescription.text.isEmpty
                                          ? validation =
                                              'Please enter Description'
                                          : '';
                                  if (validation == "") {
                                    ModelClass modelClass = ModelClass(
                                        title: textEditTitle.text,
                                        description: textEditDescription.text,
                                        timer: textEditTime.text,
                                        status: _selectedCaption);
                                    _Updatequery(modelClass, model);
                                    Navigator.of(context).pop();
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: validation,
                                      backgroundColor: COLOR_CODE_PURPLE,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width / 2 - 25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: COLOR_CODE_PURPLE),
                                  child: Text("Save",
                                      style: TextStyle_BLACK_W500_16),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width / 2 - 25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: COLOR_CODE_PURPLE),
                                  child: Text("Cancel",
                                      style: TextStyle_BLACK_W500_16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )));
          });
        }).then((value) => _query());
  }

  _Updatequery(ModelClass modelClass, ModelTODO model) async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    databaseHelper.update(modelClass, model.id);
    // get all rows
    List<Map> result = await db!.query(DatabaseHelper.table);
    // print the results
    result.forEach((row) => print(row));
    isloading = false;
    fetchedList = [];
    setState(() {
      fetchedList = result.map((f) => ModelTODO.fromJson(f)).toList();
    });
  }

  List<DropdownMenuItem<String>> buildDropdownMenuItems(List captions) {
    List<DropdownMenuItem<String>> items = [];
    for (String value in captions as Iterable<String>) {
      items.add(DropdownMenuItem(
        alignment: Alignment.centerLeft,
        value: value,
        child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle_BLACK_W400_14,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
      ));
    }

    return items;
  }
}
