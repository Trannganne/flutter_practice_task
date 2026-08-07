import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/permissions/medium/model/country.dart';
import 'package:flutterpractisetasks/permissions/medium/model/country_filter.dart';

sealed class CountryState extends Equatable {
  const CountryState();

  @override
  List<Object?> get props => [];
}

class CountryInitial extends CountryState {}

class CountryLoading extends CountryState {}

class _Unset {
  const _Unset();
}

const _unset = _Unset();

class CountryLoadSuccess extends CountryState {
  final List<Country> allCountries;
  final List<Country> countries;
  final CountryFilter filter;
  final String? actionMessage;
  final bool isPermissionGranted;
  final bool? isSuccess;
  final String? exportPath;

  CountryLoadSuccess({
    required this.allCountries,
    required this.countries,

    this.actionMessage,
    this.isPermissionGranted = false,
    this.isSuccess,
    this.exportPath,
    this.filter = const CountryFilter(),
  });

  CountryLoadSuccess copyWith({
    List<Country>? allCountries,
    List<Country>? countries,
    Object? actionMessage = _unset,
    bool? isPermissionGranted,
    bool? isSuccess,
    String? exportPath,
    CountryFilter? filter,
  }) {
    return CountryLoadSuccess(
      allCountries: allCountries ?? this.allCountries,
      countries: countries ?? this.countries,
      actionMessage: identical(actionMessage, _unset)
          ? this.actionMessage
          : actionMessage as String?,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isSuccess: isSuccess ?? this.isSuccess,
      exportPath: exportPath ?? this.exportPath,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
    allCountries,
    countries,
    filter,
    actionMessage,
    isPermissionGranted,
    isSuccess,
    exportPath,
  ];
}

class CountryLoadFailure extends CountryState {
  final String message;

  const CountryLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
