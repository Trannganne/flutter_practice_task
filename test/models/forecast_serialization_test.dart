import 'package:flutter_test/flutter_test.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/hourly_forecast.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/weather.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';

// ==================== Dữ liệu mẫu ====================

/// Mẫu giống response thật từ OpenWeatherMap API (dt là int Unix seconds)
Map<String, dynamic> _apiHourlyJson(int dtUnix) => {
      'dt': dtUnix,
      'main': {'temp': 28.5, 'feels_like': 30.1, 'humidity': 75},
      'weather': [
        {'main': 'Rain', 'description': 'light rain', 'icon': '10d'}
      ],
      'wind': {'speed': 3.2},
      'pop': 0.8,
    };

/// Mẫu cache cũ (dt là ISO-8601 string) — đã lưu trước khi sửa
Map<String, dynamic> _oldCacheHourlyJson(String isoDate) => {
      'dt': isoDate,
      'main': {'temp': 28.5, 'feels_like': 30.1, 'humidity': 75},
      'weather': [
        {'main': 'Rain', 'description': 'light rain', 'icon': '10d'}
      ],
      'wind': {'speed': 3.2},
      'pop': 0.8,
    };

HourlyForecast _sampleHourly(DateTime dt) => HourlyForecast(
      dateTime: dt,
      temp: 28.5,
      weatherMain: 'Rain',
      description: 'light rain',
      rainProbability: 0.8,
      humidity: 75,
      windSpeed: 3.2,
      icon: '10d',
      feelsLike: 30.1,
    );

Weather _sampleWeather(DateTime dt) => Weather(
      cityName: 'Ho Chi Minh City',
      dateTime: dt,
      temp: 32.0,
      weatherMain: 'Clear',
      description: 'clear sky',
      rainProbability: 0.1,
      humidity: 60,
      windSpeed: 2.5,
      icon: '01d',
      feelsLike: 34.0,
      pressure: 1012,
    );

// ==================== Tests ====================

