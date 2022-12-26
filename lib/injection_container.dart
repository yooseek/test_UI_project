import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:test_ui_project/bloc/tmp2_bloc.dart';
import 'package:test_ui_project/bloc/tmp_bloc.dart';
import 'package:test_ui_project/repository/tmp_repo.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {

  //repoimpl
  serviceLocator.registerLazySingleton<TmpRepository>(() => TmpRepositoryImpl());
  //usecases - 생략

  //blocs
  serviceLocator.registerFactory<TmpBloc>(() => TmpBloc(tmpRepository: serviceLocator()));
  serviceLocator.registerFactory<Tmp2Bloc>(() => Tmp2Bloc(tmpRepository: serviceLocator()));
}