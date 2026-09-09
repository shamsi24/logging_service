import '../src/adapter/dio/dio_logging_interceptor.dart';

export '../src/adapter/dio/dio_logging_interceptor.dart';

/// Former name of [DioLoggingInterceptor].
///
/// Kept so existing apps keep compiling; import `package:logging_service/logging_service.dart`
/// and use [DioLoggingInterceptor] instead.
@Deprecated(
  'Use DioLoggingInterceptor from package:logging_service/logging_service.dart',
)
class DebugLogging extends DioLoggingInterceptor {
  DebugLogging();
}
