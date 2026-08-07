import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/connectivity_check/connectivity_service.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final ConnectivityService _service;

  StreamSubscription<bool>? _subscription;

  ConnectivityCubit(this._service) : super(ConnectivityStatus.online) {
    _init();
  }

  Future<void> _init() async {
    // Check trạng thái ngay khi Cubit được khởi tạo, tránh hiện sai banner lúc mở app
    final hasInternet = await _service.hasInternet();
    emit(hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline);
    ;

    // Lắng nghe thay đổi liên tục
    _subscription = _service.onConnectivityChanged.listen((hasInternet) {
      emit(
        hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline,
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
