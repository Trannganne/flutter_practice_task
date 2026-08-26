import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/connectivity_check/connectivity_service.dart';
import 'connectivity_state.dart';

/// Cubit phát hiện offline CHỦ ĐỘNG (proactive) — khác cách cũ chỉ catch
/// lỗi SAU KHI 1 API call đã thất bại. Dùng để:
///  1. Hiện OfflineBanner ngay khi mất mạng, không cần đợi user thao tác.
///  2. Cho UI tự chặn việc bắn API (search/load more/retry) TỪ ĐẦU khi đã
///     biết chắc đang offline — tránh chờ HTTP timeout vô ích.
///
/// Cố tình KHÔNG gộp logic này vào PopularBloc/SearchBloc — 2 Bloc đó chỉ
/// lo pagination/fetch, còn network-awareness là 1 concern riêng, dùng
/// chung được cho mọi tab (Home/Search) mà không cần Bloc nào phụ thuộc
/// Bloc nào.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit({ConnectivityService? service})
    : _service = service ?? ConnectivityService(),
      super(const ConnectivityState()) {
    _init();
  }

  Future<void> _init() async {
    final hasInternet = await _service.hasInternet();
    if (isClosed) return;
    emit(ConnectivityState(isOnline: hasInternet, isKnown: true));

    _subscription = _service.onConnectivityChanged.listen((isOnline) {
      if (isClosed) return;
      emit(ConnectivityState(isOnline: isOnline, isKnown: true));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
