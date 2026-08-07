import 'package:flutterpractisetasks/local_notification/hard/services/notificationservice.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/locationservice.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/weather_api.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Khởi tạo service/ notification => tuyệt đối không gọi BloC vì khi terminated thì UI bị killed hoàn toàn
    // => BloC không hoạt động

    switch (taskName) {
      case 'fetchForecastData':
        {
          // QUAN TRỌNG: Workmanager chạy callbackDispatcher trên 1 isolate
          // NỀN riêng biệt với isolate chính của app. FlutterLocalNotificationsPlugin
          // là static nhưng static KHÔNG được chia sẻ giữa các isolate, nên nếu
          // không gọi initialize() ở đây, plugin trong isolate nền này chưa từng
          // được khởi tạo -> notification nền sẽ âm thầm không hiển thị.
          await NotificationService.initialize();

          final position = await LocationService.getCurrentLocation();
          final forecasts = await WeatherApi.getForecast(
            position.latitude,
            position.longitude,
          );

          if (forecasts.maxRainProbabilityNext12h > 50) {
            NotificationService.showTestNotification(forecasts);
          }
          break;
        }
      default:
        break;
    }
    return Future.value(true);
  });
}

class WeatherBackgroundService {
  static const String taskName = 'fetchForecastData';

  Future<void> initBackgroundTask() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  Future<void> startPeriodicTask() async {
    Workmanager().registerPeriodicTask(
      'weather_periodic_id',
      taskName,
      frequency: Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  Future<void> stopBackgroundTask() async {
    Workmanager().cancelAll();
    print('Đã tắt chế độ chạy ngầm!');
  }
}
