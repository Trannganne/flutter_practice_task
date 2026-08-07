import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/weather.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/weather_api.dart';

class WeatherRepository {
  final WeatherApi api;

  WeatherRepository(this.api);

  Future<Weather> getCurrentWeather(double lat, double lon) async {
    final json = await api.getCurrentWeather(lat, lon);

    return Weather.fromJson(json);
  }
}
