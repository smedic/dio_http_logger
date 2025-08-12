import 'package:dio/dio.dart' as dio;
import 'package:dio_http_logger/src/utils/local_notification.dart';
import 'package:dio_http_logger/src/utils/utils.dart';

import '../models/network_model.dart';


class DioNetworkInterceptor extends dio.Interceptor {
  Function(NetworkModel) callBackOnRequest;
  Function(dio.Response) callBackOnResponse;
  Function(dio.DioException) callBackOnError;
  DioNetworkInterceptor(this.callBackOnRequest,this.callBackOnResponse,this.callBackOnError);

  @override
  Future<void> onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) async{
    super.onRequest(options, handler);
    var requestTime = DateTime.now().millisecondsSinceEpoch.toString();
    NetworkModel networkModel = NetworkModel();
    if (options.data is dio.FormData) {
      networkModel.requestType = 'POST(multipart)';
    } else {
      networkModel.requestType = options.method.toUpperCase();
    }
    networkModel.path = "${options.baseUrl}${options.path}";
    networkModel.uri = options.uri;
    networkModel.requestTime = requestTime;
    networkModel.requestHeaders = options.headers;
    networkModel.queryParams = options.queryParameters;
    if (options.data is dio.FormData) {
      networkModel.requestBody = { 'body': 'attachment_multipart...'};
    } else {
      networkModel.requestBody = options.data;
    }
    networkModel.requestSize = measureNetworkData(options.data);
    networkModel.requestOptions = options;
    LocalNotification.instance.showSimpleNotification('Request : : ${networkModel.requestType}', options.path, 'payload');
    callBackOnRequest.call(networkModel);
    options.extra['requestTimestamp'] = requestTime;
    return Future.value(options);
  }

  @override
  Future<void> onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) async{
    super.onResponse(response, handler);
    callBackOnResponse.call(response);
  }

  @override
  Future<void> onError(dio.DioException err, dio.ErrorInterceptorHandler handler) async{
    super.onError(err, handler);
    callBackOnError.call(err);
  }
}
