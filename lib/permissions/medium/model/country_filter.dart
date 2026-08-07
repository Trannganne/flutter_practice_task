class CountryFilter {
  final String keyword;
  final int? minPopulation;
  final int? maxPopulation;
  final String? drivingSide;

  const CountryFilter({
    this.keyword = '',
    this.minPopulation,
    this.maxPopulation,
    this.drivingSide,
  });

  bool get isFilterActive =>
      minPopulation != null || maxPopulation != null || drivingSide != null;

  CountryFilter copyWith({
    String? keyword,
    int? minPopulation,
    int? maxPopulation,
    String? drivingSide,
    bool clearDrivingSide = false,
  }) {
    return CountryFilter(
      keyword: keyword ?? this.keyword,
      minPopulation: minPopulation ?? this.minPopulation,
      maxPopulation: maxPopulation ?? this.maxPopulation,
      drivingSide: clearDrivingSide ? null : (drivingSide ?? this.drivingSide),
    );
  }

  // Xoá riêng phần filter, GIỮ NGUYÊN keyword đang gõ trong ô search
  CountryFilter clearFiltersOnly() => CountryFilter(keyword: keyword);
}
