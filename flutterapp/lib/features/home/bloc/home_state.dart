import 'package:equatable/equatable.dart';
import 'package:flutterapp/model/task_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class EmptyState extends HomeState {
  final isLoading;

  EmptyState(this.isLoading);
  @override
  List<Object> get props => [isLoading];
}

class HomePageReadyState extends HomeState {
  final bool landingDone;
  final isLoading;

  HomePageReadyState(this.landingDone, this.isLoading);

  @override
  List<Object> get props => [landingDone, isLoading];
}

class BackendTaskRunningState extends HomeState {
  final isLoading;

  BackendTaskRunningState(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class GetAllTaskListSuccessState extends HomeState {
  final isLoading;
  final List<TaskModel> taskList;

  GetAllTaskListSuccessState(this.isLoading, this.taskList);

  @override
  List<Object> get props => [isLoading, taskList];
}

class CreateTaskSuccessState extends HomeState {
  final isLoading;

  CreateTaskSuccessState(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class CompleteTaskSuccessState extends HomeState {
  final isLoading;

  CompleteTaskSuccessState(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class DeleteTaskSuccessState extends HomeState {
  final isLoading;

  DeleteTaskSuccessState(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class BackendTaskFailedState extends HomeState {
  final isLoading;
  final String errorMessageKey;

  BackendTaskFailedState(this.isLoading, this.errorMessageKey);

  @override
  List<Object> get props => [isLoading, errorMessageKey];
}
