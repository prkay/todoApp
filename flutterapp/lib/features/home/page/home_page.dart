import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterapp/features/home/bloc/bloc.dart';
import 'package:flutterapp/injectioncontainer/injection_container.dart';
import 'package:flutterapp/model/task_model.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime pickedTime = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool landingDone = false;
  late HomeBloc _homeBloc;
  var _landingDone = false;
  bool _isLoading = true;
  TextEditingController _textFieldController = TextEditingController();
  List<TaskModel> taskList = [];

  @override
  void initState() {
    _homeBloc = di<HomeBloc>();
    _homeBloc.add(HomePageReadyEvent());
    super.initState();
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _homeBloc,
      listener: (context, state) {
        if (state is HomePageReadyState) {
          fetchListForDevice();
        } else if (state is GetAllTaskListSuccessState) {
          setState(() {
            taskList = state.taskList;
          });
        } else if (state is BackendTaskFailedState) {
          _scaffoldKey.currentState!.showSnackBar(
              new SnackBar(content: new Text(state.errorMessageKey)));
        } else if (state is CreateTaskSuccessState) {
          _scaffoldKey.currentState!
              .showSnackBar(new SnackBar(content: new Text("Task Created.")));
          fetchListForDevice();
        } else if (state is CompleteTaskSuccessState) {
          fetchListForDevice();
          _scaffoldKey.currentState!
              .showSnackBar(new SnackBar(content: new Text("Task Completed.")));
        } else if (state is DeleteTaskSuccessState) {
          fetchListForDevice();
          _scaffoldKey.currentState!
              .showSnackBar(new SnackBar(content: new Text("Task Deleted.")));
        }
      },
      builder: (context, state) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Manage your task here"),
            ),
            body: RefreshIndicator(
                onRefresh: _createTask,
                child: ReorderableListView(
                  onReorder: onReorder,
                  children: _getListItems(),
                )),
            floatingActionButton: new FloatingActionButton(
                elevation: 0.0,
                child: new Icon(Icons.create),
                backgroundColor: new Color(0xFFE57373),
                onPressed: () {}));
      },
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      TaskModel task = taskList[oldIndex];
      taskList.removeAt(oldIndex);
      taskList.insert(newIndex, task);
    });
  }

  List<Widget> _getListItems() => taskList
      .asMap()
      .map((i, item) => MapEntry(i, _buildToDoListTile(item, i)))
      .values
      .toList();
  Widget _buildToDoListTile(TaskModel item, int index) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        if (direction.index == 3) {
          _homeBloc.add(CompleteTaskEvent(taskModel: taskList[index]));
        } else {
          _homeBloc.add(DeleteTaskEvent(taskModel: taskList[index]));
        }
      },
      background: Container(color: Colors.green),
      secondaryBackground: Container(color: Colors.red),
      child: Container(
          decoration: new BoxDecoration(color: _getColor(index)),
          margin: EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(
              taskList[index].name,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            subtitle: Text(
              _getFormattedDate(index),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            onTap: () {},
          )),
    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('What to do?'),
            content: TextField(
              controller: _textFieldController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(hintText: "Task Name"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Create Task'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _selectDate();
                },
              ),
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<void> _selectDate() async {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
              height: 240,
              color: Colors.white,
              child: Column(
                children: [
                  CupertinoButton(
                    child: Text(
                      'Create Task',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                    onPressed: () => {
                      Navigator.of(context).pop(),
                      saveTask(pickedTime),
                    },
                  ),
                  Container(
                    height: 180,
                    child: CupertinoDatePicker(
                      initialDateTime: DateTime.now(),
                      minimumDate:
                          DateTime.now().subtract(Duration(seconds: 30)),
                      maximumDate: DateTime.now().add(Duration(days: 7)),
                      onDateTimeChanged: (val) {
                        setState(() {
                          pickedTime = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ));
  }

  Future<void> saveTask(DateTime dateTime) async {
    String? deviceId = await _getId();
    if (deviceId != null) {
      TaskModel taskModel = TaskModel(
          status: STATUS.pending.toShortString(),
          name: _textFieldController.text,
          deviceId: deviceId,
          dateOfTask: dateTime.toString());
      _homeBloc.add(CreateTaskEvent(taskModel: taskModel));
    }
  }

  Future<void> fetchListForDevice() async {
    String? deviceId = await _getId();
    if (deviceId != null) {
      _homeBloc.add(GetAllTaskListEvent(deviceID: deviceId));
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId;
    }
  }

  Future<void> _createTask() async {
    _displayDialog(context);
  }

  String _getFormattedDate(int index) {
    DateTime tempDate =
        new DateFormat("yyyy-MM-dd hh:mm").parse(taskList[index].dateOfTask);
    return DateFormat("yyyy-MM-dd hh:mm a").format(tempDate.toLocal());
  }

  _getColor(int index) {
    DateTime tempDate =
        new DateFormat("yyyy-MM-dd hh:mm").parse(taskList[index].dateOfTask);
    if (DateTime.now().isAfter(tempDate)) {
      return Colors.redAccent;
    }
    return Colors.amberAccent;
  }
}
