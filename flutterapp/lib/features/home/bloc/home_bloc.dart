import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterapp/model/task_model.dart';
import 'package:flutterapp/repository/firebase_repository.dart';

import 'bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  String versiontemp = "";
  @override
  HomeState get initialState => EmptyState(false);
  final FireBaseRepository fireBaseRepository;
  HomeBloc({
    required this.fireBaseRepository,
  });

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is HomePageReadyEvent) {
      yield HomePageReadyState(true, false);
    } else if (event is GetAllTaskListEvent) {
      yield* getAllTask(event.deviceID);
    } else if (event is CreateTaskEvent) {
      yield* createTask(event.taskModel);
    } else if (event is CompleteTaskEvent) {
      yield* completeTask(event.taskModel);
    } else if (event is DeleteTaskEvent) {
      yield* deleteTask(event.taskModel);
    }
  }

  Stream<HomeState> deleteTask(TaskModel taskModel) async* {
    yield BackendTaskRunningState(true);
    try {
      await fireBaseRepository.deleteTask(taskModel: taskModel);
      yield DeleteTaskSuccessState(false);
    } catch (e) {
      BackendTaskFailedState(
          false, "Something went wrong please try again later.");
    }
  }

  Stream<HomeState> createTask(TaskModel taskModel) async* {
    yield BackendTaskRunningState(true);
    try {
      await fireBaseRepository.createTask(task: taskModel);
      yield CreateTaskSuccessState(false);
    } catch (e) {
      BackendTaskFailedState(
          false, "Something went wrong please try again later.");
    }
  }

  Stream<HomeState> completeTask(TaskModel taskModel) async* {
    yield BackendTaskRunningState(true);
    try {
      await fireBaseRepository.completeTask(taskModel: taskModel);
      yield CompleteTaskSuccessState(false);
    } catch (e) {
      BackendTaskFailedState(
          false, "Something went wrong please try again later.");
    }
  }

  Stream<HomeState> getAllTask(String deviceID) async* {
    yield BackendTaskRunningState(true);
    try {
      var userList = await fireBaseRepository.getListOfAllTask(deviceID);
      yield GetAllTaskListSuccessState(false, userList);
    } catch (e) {
      BackendTaskFailedState(
          false, "Something went wrong please try again later.");
    }
  }
}
