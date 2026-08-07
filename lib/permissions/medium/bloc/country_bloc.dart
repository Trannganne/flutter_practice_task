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
    on<ExportCsvEvent>(_onExportCsv);
    on<RequestStoragePermissionEvent>(_onRequestStoragePermission);
    on<OpenExportedFileEvent>(_onOpenExportedFile);
    on<ApplyFilterEvent>(_onApplyFilter);
  }

  Future<void> _onFetchCountries(
    FetchCountryEvent event,
    Emitter<CountryState> emit,
  ) async {
    emit(CountryLoading());
    try {
      final countries = await CountryRepository.getCountry();
      print('Cờ nè: ${countries[1].flagUrl}');
      emit(
        CountryLoadSuccess(
          allCountries: countries,
          countries: countries,
          actionMessage: "Tải danh sách thành công!",
        ),
      );
    } catch (e) {
      emit(CountryLoadFailure(message: 'Tải countries thất bại: $e'));
    }
  }

  Future<void> _onExportCsv(
    ExportCsvEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is! CountryLoadSuccess) return;
    final current = state as CountryLoadSuccess;
    try {
      // Chuyển list Country sang string csv
      final csvString = await CsvService().toCsvRows(current.countries);

      // Xuất file
      // Trả về đường dẫn
      final String result = await FileStorageService().exportCountriesToCsv(
        csvString,
        'countries',
      );

      emit(
        current.copyWith(
          countries: current.countries,
          actionMessage: 'Xuất file thành công!',
          isSuccess: true,
          exportPath: result,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          countries: current.countries,
          actionMessage: 'Xuất file csv thất bại!',
          isSuccess: false,
        ),
      );
      debugPrint('Lỗi: $e');
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
      emit(
        current.copyWith(
          countries: current.countries,
          actionMessage: 'Lỗi xử lý quyền: $e',
        ),
      );
    }
  }

  Future<void> _onOpenExportedFile(
    OpenExportedFileEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is! CountryLoadSuccess) return;
    final current = state as CountryLoadSuccess;

    try {
      final result = await FileStorageService().openFile(event.filePath);

      if (result.type != ResultType.done) {
        emit(
          current.copyWith(
            countries: current.countries,
            actionMessage: 'Mở file thất bại! Vui lòng kiểm tra lại đường dẫn.',
            exportPath: current.exportPath,
          ),
        );
      }
    } catch (e) {
      debugPrint('Lỗi mở file: $e');
      ;
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
