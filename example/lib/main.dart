
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dio_http_logger/dio_logger.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();;
  await DioNetworkLogger.instance.initLocalNotifications();
  runApp(
      MaterialApp(
        home: Stack(
          children: [
            const MyApp(),
            DioNetworkLogger.instance.overLayButtonWidget
          ],
        ),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Dio _client;

  @override
  void initState() {
    super.initState();
    _client = Dio();
    _client.interceptors.add(DioNetworkLogger.instance.dioNetworkInterceptor!);
    DioNetworkLogger.instance.listenerEventChange = () {
      final models = DioNetworkLogger.instance.networkModels;
      if (models.isNotEmpty && models.first.exception != null) {
        debugPrint('Logged error response body: ${models.first.responseBody}');
      }
    };
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _client.get('https://jsonplaceholder.typicode.com/404');
      } catch (_) {
        // Ignore; we only care about logging output.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DioNetworkLogger.instance.context = context;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dio http logger app example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                onPressed: (){
                  _client.get('https://jsonplaceholder.typicode.com/todos/1');
                }, child: const Text('SEND GET REQUEST')
            ),
            TextButton(
                onPressed: (){
                  _client.post(
                    'https://jsonplaceholder.typicode.com/posts',
                    data: {
                      'title': 'New Post',
                      'body': 'This is the body of the new post.',
                      'userId': 1,
                    },
                  );
                }, child: const Text('SEND POST REQUEST')
            ),
            TextButton(
                onPressed: (){
                  _client.put(
                    'https://jsonplaceholder.typicode.com/posts/1',
                    data: {
                      'id': 1,
                      'title': 'Updated Post',
                      'body': 'This is the updated body of the post.',
                      'userId': 1,
                    },
                  );
                }, child: const Text('SEND PUT REQUEST')
            ),
          ],
        ),
      ),
    );
  }
}
