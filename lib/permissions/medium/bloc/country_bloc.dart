import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterpractisetasks/permissions/medium/bloc/country_event.dart';
import 'package:flutterpractisetasks/permissions/medium/bloc/country_state.dart';
import 'package:flutterpractisetasks/permissions/medium/repository/country_repo.dart';
import 'package:flutterpractisetasks/permissions/medium/service/csv_service.dart';
import 'package:flutterpractisetasks/permissions/medium/service/file_storage_service.dart';
import 'package:flutterpractisetasks/permissions/medium/service/storagepermission_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class CountryBloc extends Bloc<CountryEvent, CountryState> {
  CountryBloc() : super(CountryInitial()) {
    on<FetchCountryEvent>(_onFetchCountries);
    on<RefreshCountryEvent>(_onRefreshCountries);
    on<ExportCsvEvent>(_onExportCsv);
    on<RequestStoragePermissionEvent>(_onRequestStoragePermission);
    on<ShareExportedFileEvent>(_onShareExportedFile);
    on<ApplyFilterEvent>(_onApplyFilter);
  }

  Future<void> _onFetchCountries(
    FetchCountryEvent event,
    Emitter<CountryState> emit,
  ) async {
    emit(CountryLoading());
    try {
      final countries = await CountryRepository.getCountry();
      emit(
        CountryLoadSuccess(
          allCountries: countries,
          countries: countries,
          actionMessage: "Tải danh sách thành công!",
        ),
      );
    } catch (e) {
      emit(
        CountryLoadFailure(
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRefreshCountries(
    RefreshCountryEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is! CountryLoadSuccess) {
      add(FetchCountryEvent());
      return;
    }
    final current = state as CountryLoadSuccess;
    try {
      final countries = await CountryRepository.getCountry();
      // Re-apply filter
      final f = current.filter;
      final filtered = countries.where((c) {
        final matchKeyword =
            f.keyword.isEmpty ||
            c.name.toLowerCase().contains(f.keyword.toLowerCase());
        final matchMin =
            f.minPopulation == null || c.population >= f.minPopulation!;
        final matchMax =
            f.maxPopulation == null || c.population <= f.maxPopulation!;
        final matchSide =
            f.drivingSide == null || c.driving_side == f.drivingSide;
        return matchKeyword && matchMin && matchMax && matchSide;
      }).toList();

      emit(
        CountryLoadSuccess(
          allCountries: countries,
          countries: filtered,
          filter: f,
          actionMessage: "Tải lại danh sách thành công!",
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          actionMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onExportCsv(
    ExportCsvEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is! CountryLoadSuccess) return;
    final current = state as CountryLoadSuccess;

    if (current.isExporting) return; // Prevent concurrent exports

    final exportList = event.exportAll
        ? current.allCountries
        : current.countries;
    if (exportList.isEmpty) {
      emit(current.copyWith(actionMessage: 'Không có dữ liệu để xuất!'));
      return;
    }

    emit(current.copyWith(isExporting: true, isExportingAll: event.exportAll));

    try {
      final csvString = CsvService().toCsvRows(exportList);
      final String result = await FileStorageService().exportCountriesToCsv(
        csvString,
      );

      // We don't have a reliable way to check if it was reused from the result path alone,
      // but FileStorageService returns the same path if the file exists and is identical.
      // We can just say it was exported.

      emit(
        current.copyWith(
          isExporting: false,
          actionMessage: 'Xuất file thành công!',
          isSuccess: true,
          exportPath: result,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isExporting: false,
          actionMessage: e.toString().replaceFirst('Exception: ', ''),
          isSuccess: false,
        ),
      );
      debugPrint('Lỗi xuất file: $e');
    }
  }

  Future<void> _onRequestStoragePermission(
    RequestStoragePermissionEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is! CountryLoadSuccess) return;
    final current = state as CountryLoadSuccess;

    try {
      final PermissionStatus result = await StorageService()
          .requestPermission();

      if (result.isGranted) {
        emit(
          current.copyWith(
            isPermissionGranted: true,
            actionMessage: 'Đã cấp quyền truy cập bộ nhớ!',
          ),
        );
      } else {
        if (result.isDenied) {
          emit(
            current.copyWith(
              isPermissionGranted: false,
              actionMessage: 'Bạn cần cấp quyền để tiếp tục.',
            ),
          );
        } else {
          emit(
            current.copyWith(
              isPermissionGranted: false,
              actionMessage:
                  'Quyền bị từ chối vĩnh viễn. Vui lòng bật lại trong Cài đặt.',
              isSuccess: false,
            ),
          );
          await openAppSettings();
        }
      }
    } catch (e) {
      emit(current.copyWith(actionMessage: 'Lỗi xử lý quyền: $e'));
    }
  }

  Future<void> _onShareExportedFile(
    ShareExportedFileEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is! CountryLoadSuccess) return;
    final current = state as CountryLoadSuccess;

    try {
      await FileStorageService().shareFile(event.filePath);
    } catch (e) {
      debugPrint('Lỗi chia sẻ file: $e');
      emit(
        current.copyWith(
          actionMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onApplyFilter(
    ApplyFilterEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is! CountryLoadSuccess) return;
    final current = state as CountryLoadSuccess;
    final f = event.filter;

    final filtered = current.allCountries.where((c) {
      final matchKeyword =
          f.keyword.isEmpty ||
          c.name.toLowerCase().contains(f.keyword.toLowerCase());

      final matchMin =
          f.minPopulation == null || c.population >= f.minPopulation!;

      final matchMax =
          f.maxPopulation == null || c.population <= f.maxPopulation!;

      final matchSide =
          f.drivingSide == null || c.driving_side == f.drivingSide;

      return matchKeyword && matchMin && matchMax && matchSide;
    }).toList();
    emit(current.copyWith(countries: filtered, filter: f, actionMessage: null));
  }
}
