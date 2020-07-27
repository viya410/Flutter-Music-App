import 'dart:async';
import 'package:connectivity/connectivity.dart';

class ConnectivityBloc {
  StreamController _connectivityController;
  StreamSink<ConnectivityResult> get connectivityResultSink =>
      _connectivityController.sink;
  Stream<ConnectivityResult> get connectivityResultStream =>
      _connectivityController.stream;

  ConnectivityBloc() {
    _connectivityController = StreamController<ConnectivityResult>.broadcast();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _connectivityController.add(result);
    });
  }
  dispose() {
    _connectivityController?.close();
  }
}
