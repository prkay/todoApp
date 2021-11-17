// ignore: import_of_legacy_library_into_null_safe
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/task_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomePageReadyEvent extends HomeEvent {
  @override
  List<Object> get props => [];
}

class GetAllTaskListEvent extends HomeEvent {
  late final String deviceID;
  GetAllTaskListEvent({required this.deviceID});
  @override
  List<Object> get props => [this.deviceID];
}

class CreateTaskEvent extends HomeEvent {
  late final TaskModel taskModel;
  CreateTaskEvent({required this.taskModel});
  @override
  List<Object> get props => [this.taskModel];
}

class CompleteTaskEvent extends HomeEvent {
  late final TaskModel taskModel;
  CompleteTaskEvent({required this.taskModel});
  @override
  List<Object> get props => [this.taskModel];
}

class DeleteTaskEvent extends HomeEvent {
  late final TaskModel taskModel;
  DeleteTaskEvent({required this.taskModel});
  @override
  List<Object> get props => [this.taskModel];
}
