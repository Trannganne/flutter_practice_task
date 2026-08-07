class Country {
  final String name;
  final String officialName;
  final String capital;
  final String? flagUrl;
  final String? region;
  final double? area_km;
  final double? area_m;
  final String? driving_side;
  final String? currencies_code;
  final String? currencies_symbol;
  final String? links_wiki;
  final String? links_ggmaps;
  final int population;
  final List<String>? membership;

  const Country({
    required this.name,
    required this.officialName,
    required this.capital,
    this.flagUrl,
    this.region,
    this.area_km,
    this.area_m,
    this.driving_side,
    this.currencies_code,
    this.currencies_symbol,
    this.links_wiki,
    this.links_ggmaps,
    required this.population,
    this.membership,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'officialName': officialName,
      'capital': capital,
      'flagUrl': flagUrl,
      'region': region,
      'area_km': area_km,
      'area_m': area_m,
      'driving_side': driving_side,
      'currencies_code': currencies_code,
      'currencies_symbol': currencies_symbol,
      'links_wiki': links_wiki,
    };
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    final membershipsMap = json['memberships'] as Map<String, dynamic>? ?? {};
    final joinedOrgs = membershipsMap.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key.replaceAll('_', ' ').toUpperCase())
        .toList();

    // ---- Các field lồng nhau, có thể null -> lấy ra thành biến trung gian
    // rồi dùng ?. ở MỌI bước tiếp theo, không bao giờ index thẳng vào JSON gốc.
    final names = json['names'] as Map<String, dynamic>?;
    final capitalsList = json['capitals'] as List<dynamic>?;
    final flagMap = json['flag'] as Map<String, dynamic>?;
    final areaMap = json['area'] as Map<String, dynamic>?;
    final carsMap = json['cars'] as Map<String, dynamic>?;
    final linksMap = json['links'] as Map<String, dynamic>?;
    // currencies là LIST, lấy phần tử đầu tiên (nếu có) để ra code/symbol
    final currenciesList = json['currencies'] as List<dynamic>?;
    final firstCurrency = (currenciesList != null && currenciesList.isNotEmpty)
        ? currenciesList.first as Map<String, dynamic>?
        : null;

    return Country(
      name: names?['common'] as String? ?? 'Unknown',
      officialName: names?['official'] as String? ?? '',
      // capitals là List -> lấy phần tử [0]['name'], có fallback khi rỗng
      capital: (capitalsList != null && capitalsList.isNotEmpty)
          ? (capitalsList.first as Map<String, dynamic>)['name'] as String? ??
                '—'
          : '—',
      flagUrl: flagMap?['url_svg'] as String?,
      region: json['region'] as String?,
      area_km: (areaMap?['kilometers'] as num?)?.toDouble(),
      area_m: (areaMap?['miles'] as num?)?.toDouble(),
      driving_side: carsMap?['driving_side'] as String?,
      currencies_code: firstCurrency?['code'] as String?,
      currencies_symbol: firstCurrency?['symbol'] as String?,
      links_ggmaps: linksMap?['google_maps'] as String?,
      links_wiki: linksMap?['wikipedia'] as String?,
      population: (json['population'] as num?)?.toInt() ?? 0,
      membership: joinedOrgs,
    );
  }
}
