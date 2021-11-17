import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/task_model.dart';

enum taskExist { exist, notexist, otherError }

class FireBaseRepository {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('task');

  Future<void> createTask({required TaskModel task}) async {
    try {
      DocumentReference documentReferencer =
          userCollection.doc(task.deviceId + task.dateOfTask);
      await documentReferencer.set(task.toMap()).whenComplete(() {
        print("dfasdfasdf");
      }).catchError((e) => print(e));
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> getListOfAllTask(String deviceID) async {
    try {
      final QuerySnapshot result = await Future.value(
          userCollection.orderBy('time', descending: true).get());
      List<TaskModel> taskList = [];
      result.docs.forEach((element) {
        TaskModel taskModel = TaskModel.fromMap(element.data());
        if (taskModel.deviceId == deviceID &&
            taskModel.status == STATUS.pending.toShortString()) {
          taskList.add(TaskModel.fromMap(element.data()));
        }
      });
      print(taskList.length);
      return taskList;
    } catch (e) {
      print(e);
      return "Something went wrong please try again later.";
    }
  }

  Future<void> completeTask({required TaskModel taskModel}) async {
    try {
      TaskModel updateTask = TaskModel(
          dateOfTask: taskModel.dateOfTask,
          deviceId: taskModel.deviceId,
          name: taskModel.name,
          status: STATUS.finished.toShortString());
      DocumentReference documentReferencer =
          userCollection.doc(taskModel.deviceId + taskModel.dateOfTask);
      await documentReferencer.update(updateTask.toMap());
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteTask({required TaskModel taskModel}) async {
    try {
      DocumentReference documentReferencer =
          userCollection.doc(taskModel.deviceId + taskModel.dateOfTask);
      await documentReferencer.delete();
    } catch (e) {
      print(e);
    }
  }
}
