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

class TodoUpdatePage extends StatefulWidget {
  ModelTODO? model;
  TodoUpdatePage({@required this.model});

  @override
  State<TodoUpdatePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TodoUpdatePage> {
  List<DropdownMenuItem<String>>? _dropdownMenuItems;
  String? _selectedCaption;
  List<String> statusList = ['TODO', 'In-Progress', 'Done'];
  List<ModelTODO> fetchedList = [];
  TextEditingController textEditTitle = TextEditingController();
  TextEditingController textEditDescription = TextEditingController();
  final GlobalKey<ScaffoldState> _modelScaffoldKey = GlobalKey<ScaffoldState>();
  bool isloading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _query();

    textEditTitle.text = widget.model!.title.toString();
    textEditDescription.text = widget.model!.description.toString();
    _dropdownMenuItems = buildDropdownMenuItems(statusList);
    _selectedCaption = widget.model!.status.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Todo Edit Page'),
      ),
      body:Stack(
        children: [
          Container(

            height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(
                left: FIXED_SIZE_20,
                right: FIXED_SIZE_20,
                top: FIXED_SIZE_20,
                bottom: FIXED_SIZE_10,
              ),
              margin: const EdgeInsets.only(bottom: FIXED_SIZE_10),
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
                          setState(() {
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
                    height: 20,
                  ),


                ],
              )),
          Positioned(
            bottom: 10,left: 10,right: 10,
            child: InkWell(
            onTap: () {

              String validation = '';
              textEditTitle.text.isEmpty
                  ? validation = 'Please enter Title'
                  : textEditDescription.text.isEmpty
                  ? validation = 'Please enter Description'
                  : '';
              if (validation == "") {
                ModelClass modelClass = ModelClass(
                    title: textEditTitle.text,
                    description: textEditDescription.text,
                    timer: widget.model!.timer.toString(),
                    status: _selectedCaption);
                _Updatequery(modelClass);
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
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: COLOR_CODE_PURPLE),
              child: Text("EDIT TODO",
                  style: TextStyle_BLACK_W500_16),
            ),
          ),)
        ],
      ),
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

  _Updatequery(ModelClass modelClass) async {
    // get a reference to the database
    Database? db = await DatabaseHelper.instance.database;
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    databaseHelper.update(modelClass, widget.model!.id);
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
