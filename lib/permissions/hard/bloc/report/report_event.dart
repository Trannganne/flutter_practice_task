import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/permissions/hard/models/draftmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class HomeScreenOpened extends ReportEvent {
  const HomeScreenOpened();
}

class LoadReportEvent extends ReportEvent {
  const LoadReportEvent();
}

class LoadDraftsEvent extends ReportEvent {
  const LoadDraftsEvent();
}

class DeleteReportEvent extends ReportEvent {
  final String reportId;
  const DeleteReportEvent(this.reportId);
  @override
  List<Object?> get props => [reportId];
}

class ToggleCameraEvent extends ReportEvent {
  const ToggleCameraEvent();
}

class ToggleLocationEvent extends ReportEvent {
  const ToggleLocationEvent();
}

class ToggleStorageEvent extends ReportEvent {
  const ToggleStorageEvent();
}

class SiteLocationSelected extends ReportEvent {
  final String value;
  const SiteLocationSelected(this.value);
  @override
  List<Object?> get props => [value];
}

class NotesChanged extends ReportEvent {
  final String value;
  const NotesChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PhotoCaptured extends ReportEvent {
  final String path;
  const PhotoCaptured(this.path);
  @override
  List<Object?> get props => [path];
}

class CurrentLocationRequested extends ReportEvent {
  const CurrentLocationRequested();
}

class SaveDraftPressed extends ReportEvent {
  final Draftmodel draft;
  const SaveDraftPressed(this.draft);
  @override
  List<Object?> get props => [draft];
}

class SaveAndExportPressed extends ReportEvent {
  final ReportModel report;
  const SaveAndExportPressed(this.report);
  @override
  List<Object?> get props => [report];
}

class PhotoRemoveEvent extends ReportEvent {
  final String path;
  const PhotoRemoveEvent(this.path);
  @override
  List<Object?> get props => [path];
}

// Làm mới Form
class ReportSubmittedResetFormEvent extends ReportEvent {
  const ReportSubmittedResetFormEvent();
}

class LoadDraftIntoForm extends ReportEvent {
  final Draftmodel draft;
  const LoadDraftIntoForm(this.draft);
  @override
  List<Object?> get props => [draft];
}

// Chỉnh sửa thông tin bản nháp
class EditDraftEvent extends ReportEvent {
  final Draftmodel draft;
  const EditDraftEvent(this.draft);
  @override
  List<Object?> get props => [draft];
}

// Xóa bản nháp
class DeleteDraftEvent extends ReportEvent {
  final String draftId;
  const DeleteDraftEvent(this.draftId);

  @override
  List<Object?> get props => [];
}

// Save draft => Chuyển draft model sang report model
// Xóa draft và thêm report

class ConvertDraftToReportEvent extends ReportEvent {
  final Draftmodel draft;
  const ConvertDraftToReportEvent(this.draft);
  @override
  List<Object?> get props => [draft];
}

// Search report
class SearchReportEvent extends ReportEvent {
  final String key;
  const SearchReportEvent(this.key);

  @override
  List<Object?> get props => [];
}

// Kiểm tra lại các quyền sau khi openSettings
class ReCheckPermissionEvent extends ReportEvent {
  const ReCheckPermissionEvent();
}
