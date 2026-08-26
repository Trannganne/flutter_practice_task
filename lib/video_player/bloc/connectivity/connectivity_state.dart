import 'package:equatable/equatable.dart';

/// [isKnown] = false ĐÚNG 1 LẦN lúc khởi tạo — trước khi hasInternet() lần
/// đầu trả về. Tách riêng khỏi isOnline để UI không hiện nhầm banner
/// "offline" trong khoảnh khắc đầu tiên khi chưa kịp check thật.
class ConnectivityState extends Equatable {
  final bool isOnline;
  final bool isKnown;

  const ConnectivityState({this.isOnline = true, this.isKnown = false});

  @override
  List<Object?> get props => [isOnline, isKnown];
}
