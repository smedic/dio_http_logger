import 'package:flutter/material.dart';

import '../dio_network_logger.dart';
import '../models/network_model.dart';
import '../utils/utils.dart';
import 'network_request_details.dart';

class NetworkRequestsList extends StatefulWidget {
  const NetworkRequestsList({super.key});

  @override
  State<NetworkRequestsList> createState() => _NetworkRequestsListState();
}

class _NetworkRequestsListState extends State<NetworkRequestsList> {

  final DioNetworkLogger _dioNetworkLogger = DioNetworkLogger.instance;
  List<NetworkModel> models = [];

  @override
  void initState() {
    models = _dioNetworkLogger.networkModels;
    _dioNetworkLogger.listenerEventChange = (){
      setState(() {
        models = _dioNetworkLogger.networkModels;
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _dioNetworkLogger.listenerEventChange = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dio logger'),
      ),
      body: Stack(
        children: [
          models.isNotEmpty?Container(
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: models.length,
              itemBuilder: (context, index) {
                return NetworkLogEntryWidget(entry: models[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider( // Or any other separator widget you prefer
                  height: 1,
                  color: Colors.black12,
                );
              },
            ),
          ):const Center(child: Text('No requests found'),),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.indigo,
              onPressed: () {
                DioNetworkLogger.instance.deleteAllRequests();
              },
              child: const Icon(Icons.delete,color: Colors.white,),
            ),
          ),
          /*Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                //DioNetworkLogger.instance.startNetworkLoggerScreen();
              },
              child: Icon(Icons.filter_list_alt,color: Colors.white,),
            ),
          ),*/
        ],
      ),
    );
  }

}

class NetworkLogEntryWidget extends StatelessWidget {
  final NetworkModel entry;

  const NetworkLogEntryWidget({super.key, required this.entry});

@override
  Widget build(BuildContext context) {
  var typeColor = entry.code == null?Colors.black26:entry.requestType == 'GET'?Colors.green:entry.requestType == 'POST'?Colors.teal:entry.requestType == 'PUT'?Colors.indigo:Colors.red;
  final responseColor = (entry.code == null) ? Colors.black38 : (entry.code! >= 200 && entry.code! <= 300) ? Colors.green:(entry.code! >= 400 && entry.code! <=499)?Colors.amber: Colors.red;
  final uri = Uri.parse(entry.path??'');
  print("SMEDIC URI1: ${'${uri.scheme}://${uri.host}'}");
  print("SMEDIC URI2: ${uri.scheme}");
  print("SMEDIC URI3: ${uri.host}");

  final fullUri = '${uri.scheme}://${uri.host}';
  print("SMEDIC FULL URI: ${fullUri}");

  // // Find the index of the last slash
  // int lastSlashIndex = url.lastIndexOf('/');
  //
  // if (lastSlashIndex != -1) {
  //   // Extract the part before the last slash
  //   String base = url.substring(0, lastSlashIndex);
  //   // Extract the part after the last slash
  //   String filename = url.substring(lastSlashIndex + 1);
  //
  //   print("Base: $base");      // Output: https://example.com/path/to
  //   print("Filename: $filename"); // Output: file.txt
  // } else {
  //   print("No slash found in the string.");
  // }

  return ListTile(
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
                entry.requestType ?? '',
                style: TextStyle(
                  color: typeColor,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  uri.path,
                  style: TextStyle(
                    color: entry.code == null ? Colors.black26 : Colors.black,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.start,
                  // Align text to the start (left)
                  maxLines: 2,
                ),
              ),
            ],
          ),
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              uri.scheme == 'https'
                  ? const Icon(Icons.lock, size: 12)
                  : Container(),
              const SizedBox(width: 2.0),
              Expanded(
                child: Text(
                  '${uri.scheme}://${uri.host}',
                  style: TextStyle(
                      color: entry.code == null ? Colors.black26 : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    subtitle: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Time: ${milisToDateTime(int.parse(entry.requestTime??'0'))}",style: TextStyle(color: entry.code == null?Colors.black26:Colors.black,fontSize: 10)),
        Text("Size: ${entry.responseSize ?? '0'}B",style: TextStyle(color: entry.code == null?Colors.black26:Colors.black,fontSize: 10)),
      ],
    ),
    trailing: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: responseColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          entry.code == -87
              ? 'Error'
              : entry.code == null
                  ? 'Pending'
                  : entry.code.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NetworkRequestDetails(entry)));
      },
    );
  }
}
