import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/permissions/medium/model/country_filter.dart';

abstract class CountryEvent extends Equatable {
  const CountryEvent();

  @override
  List<Object?> get props => [];
}

// Load lần đầu
class CountryStarted extends CountryEvent {}

class FetchCountryEvent extends CountryEvent {}

class ExportCsvEvent extends CountryEvent {}

class RequestStoragePermissionEvent extends CountryEvent {}

class OpenExportedFileEvent extends CountryEvent {
  final String filePath;
  OpenExportedFileEvent(this.filePath);
}

class ApplyFilterEvent extends CountryEvent {
  final CountryFilter filter;

  ApplyFilterEvent(this.filter);
}
