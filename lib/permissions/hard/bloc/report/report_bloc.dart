import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/weather_api.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_event.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_state.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/service/GPSservice.dart';
import 'package:flutterpractisetasks/permissions/hard/service/permission.dart';
import 'package:flutterpractisetasks/permissions/hard/service/sharepreferences.dart';
import 'package:flutterpractisetasks/permissions/medium/repository/country_repo.dart';
import 'package:flutterpractisetasks/permissions/medium/service/csv_service.dart';
import 'package:flutterpractisetasks/permissions/medium/service/file_storage_service.dart';
import 'package:flutterpractisetasks/permissions/medium/service/storagepermission_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Triển khai thêm go router

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  Timer? _searchDebounce;

  ReportBloc() : super(const ReportState()) {
    on<HomeScreenOpened>(_onHomeScreenOpened);
    on<LoadReportEvent>(_onLoadReport);
    on<ToggleCameraEvent>(_onToggleCamera);
    on<ToggleLocationEvent>(_onToggleLocation);
    on<ToggleStorageEvent>(_onToggleStorage);
    on<CurrentLocationRequested>(_onCurrentLocationRequested);
    on<PhotoCaptured>(_onPhotoCaptured);
    on<SiteLocationSelected>(
      (e, emit) =>
          emit(state.copyWith(siteLocation: e.value, actionMessage: null)),
    );
    on<NotesChanged>((e, emit) => emit(state.copyWith(notes: e.value)));
    on<SaveDraftPressed>(_onSaveDraft);
    on<SaveAndExportPressed>(_onSaveAndExportReport);
    on<PhotoRemoveEvent>(_onPhotoRemove);
    on<LoadDraftsEvent>(_onLoadDrafts);
    on<ReportSubmittedResetFormEvent>(_onResetForm);
    on<LoadDraftIntoForm>(_onLoadDraftDetail);
    on<EditDraftEvent>(_onEditDraft);
    on<ConvertDraftToReportEvent>(_onConvertDraftToReport);
    on<DeleteDraftEvent>(_onDeleteDraft);
    on<DeleteReportEvent>(_onDeleteReport);
    on<SearchReportEvent>(_onSearchReport);
    on<ReCheckPermissionEvent>(_onReCheckPermission);
  }
  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> _onReCheckPermission(
    ReCheckPermissionEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      // Dùng hàm check để check lại các quyền
      final cameraStatus = await PermissionRequest().checkCameraStatus();
      final locationStatus = await PermissionRequest().checkLocationStatus();
      final storageStatus = await PermissionRequest().checkStorageaStatus();

      emit(
        state.copyWith(
          cameraPermission: _mapStatus(cameraStatus),
          locationPermission: _mapStatus(locationStatus),
          storagePermission: _mapStatus(storageStatus),
        ),
      );
    } catch (e) {}
  }

  Future<void> _onSearchReport(
    SearchReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    // Cập nhật ngay để UI phản hồi tức thì (không cần chờ debounce)
    emit(state.copyWith(searchQuery: event.key, actionMessage: null));
  }

  // Xóa 1 bản báo cáo
  Future<void> _onDeleteReport(
    DeleteReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final reports = await SharepreferencesService().getReports() ?? [];
      reports.removeWhere((r) => r.reportId == event.reportId);

      await SharepreferencesService().saveAllReports(reports);
      emit(state.copyWith(reports: reports, actionMessage: null));
    } catch (e) {
      emit(state.copyWith(actionMessage: 'Xóa lịch sử báo cáo thất bại!'));
    }
  }

  // Xóa bản nháp
  Future<void> _onDeleteDraft(
    DeleteDraftEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await SharepreferencesService().deleteDraft(event.draftId);
      final drafts = await SharepreferencesService().getDraft() ?? [];
      emit(state.copyWith(actionMessage: null, drafts: drafts));
    } catch (e) {
      emit(state.copyWith(actionMessage: 'Xóa bản nháp thất bại!'));
    }
  }

  // Cập nhật thông tin bản nháp
  Future<void> _onEditDraft(
    EditDraftEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final drafts = await SharepreferencesService().getDraft() ?? [];
      final index = drafts.indexWhere((d) => d.draftId == event.draft.draftId);

      if (index == -1) {
        emit(
          state.copyWith(actionMessage: 'Không tìm thấy bản nháp để cập nhật!'),
        );
        return;
      }
      // Cập nhật các thông tin của bản nháp mới sang bản cũ
      drafts[index] = event.draft;

      await SharepreferencesService().saveAllDaft(drafts);

      // Cập nhật lại UI

      emit(
        state.copyWith(
          drafts: drafts,
          lastSavedAt: DateTime.now(),
          saveStatus: SaveStatus.success,
          actionMessage: 'Đã cập nhật bản nháp!',
          saveType: SaveActionType.draftSaved,
        ),
      );
    } catch (e) {
      emit(state.copyWith(actionMessage: 'Cập nhật bản nháp thất bại!'));
      debugPrint('Lỗi khi cập nhật bản nháp: $e');
    }
  }

  // Chuyển từ draft sang report để lưu
  Future<void> _onConvertDraftToReport(
    ConvertDraftToReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final draft = event.draft;
      final newReport = ReportModel(
        permissions: event.draft.permissions!,
        reportId: draft.draftId!,
        siteLocation: draft.siteLocation!,
        dateTime: draft.dateTime!,
        photoUrls: draft.photoUrls!,
        photoCount: draft.photoCount!,
        longitude: draft.longitude!,
        latitude: draft.latitude!,
        notes: draft.notes!,
        status: ReportStatus.submitted,
        weatherDesc: draft.weatherDesc!,
        temp: draft.temp!,
        iconWeather: draft.iconWeather!,
        country: draft.country!,
        flagUrl: draft.flagUrl!,
      );

      // await SharepreferencesService().saveAllReports(reports);
      final saved = await _onSaveAndExport(newReport, emit);

      if (!saved) return; // Nếu không save được thì dừng việc xóa lại

      // Xóa draft trong trong danh sách drafts
      final drafts = await SharepreferencesService().getDraft() ?? [];
      drafts.removeWhere((t) => t.draftId == event.draft.draftId);

      await SharepreferencesService().saveAllDaft(drafts);
      emit(state.copyWith(drafts: drafts));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: SaveStatus.failure,
          actionMessage: 'Lưu báo cáo thất bại!',
        ),
      );
    }
  }

  // Helper dùng chung cho việc lưu và xuất
  Future<bool> _onSaveAndExport(
    ReportModel report,
    Emitter<ReportState> emit,
  ) async {
    // Lưu báo cáo hiện tại
    try {
      final success = await SharepreferencesService().saveReport(report);
      if (!success) {
        emit(
          state.copyWith(
            actionMessage: 'Bản báo cáo này đã tồn tại!',
            saveStatus: SaveStatus.failure,
          ),
        );
        return false;
      }
    } catch (e, stackTrace) {
      emit(
        state.copyWith(
          actionMessage: 'Lưu thất bại. Vui lòng thử lại!',
          saveStatus: SaveStatus.failure,
        ),
      );
      debugPrint('lưu thất bại: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }

    // Xuất báo cáo CSV
    final reports = await SharepreferencesService().getReports();
    if (reports == null || reports.isEmpty) {
      emit(
        state.copyWith(
          actionMessage: 'Đã lưu báo cáo nhưng chưa có dữ liệu để xuất!',
        ),
      );
      return false;
    }
    // Xuất file
    try {
      // Chuyển list reports sang string csv
      final String csvString = CsvService().toCsv_Hard(reports);

      // Xuất file
      // Trả về đường dẫn
      final String result = await FileStorageService().exportCountriesToCsv(
        csvString,
        'report',
      );

      emit(
        state.copyWith(
          actionMessage: 'Đã lưu và xuất báo cáo.',
          exportPath: result,
          reports: reports,
          saveType: SaveActionType.reportExported,
          lastSavedAt: DateTime.now(),
          saveStatus: SaveStatus.success,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionMessage: 'Đã lưu file nhưng xuất file thất bại: $e',
        ),
      );
      return false;
    }
  }

  Future<void> _onLoadDraftDetail(
    LoadDraftIntoForm event,
    Emitter<ReportState> emit,
  ) async {
    final draft = event.draft;
    emit(
      state.copyWith(
        reportId: draft.draftId ?? _generateReportId(),
        createdAt: draft.dateTime,
        photoPaths: draft.photoUrls ?? [],
        latitude: draft.latitude,
        longitude: draft.longitude,
        accuracy: draft.accuracy,
        weatherDesc: draft.weatherDesc,
        countryGuess: draft.country,
        flagUrl: draft.flagUrl,
        icon: draft.iconWeather,
        status: WeatherStatus.success,
        temp: draft.temp,
      ),
    );
  }

  // Làm mới form
  Future<void> _onResetForm(
    ReportSubmittedResetFormEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(
      ReportState(
        reports: state.reports,
        drafts: state.drafts,
        reportId: _generateReportId(),
        cameraPermission: state.cameraPermission,
        locationPermission: state.locationPermission,
        storagePermission: state.storagePermission,
        createdAt: DateTime.now(),
        listStatus: state.listStatus,
        saveStatus: SaveStatus.initial,
        saveType: SaveActionType.none,
        actionMessage: null,
        exportPath: null,
      ),
    );
  }

  // Sự kiện xóa 1 ảnh khi click vào
  Future<void> _onPhotoRemove(
    PhotoRemoveEvent event,
    Emitter<ReportState> emit,
  ) async {
    final newUrls = state.photoPaths.where((t) => t != event.path).toList();
    emit(state.copyWith(photoPaths: newUrls, actionMessage: null));
  }

  // Tải tất cả báo cáo
  Future<void> _onLoadReport(
    LoadReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(listStatus: ListStatus.loading));
    try {
      final reports = await SharepreferencesService().getReports();

      emit(
        state.copyWith(listStatus: ListStatus.loaded, reports: reports ?? []),
      );
    } catch (e) {
      emit(
        state.copyWith(
          listStatus: ListStatus.failure,
          actionMessage: 'Lỗi khi tải danh sách báo cáo: $e. Vui lòng thử lại!',
        ),
      );
    }
  }

  // Tải tất cả báo cáo
  Future<void> _onLoadDrafts(
    LoadDraftsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(listStatus: ListStatus.loading));
    try {
      final draft = await SharepreferencesService().getDraft();

      emit(state.copyWith(listStatus: ListStatus.loaded, drafts: draft ?? []));
    } catch (e) {
      emit(
        state.copyWith(
          listStatus: ListStatus.failure,
          actionMessage: 'Lỗi khi tải bản nháp: $e. Vui lòng thử lại!',
        ),
      );
    }
  }

  Future<void> _onSaveAndExportReport(
    SaveAndExportPressed event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await _onSaveAndExport(event.report, emit);
    } catch (e) {
      emit(state.copyWith(actionMessage: 'Lưu báo cáo thất bại: $e'));
    }
  }

  // Lưu nháp( draft)
  Future<void> _onSaveDraft(
    SaveDraftPressed event,
    Emitter<ReportState> emit,
  ) async {
    try {
      emit(state.copyWith(saveStatus: SaveStatus.saving));
      final success = await SharepreferencesService().saveDaft(event.draft);
      if (success) {
        final drafts = await SharepreferencesService().getDraft();
        emit(
          state.copyWith(
            actionMessage: 'Đã lưu bản nháp',
            saveStatus: SaveStatus.success,
            drafts: drafts,
            saveType: SaveActionType.draftSaved,
          ),
        );
      } else {
        emit(state.copyWith(actionMessage: 'Bản nháp này đã tồn tại!'));
      }
    } catch (e) {
      emit(
        state.copyWith(
          actionMessage: 'Lưu thất bại: $e',
          saveStatus: SaveStatus.failure,
        ),
      );
    }
  }

  Future<void> _onHomeScreenOpened(
    HomeScreenOpened event,
    Emitter<ReportState> emit,
  ) async {
    emit(
      state.copyWith(reportId: _generateReportId(), createdAt: DateTime.now()),
    );
  }

  Future<void> _onToggleCamera(
    ToggleCameraEvent event,
    Emitter<ReportState> emit,
  ) async {
    // final result = await PermissionRequest().cameraRequest();
    final result = await PermissionRequest().cameraRequest();

    emit(
      state.copyWith(
        cameraPermission: _mapStatus(result),
        actionMessage: 'Đã cấp quyền truy cập camera',
      ),
    );
  }

  Future<void> _onToggleLocation(
    ToggleLocationEvent event,
    Emitter<ReportState> emit,
  ) async {
    final result = await PermissionRequest().locationRequest();
    emit(
      state.copyWith(
        locationPermission: _mapStatus(result),
        actionMessage: 'Đã cấp quyền truy cập vị trí',
      ),
    );
  }

  Future<void> _onToggleStorage(
    ToggleStorageEvent event,
    Emitter<ReportState> emit,
  ) async {
    final result = await StorageService().requestPermission();
    emit(
      state.copyWith(
        storagePermission: _mapStatus(result),
        actionMessage: 'Đã cấp quyền lưu trữ',
      ),
    );
  }

  // Khi chụp, emit các đường dẫn và show preview
  Future<void> _onPhotoCaptured(
    PhotoCaptured event,
    Emitter<ReportState> emit,
  ) async {
    debugPrint('Đường dẫn ảnh mới đó nha: ${event.path}');
    final updatedPaths = [...state.photoPaths, event.path];
    emit(state.copyWith(photoPaths: updatedPaths));
  }

  // còn thiếu: _onLoadReport, _onCurrentLocationRequested
  // _onSaveDraft, _onSaveAndExport
  // theo đúng khuôn: emit loading → try gọi service → emit success/failure

  Future<void> _onCurrentLocationRequested(
    CurrentLocationRequested event,
    Emitter<ReportState> emit,
  ) async {
    // Trạng thái đang tải thời tiết
    emit(state.copyWith(status: WeatherStatus.loading));
    late final Position position;
    try {
      // Lấy vị trí: Bắt buộc lấy được không phụ thuộc mạng á nha
      position = await Gpsservice().getCurrentLocation();
    } catch (e) {
      emit(
        state.copyWith(
          actionMessage: 'Không xác định được vị trí GPS: $e',
          status: WeatherStatus.failure,
        ),
      );
      return; // Không có GPS thì không làm tiếp được nên dừng ở đây
    }
    final lat = position.latitude;
    final long = position.longitude;

    // Muốn giao diện được cập nhật thì emit ngay lập tức
    // Dù phần sau mạng lỗi cũng không ảnh hưởng
    emit(
      state.copyWith(
        latitude: lat,
        longitude: long,
        accuracy: position.accuracy,
      ),
    );
    // Kiểm tra kết nối mạng
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasNetword = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasNetword) {
      emit(
        state.copyWith(
          status: WeatherStatus.failure,
          weatherDesc: 'Không xác định',
          countryGuess: 'Không xác định',
          actionMessage:
              'Không có kết nối mạng. Vui lòng kiểm tra lại kết nối!',
        ),
      );
    }
    // Thời tiết
    String? weatherDesc;
    double? temp;
    String? icon;
    bool weatherFailed = false;
    try {
      // Lấy thời tiết tại thời điểm gần nhất
      final weather = await WeatherApi.getForecast(lat, long);
      weatherDesc = weather.current.description;
      temp = weather.current.temp;
      icon = weather.current.icon;
    } catch (e) {
      weatherFailed = true;
      debugPrint('Lấy thời tiết thất bại: $e. Vui lòng thử lại!');
    }

    // Dự đoán đất nước
    // Lấy code dựa vào lat/ long trước nè
    String? countryGuess;
    String? flag;
    bool countryFailed = false;

    try {
      final code = await Gpsservice().getCoutryCode(lat, long);

      final country = await CountryRepository.getCountryByCode(code!);
      countryGuess = country.officialName;
      flag = country.flagUrl;
    } catch (e) {
      countryFailed = true;
      debugPrint('Không xác định được quốc gia: $e. Vui lòng thử lại!');
    }

    String message;
    if (!weatherFailed && !countryFailed) {
      message = 'Đã lấy được vị trí, thời tiết và quốc gia thành công!';
    } else if (weatherFailed && !countryFailed) {
      message = 'Đã lấy được vị trí và quốc gia. Lấy thời tiết thất bại';
    } else if (!weatherFailed && countryFailed) {
      message = 'Đã lấy được vị trí và thời tiết. Lấy quốc gia thất bại';
    } else {
      message = 'Đã lấy được vị trí. Lấy thời tiết và quốc gia thất bại';
    }

    emit(
      state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        temp: temp,
        weatherDesc: weatherDesc,
        status: WeatherStatus.success,
        icon: icon,
        countryGuess: countryGuess,
        flagUrl: flag,
        actionMessage: message,
      ),
    );
  }

  PermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted) {
      return PermissionState.granted;
    } else {
      if (status.isDenied) {
        return PermissionState.denied;
      } else {
        if (status.isPermanentlyDenied) {
          return PermissionState.permanentlyDenied;
        }
        return PermissionState.initial;
      }
    }
  }

  String _generateReportId() {
    final now = DateTime.now();
    String p2(int n) => n.toString().padLeft(2, '0');
    return 'RPT-${now.year}-${p2(now.month)}${p2(now.day)}-${p2(now.minute)}${p2(now.second)}';
  }
}
