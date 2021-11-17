import 'package:flutterapp/features/home/bloc/home_bloc.dart';
import 'package:flutterapp/repository/firebase_repository.dart';
import 'package:get_it/get_it.dart';

final di = GetIt.instance;

Future<void> init() async {
  // BLoC
  di.registerFactory(() => HomeBloc(fireBaseRepository: FireBaseRepository()));
}