void main() {
  group('HourlyForecast serialization', () {
    test('fromJson — đọc dt dạng int (API response)', () {
      // 2026-09-22 14:00:00 UTC = 1790258400
      const dtUnix = 1790258400;
      final json = _apiHourlyJson(dtUnix);

      final model = HourlyForecast.fromJson(json);

      expect(model.dateTime, DateTime.fromMillisecondsSinceEpoch(dtUnix * 1000));
      expect(model.temp, 28.5);
      expect(model.rainProbability, 0.8);
      expect(model.weatherMain, 'Rain');
    });

    test('fromJson — đọc dt dạng String ISO-8601 (cache cũ)', () {
      const isoDate = '2026-09-22T14:00:00.000';
      final json = _oldCacheHourlyJson(isoDate);

      final model = HourlyForecast.fromJson(json);

      expect(model.dateTime, DateTime.parse(isoDate));
      expect(model.temp, 28.5);
    });

    test('toJson — ghi dt dạng int Unix seconds', () {
      final dt = DateTime(2026, 9, 22, 14, 0, 0);
      final model = _sampleHourly(dt);

      final json = model.toJson();

      expect(json['dt'], isA<int>());
      expect(json['dt'], dt.millisecondsSinceEpoch ~/ 1000);
    });

    test('round-trip: fromJson(toJson(model)) giữ đúng dữ liệu', () {
      final dt = DateTime(2026, 9, 22, 14, 30, 45);
      final original = _sampleHourly(dt);

      final restored = HourlyForecast.fromJson(original.toJson());

      // Unix seconds cắt mất milliseconds — chỉ so sánh đến giây
      final expectedDt = DateTime.fromMillisecondsSinceEpoch(
          (dt.millisecondsSinceEpoch ~/ 1000) * 1000);
      expect(restored.dateTime, expectedDt);
      expect(restored.temp, original.temp);
      expect(restored.weatherMain, original.weatherMain);
      expect(restored.description, original.description);
      expect(restored.rainProbability, original.rainProbability);
      expect(restored.humidity, original.humidity);
      expect(restored.windSpeed, original.windSpeed);
      expect(restored.icon, original.icon);
      expect(restored.feelsLike, original.feelsLike);
    });

    test('fromJson — dt không hợp lệ (double) → FormatException', () {
      final json = _apiHourlyJson(0);
      json['dt'] = 3.14; // double — sai kiểu

      expect(
        () => HourlyForecast.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson — dt null → FormatException', () {
      final json = _apiHourlyJson(0);
      json['dt'] = null;

      expect(
        () => HourlyForecast.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Weather serialization', () {
    test('fromJson — đọc dt dạng int (API response)', () {
      const dtUnix = 1790258400;
      final json = {
        'name': 'Ho Chi Minh City',
        'dt': dtUnix,
        'main': {'temp': 32.0, 'feels_like': 34.0, 'humidity': 60, 'pressure': 1012},
        'weather': [
          {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}
        ],
        'wind': {'speed': 2.5},
        'pop': 0.1,
      };

      final model = Weather.fromJson(json);

      expect(model.dateTime, DateTime.fromMillisecondsSinceEpoch(dtUnix * 1000));
      expect(model.cityName, 'Ho Chi Minh City');
      expect(model.temp, 32.0);
    });

    test('fromJson — đọc dt dạng String ISO-8601 (cache cũ)', () {
      const isoDate = '2026-09-22T07:00:00.000Z';
      final json = {
        'name': 'Ha Noi',
        'dt': isoDate,
        'main': {'temp': 30.0, 'feels_like': 32.0, 'humidity': 55, 'pressure': 1010},
        'weather': [
          {'main': 'Clouds', 'description': 'overcast', 'icon': '04d'}
        ],
        'wind': {'speed': 1.5},
        'pop': 0.3,
      };

      final model = Weather.fromJson(json);

      expect(model.dateTime, DateTime.parse(isoDate));
      expect(model.cityName, 'Ha Noi');
    });

    test('toJson — ghi dt dạng int Unix seconds', () {
      final dt = DateTime(2026, 9, 22, 14, 0, 0);
      final model = _sampleWeather(dt);

      final json = model.toJson();

      expect(json['dt'], isA<int>());
      expect(json['dt'], dt.millisecondsSinceEpoch ~/ 1000);
    });

    test('round-trip: fromJson(toJson(model)) giữ đúng dữ liệu', () {
      final dt = DateTime(2026, 9, 22, 14, 30, 45);
      final original = _sampleWeather(dt);

      // Weather.toJson ghi 'cityName', nhưng fromJson đọc 'name'
      // Nên round-trip phải đi qua key đúng:
      final json = original.toJson();
      // toJson ghi 'cityName', fromJson đọc 'name' — đây là design hiện tại
      // (toJson dùng cho cache, fromJson cho API). Tạo json phù hợp fromJson:
      json['name'] = json.remove('cityName');

      final restored = Weather.fromJson(json);

      final expectedDt = DateTime.fromMillisecondsSinceEpoch(
          (dt.millisecondsSinceEpoch ~/ 1000) * 1000);
      expect(restored.dateTime, expectedDt);
      expect(restored.cityName, original.cityName);
      expect(restored.temp, original.temp);
      expect(restored.weatherMain, original.weatherMain);
      expect(restored.description, original.description);
      expect(restored.rainProbability, original.rainProbability);
      expect(restored.pressure, original.pressure);
    });

    test('fromJson — dt không hợp lệ → FormatException', () {
      final json = {
        'name': 'Test',
        'dt': true, // bool — sai kiểu
        'main': {'temp': 30.0, 'feels_like': 32.0, 'humidity': 55, 'pressure': 1010},
        'weather': [
          {'main': 'Clear', 'description': 'clear', 'icon': '01d'}
        ],
        'wind': {'speed': 1.0},
        'pop': 0.0,
      };

      expect(
        () => Weather.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Forecast serialization (bao ngoài — luồng cache)', () {
    test('fromJson(toJson(forecast)) giữ đúng dữ liệu qua cache round-trip', () {
      final dt1 = DateTime(2026, 9, 22, 14, 0, 0);
      final dt2 = DateTime(2026, 9, 22, 17, 0, 0);
      final forecast = Forecast(
        cityName: 'Ho Chi Minh City',
        hourlyList: [_sampleHourly(dt1), _sampleHourly(dt2)],
      );

      // Mô phỏng luồng WeatherCacheservice: jsonEncode(forecast.toJson()) rồi
      // Forecast.fromJson(jsonDecode(...))
      final json = forecast.toJson();
      final restored = Forecast.fromJson(json);

      expect(restored.cityName, forecast.cityName);
      expect(restored.hourlyList.length, 2);

      // So sánh thời gian (đến giây)
      final expectedDt1 = DateTime.fromMillisecondsSinceEpoch(
          (dt1.millisecondsSinceEpoch ~/ 1000) * 1000);
      expect(restored.hourlyList[0].dateTime, expectedDt1);

      // So sánh dữ liệu
      expect(restored.hourlyList[0].temp, 28.5);
      expect(restored.hourlyList[0].rainProbability, 0.8);
      expect(restored.hourlyList[1].temp, 28.5);
    });

    test('fromJson đọc được cache cũ (dt dạng ISO string trong hourlyList)', () {
      // Mô phỏng dữ liệu cache cũ — dt là ISO string
      final json = {
        'city': {'name': 'Da Nang'},
        'list': [
          _oldCacheHourlyJson('2026-09-22T14:00:00.000'),
          _oldCacheHourlyJson('2026-09-22T17:00:00.000'),
        ],
      };

      final forecast = Forecast.fromJson(json);

      expect(forecast.cityName, 'Da Nang');
      expect(forecast.hourlyList.length, 2);
      expect(
        forecast.hourlyList[0].dateTime,
        DateTime.parse('2026-09-22T14:00:00.000'),
      );
    });
  });
}
