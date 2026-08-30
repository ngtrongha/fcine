import 'package:dio/dio.dart';
import '../config/master_config.dart';

class DioClient {
  final Dio dio;
  DioClient({Dio? dio, required AppSettings settings})
      : dio = dio ??
            Dio(BaseOptions(
              connectTimeout: Duration(milliseconds: settings.requestTimeoutMs),
              receiveTimeout: Duration(milliseconds: settings.requestTimeoutMs),
              sendTimeout: Duration(milliseconds: settings.requestTimeoutMs),
              headers: {'accept': 'application/json'},
              validateStatus: (s) => s != null && s < 500,
            )) {
    // logging interceptor
    this.dio.interceptors.add(LogInterceptor(request: false, requestHeader: false, responseHeader: false, responseBody: false));
  }

  factory DioClient.forSource(SourceConfig source, AppSettings settings) {
    final dio = Dio(BaseOptions(
      baseUrl: source.baseUrl,
      connectTimeout: Duration(milliseconds: settings.requestTimeoutMs),
      receiveTimeout: Duration(milliseconds: settings.requestTimeoutMs),
      headers: source.headers,
      validateStatus: (s) => s != null && s < 500,
    ));
    dio.interceptors.add(InterceptorsWrapper(onError: (e, h) async {
      // fallback domain retry (simple)
      // nếu lỗi network và có fallback, thử lại 1 lần với fallbackUrls[0]
      // Để đơn giản, không tự đổi baseUrl ở đây, để datasource tự retry
      return h.next(e);
    }));
    return DioClient(dio: dio, settings: settings);
  }
}
