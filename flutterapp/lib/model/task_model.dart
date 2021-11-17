import 'dart:convert';

enum STATUS { pending, finished }

extension ParseToString on STATUS {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class TaskModel {
  final String status;
  final String name;
  final String deviceId;
  final String dateOfTask;
  TaskModel(
      {required this.status,
      required this.name,
      required this.deviceId,
      required this.dateOfTask});

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
        status: map["status"],
        name: map["name"],
        deviceId: map["device_id"],
        dateOfTask: map["time"]);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["status"] = status;
    map["name"] = name;
    map["device_id"] = deviceId;
    map["time"] = dateOfTask;
    return map;
  }
}
