/// Shake to open network inspector for Flutter apps.
///
/// Attach [DioLoggingInterceptor] to a Dio client and start [DebugTool] once,
/// then shake the device to inspect every captured call.
library;

export 'src/adapter/dio/dio_logging_interceptor.dart';
export 'src/config/redaction_config.dart';
export 'src/export/curl_builder.dart';
export 'src/model/log_filter.dart';
export 'src/model/network_log_entry.dart';
export 'src/presentation/detail/page/log_detail_page.dart';
export 'src/presentation/logs/page/logs_page.dart';
export 'src/service/debug_tool.dart';
export 'src/service/sensor_service.dart' show ShakeDetector, PhoneShakeCallback;
export 'src/service/shake_service.dart';
export 'src/store/network_log_store.dart';
