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

class RefreshCountryEvent extends CountryEvent {}

class ExportCsvEvent extends CountryEvent {
  final bool exportAll;
  ExportCsvEvent({required this.exportAll});
}

class RequestStoragePermissionEvent extends CountryEvent {}

class ShareExportedFileEvent extends CountryEvent {
  final String filePath;
  ShareExportedFileEvent(this.filePath);
}

class ApplyFilterEvent extends CountryEvent {
  final CountryFilter filter;

  ApplyFilterEvent(this.filter);
}
