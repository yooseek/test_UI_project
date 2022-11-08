import 'package:flutter/cupertino.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServiceStatus {
  online,
  offline,
  connecting,
}

class SocketProvider with ChangeNotifier {
  ServiceStatus _serviceStatus = ServiceStatus.connecting;
  IO.Socket _socket = IO.io(
      'http://221.149.169.91:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .build());

  SocketProvider() {
    _initConfig();
  }

  ServiceStatus get serverStatus => _serviceStatus;
  IO.Socket get socket => _socket;
  get emit => _socket.emit;

  void _initConfig() {
    _socket.onConnect((_) {
      print('connect');
      _serviceStatus = ServiceStatus.online;
      notifyListeners();
    });

    _socket.on('event', (data) => print(data));

    _socket.onDisconnect((_) {
      print('disconnect');
      _serviceStatus = ServiceStatus.offline;
      notifyListeners();
    });

    _socket.on('nuevo-mensaje', (payload) {
      print('data : $payload');
    });
  }
}
