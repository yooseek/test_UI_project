import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:test_ui_project/api/dio_service.dart';

class DioConnection {

  final DioService dioService;

  DioConnection(
    this.dioService,
  ) {
    final baseOptions = BaseOptions(
      baseUrl: "www.sample-url.com",
    );
    final _cacheOptions = CacheOptions(
      store: HiveCacheStore('Directory'),
      policy: CachePolicy.request, // Bcz we force cache on-demand in repositories
      maxStale: const Duration(days: 30), // No of days cache is valid
      keyBuilder: (options) => options.path,
      hitCacheOnErrorExcept: [401,403],
    );

    final dio = DioService(
      dioClient: Dio(),
      globalCacheOptions: _cacheOptions,
      interceptors: [
        // Order of interceptors very important
        DioCacheInterceptor(options: _cacheOptions),
      ],
    );
  }
}