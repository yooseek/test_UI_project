
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:test_ui_project/models/retrofit_res.dart';

part 'retrofit_service.g.dart';

// root : https://kfa-certification-server-ceyss6nzvq-du.a.run.app
@RestApi(baseUrl: "https://kfa-certification-server-ceyss6nzvq-du.a.run.app")
abstract class RetrofitService {
  factory RetrofitService(Dio dio, {String baseUrl}) = _RetrofitService;

  @GET('/api/v1/auth/sign-check')
  Future<RetrofitResponseModel<bool>> getChangeNumberCheck(
    @Query("phoneNumber") String phoneNumber,
  );
}