import 'package:csv/csv.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';
import 'package:flutterpractisetasks/permissions/medium/model/country.dart';

class CsvService {
  // Chuyển List<Country> sang List<List<dynamic>>

  // Medium

  String toCsvRows(List<Country> countries) {
    final input = [
      ['name', 'capital', 'region', 'population'],
      for (final c in countries) [c.name, c.capital, c.region, c.population],
    ];
    final csvBody = csv.encode(input);
    return 'sep=,\n$csvBody';
  }

  // Hard
  String toCsv_Hard(List<ReportModel> reports) {
    final input = [
      ['Local path', 'Latitude', 'Longitude', 'Weather', 'Country guess'],
      for (final r in reports)
        [r.photoUrls, r.latitude, r.longitude, r.weatherDesc, r.country],
    ];
    final csvBody = csv.encode(input);
    return 'sep=,\n$csvBody';
  }
}
