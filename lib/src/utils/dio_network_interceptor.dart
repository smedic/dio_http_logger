import 'package:dio/dio.dart' as dio;
import 'package:dio_http_logger/src/utils/local_notification.dart';
import 'package:dio_http_logger/src/utils/utils.dart';

import '../models/network_model.dart';

class DioNetworkInterceptor extends dio.Interceptor {
  final void Function(NetworkModel) callBackOnRequest;
  final void Function(dio.Response) callBackOnResponse;
  final void Function(dio.DioException) callBackOnError;

  DioNetworkInterceptor(
    this.callBackOnRequest,
    this.callBackOnResponse,
    this.callBackOnError,
  );

  @override
  void onRequest(
      dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    // Timestamp MUST be set before we create/store the model (and before request continues)
    final requestTime = DateTime.now().millisecondsSinceEpoch.toString();
    options.extra['requestTimestamp'] = requestTime;

    final networkModel = NetworkModel();

    if (options.data is dio.FormData) {
      networkModel.requestType = 'POST(multipart)';
    } else {
      networkModel.requestType = options.method.toUpperCase();
    }

    // Use full URI so matching includes query params too
    final fullUri = options.uri.toString();
    networkModel.path = fullUri;

    networkModel.uri = options.uri;
    networkModel.requestTime = requestTime;
    networkModel.requestHeaders = options.headers;
    networkModel.queryParams = options.queryParameters;

    if (options.data is dio.FormData) {
      networkModel.requestBody = {'body': 'attachment_multipart...'};
    } else {
      networkModel.requestBody = options.data;
    }

    // measureNetworkData expects something; guard null
    networkModel.requestSize = measureNetworkData(options.data);
    networkModel.requestOptions = options;

    LocalNotification.instance.showSimpleNotification(
      'Request :: ${networkModel.requestType}',
      fullUri,
      'payload',
    );

    // Store model BEFORE continuing the request
    callBackOnRequest(networkModel);

    // IMPORTANT: continue chain
    handler.next(options);
  }

  @override
  void onResponse(
      dio.Response response, dio.ResponseInterceptorHandler handler) {
    callBackOnResponse(response);
    handler.next(response);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    final cleanError = dio.DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.response?.data,
    );
    callBackOnError(cleanError);
    handler.next(cleanError);
  }
}
