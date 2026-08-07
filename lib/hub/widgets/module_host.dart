import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/connectivity_check/cubit/connectivity_cubit.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/common/commontext.dart';
import 'package:go_router/go_router.dart';

/// Mỗi bài tập (Easy/Medium/Hard) trong project này được xây dựng như MỘT APP
/// ĐỘC LẬP: có GoRouter riêng, và một số nơi (ví dụ trình xử lý khi tap vào
/// notification) gọi thẳng vào router tĩnh của module đó (VD:
/// `AppRouter.router.push(...)`) thay vì dùng `context` của widget tree hiện
/// tại. Vì vậy để mở 1 bài tập từ màn Hub mà KHÔNG phá vỡ luồng điều hướng nội
/// bộ của bài đó, cách an toàn nhất là "nhúng" cả GoRouter của module đó vào
/// trong 1 MaterialApp.router riêng, rồi Navigator.push cả khối này lên trên
/// cùng của Hub. Nhờ vậy mỗi module vẫn hoạt động y hệt như khi chạy độc lập.
class ModuleHost extends StatelessWidget {
  final String title;
  final GoRouter routerConfig;
  final List<BlocProvider> providers;
  // Chỉ module cần mới bật
  final bool showOfflineBanner;

  const ModuleHost({
    super.key,
    required this.title,
    required this.routerConfig,
    this.providers = const [],
    this.showOfflineBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('ModuleHost build — providers.length = ${providers.length}');
    Widget app = MaterialApp.router(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      routerConfig: routerConfig,
      builder: showOfflineBanner
          ? (context, child) => _OfflineBannerWrapper(child: child)
          : null,
    );

    if (providers.isNotEmpty) {
      app = MultiBlocProvider(providers: providers, child: app);
    }

    return app;
  }
}

class _OfflineBannerWrapper extends StatelessWidget {
  final Widget? child;
  const _OfflineBannerWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
          builder: (context, status) {
            final isOffline = status == ConnectivityStatus.offline;
            return AnimatedContainer(
              duration: const Duration(microseconds: 250),
              height: isOffline ? 32 : 0,
              width: double.infinity,
              color: Colors.redAccent,
              child: isOffline
                  ? const Center(
                      child: CommonText(
                        text: 'Không có kết nối mạng!, ',
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    )
                  : null,
            );
          },
        ),
        Expanded(child: child ?? const SizedBox.shrink()),
      ],
    );
  }
}
