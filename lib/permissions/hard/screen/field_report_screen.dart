import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/image/image_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/image/image_event.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/image/image_state.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_event.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_state.dart';
import 'package:flutterpractisetasks/permissions/hard/core/keys/app_key.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/banner/appbanner.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/dialog/dialog.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/location_section.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/permission_dialog.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/permissioncard.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/photo_section.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/reportdetails_section.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/validator/validated_section_wrapper.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/weather_section.dart';
import 'package:flutterpractisetasks/permissions/hard/models/draftmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/permissionmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/report_details_screen.dart';
import 'package:flutterpractisetasks/permissions/hard/validators/report_validator.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../core/widgets/notes_section.dart';

class FieldReportScreen extends StatefulWidget {
  final Draftmodel? editingDraft;
  const FieldReportScreen({super.key, this.editingDraft});

  @override
  State<FieldReportScreen> createState() => _FieldReportScreenState();
}

class _FieldReportScreenState extends State<FieldReportScreen>
    with WidgetsBindingObserver {
  // int _currentBottomNavIndex = 0;

  final _siteLocationController = TextEditingController();
  final _noteController = TextEditingController();

  // GlobalKey cho từng section
  final _siteLocationKey = GlobalKey();
  final _photoSectionKey = GlobalKey();
  final _gpsSectionKey = GlobalKey();

  // Kết quả validate hiện tại - mặc định rỗng ( không lỗi) khi mở màn hình
  FormValidationResult _validationResult = const FormValidationResult({});

  GlobalKey? _keyForField(String field) {
    switch (field) {
      case ReportValidator.fieldSiteLocation:
        return _siteLocationKey;
      case ReportValidator.fieldGps:
        return _gpsSectionKey;
      case ReportValidator.fieldPhoto:
        return _photoSectionKey;
      default:
        return null;
    }
  }

  bool _validateAndScrollToError(ReportState state) {
    final result = ReportValidator.validate(
      siteLocation: _siteLocationController.text,
      photoPaths: state.photoPaths,
      latitude: state.latitude,
      longitude: state.longitude,
    );

    setState(() {
      _validationResult = result;
    });

    if (!result.isValid) {
      final key = _keyForField(result.firstErrorField!);
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1, // scroll để phần tử lỗi nằm gần đầu vùng nhìn thấy
        );
      }
    }

    return result.isValid;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.editingDraft != null) {
      context.read<ReportBloc>().add(LoadDraftIntoForm(widget.editingDraft!));

      _siteLocationController.text = widget.editingDraft!.siteLocation ?? '';
      _noteController.text = widget.editingDraft!.notes ?? '';
    } else {
      context.read<ReportBloc>().add(const HomeScreenOpened());
    }
  }

  @override
  void dispose() {
    _siteLocationController.dispose();
    _noteController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-recheck lại quyền sau khi từ setting về
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('App lifecycle changed: $state');

    if (state == AppLifecycleState.resumed) {
      // App vừa quay lại foreground  (có thể vừa từ Settings quay về)
      context.read<ReportBloc>().add(const ReCheckPermissionEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dùng multi bloc listener để lắng nghe 2 bloc cùng lúc
    return MultiBlocListener(
      listeners: [
        // lắng nghe khi user điền thông tin vào trường thiếu
        BlocListener<ReportBloc, ReportState>(
          listenWhen: (previous, current) =>
              previous.photoPaths.length != current.photoPaths.length ||
              previous.latitude != current.latitude ||
              previous.longitude != current.longitude,
          listener: (context, state) {
            setState(() {
              if (state.photoPaths.isNotEmpty) {
                _validationResult = _validationResult.clearField(
                  ReportValidator.fieldPhoto,
                );
              }
              if (state.latitude != null && state.longitude != null) {
                _validationResult = _validationResult.clearField(
                  ReportValidator.fieldGps,
                );
              }
            });
          },
        ),
        BlocListener<ReportBloc, ReportState>(
          listener: (context, state) {
            if (state.actionMessage != null) {
              if (state.saveType == SaveActionType.draftSaved ||
                  state.saveType == SaveActionType.reportExported) {
                if (state.exportPath != null) {
                  AppBanner.showAction(
                    context,
                    message: state.actionMessage!,
                    actionLabel: 'Mở file',
                    onActionPressed: () {
                      OpenFilex.open(state.exportPath!);
                    },
                  );

                  setState(() {
                    _validationResult = const FormValidationResult({});
                  });
                }
                _noteController.clear();
                _siteLocationController.clear();
                context.read<ReportBloc>().add(
                  const ReportSubmittedResetFormEvent(),
                );
              }

              Apptoast.show(state.actionMessage!);
            }
          },
        ),

        // Dùng sau khi xin cấp quyền camera thành công
        // BlocListener<ReportBloc, ReportState>(
        //   listenWhen: (previous, current) =>
        //       previous.cameraPermission != current.cameraPermission,
        //   listener: (context, state) {
        //     if (state.cameraPermission == PermissionState.granted) {
        //       context.read<ImageBloc>().add(
        //         PickImageRequested(ImageSource.camera),
        //       );
        //     }
        //   },
        // ),

        // Lắng nghe ImageBloc: khi chọn ảnh thành công thì đẩy ảnh qua Report bloc
        BlocListener<ImageBloc, ImageState>(
          listener: (context, imageState) {
            // Chặn: nếu route này không phải route đang hiển thị trên cùng, bỏ qua
            if (!ModalRoute.of(context)!.isCurrent) return;
            if (imageState is ImagePickedSuccess) {
              final newImagePath = imageState.mediaFileList.first.path;

              // Bắn event cập nhật ảnh vào reportbloc để hiển thị lên UI chính
              context.read<ReportBloc>().add(PhotoCaptured(newImagePath));
            } else if (imageState is ImagePickedFailure) {
              Apptoast.show(imageState.message);
            }
          },
        ),

        // Cái này dùng khi mà save/ edit xong thì điều hướng sang trang chi tiết
        // chứ ko ở lại trang thông tin đó  nữa
        // Ráng nhớ nha
        BlocListener<ReportBloc, ReportState>(
          listenWhen: (previous, current) =>
              current.lastSavedAt != null &&
              previous.lastSavedAt != current.lastSavedAt,

          listener: (context, state) {
            if (widget.editingDraft == null) return;

            final reportBloc = context.read<ReportBloc>();
            final imageBloc = context.read<ImageBloc>();

            if (state.saveType == SaveActionType.reportExported) {
              // Chuyển từ draft sang report thành công: Về thẳng list reports
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => MultiBlocProvider(
              //       providers: [
              //         BlocProvider.value(value: reportBloc),
              //         BlocProvider.value(value: imageBloc),
              //       ],
              //       child: const ReportlistScreen(),
              //     ),
              //   ),
              //   (route) =>
              //       false, // Xóa toàn bộ route cũ edit, detail khỏi stack
              // );
              mainShellKey.currentState?.changeTab(1); // 1 = index tab Reports
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (state.saveType == SaveActionType.draftSaved) {
              final draft = _buildDraftFromCurrentState(state);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: reportBloc),
                      BlocProvider.value(value: imageBloc),
                    ],
                    child: ReportDetailScreen(
                      draft: draft,
                      // photoPaths: draft.photoUrls ?? [],
                      // reportId: widget.editingDraft == null
                      //     ? state.reportId
                      //     : draft.draftId!,
                      // siteLocation: _siteLocationController.text,
                      // notes: _noteController.text,

                      // dateTime: Formatdatetime().formatDateTime(
                      //   state.createdAt!,
                      // ),
                      // status: widget.editingDraft!.status!,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          final bool allPermissionsGranted =
              state.cameraPermission == PermissionState.granted &&
              state.locationPermission == PermissionState.granted &&
              state.storagePermission == PermissionState.granted;
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: const Color(
                0xFF070B13,
              ), // Nền tối siêu đẹp, cực chuẩn tương phản
              appBar: AppBar(
                backgroundColor: const Color(0xFF070B13),
                elevation: 0,
                leading: widget.editingDraft == null
                    ? IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {},
                      )
                    : IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () async {
                          final result = await CustomDialog().showCusTomDialog(
                            context,
                            title: 'Cảnh báo',
                            content: 'Thoát mà không lưu thay đổi!',
                            button1: 'Tiếp tục thoát',
                            button2: 'Lưu thay đổi',
                          );
                          if (result == DialogResult.cancel) {
                            context.read<ReportBloc>().add(
                              const ReportSubmittedResetFormEvent(),
                            );
                            Navigator.pop(context);
                          } else if (result == DialogResult.confirm) {
                            context.read<ReportBloc>().add(
                              EditDraftEvent(
                                _buildDraftFromCurrentState(state),
                              ),
                            );
                          }
                        },
                      ),
                title: Text(
                  widget.editingDraft == null
                      ? 'Field Report Toolkit'
                      : 'Edit Draft',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION: Permissions Status ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Permissions Status',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: allPermissionsGranted
                                ? Color(0xFF10B981).withOpacity(0.15)
                                : Color(0xFFEF4444).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            allPermissionsGranted ? 'All set' : 'Incomplete',
                            style: TextStyle(
                              color: allPermissionsGranted
                                  ? Color(0xFF10B981)
                                  : Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PermissionCard(
                          label: 'Camera',
                          status: state.cameraPermission,
                          icon: Icons.camera_alt,
                        ),
                        PermissionCard(
                          label: 'Location',
                          status: state.locationPermission,
                          icon: Icons.location_on,
                        ),
                        PermissionCard(
                          label: 'Storage',
                          status: state.storagePermission,
                          icon: Icons.folder,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION: Report Details ---
                    ValidatedSectionWrapper(
                      sectionKey: _siteLocationKey,
                      errorText: _validationResult.errorFor(
                        ReportValidator.fieldSiteLocation,
                      ),
                      child: ReportDetailsSection(
                        reportId: state.reportId,
                        controller: _siteLocationController,
                        dateTime: state.createdAt.toString(),
                        onSiteLocationChange: (value) {
                          context.read<ReportBloc>().add(
                            SiteLocationSelected(value),
                          );
                          if (value.trim().isNotEmpty &&
                              _validationResult.errorFor(
                                    ReportValidator.fieldSiteLocation,
                                  ) !=
                                  null) {
                            setState(() {
                              _validationResult = _validationResult.clearField(
                                ReportValidator.fieldSiteLocation,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION: Photo Evidence ---
                    ValidatedSectionWrapper(
                      sectionKey: _photoSectionKey,
                      errorText: _validationResult.errorFor(
                        ReportValidator.fieldPhoto,
                      ),
                      child: PhotoSection(
                        photoUrls: state.photoPaths,
                        photoCount: state.photoCount,
                        onTakePhotoPressed: () {
                          // Sẽ xử lý bằng Bloc trigger camera event sau này

                          if (state.cameraPermission ==
                              PermissionState.granted) {
                            context.read<ImageBloc>().add(
                              PickImageRequested(ImageSource.camera),
                            );
                          } else {
                            if (state.cameraPermission ==
                                    PermissionState.denied ||
                                state.cameraPermission ==
                                    PermissionState.initial) {
                              context.read<ReportBloc>().add(
                                ToggleCameraEvent(),
                              );
                            } else {
                              PermissionDialogUtils.showSettingsDialog(
                                context: context,
                                title: 'Yêu cầu quyền Máy ảnh',
                                content:
                                    'Bạn đã tắt quyền truy cập Máy ảnh. Để tiếp tục quét mã, vui lòng mở Cài đặt, chọn "Quyền" và bật "Máy ảnh".',
                              );
                            }
                          }
                        },
                        onRemovePhotoPressed: (path) {
                          context.read<ReportBloc>().add(
                            PhotoRemoveEvent(path),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION: Current Location (GPS) ---
                    ValidatedSectionWrapper(
                      sectionKey: _gpsSectionKey,
                      errorText: _validationResult.errorFor(
                        ReportValidator.fieldGps,
                      ),
                      child: GpsSection(
                        latitude: state.latitude ?? 0,
                        longitude: state.longitude ?? 0,
                        accuracy: state.accuracy ?? 0,
                        onTap: () {
                          if (state.locationPermission ==
                              PermissionState.granted) {
                            context.read<ReportBloc>().add(
                              CurrentLocationRequested(),
                            );
                          } else {
                            if (state.locationPermission ==
                                    PermissionState.denied ||
                                state.locationPermission ==
                                    PermissionState.initial) {
                              context.read<ReportBloc>().add(
                                ToggleLocationEvent(),
                              );
                            } else {
                              PermissionDialogUtils.showSettingsDialog(
                                context: context,
                                title: 'Yêu cầu quyền Vị trí',
                                content:
                                    'Bạn đã tắt quyền truy cập Vị trí. Để tiếp tục quét mã, vui lòng mở Cài đặt, chọn "Quyền" và bật "Vị trí".',
                              );
                            }
                          }
                        },
                        // => _handlePermissionTap(
                        //   context,
                        //   state.locationPermission,
                        //   ToggleLocationEvent(),
                        // ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION: Weather ---
                    WeatherCountrySection(
                      status: state.status,
                      weatherDesc: state.weatherDesc,
                      temp: state.temp,
                      countryGuess: state.countryGuess,
                      icon: state.icon,
                      flagUrl: state.flagUrl,
                    ),
                    // --- SECTION: Notes ---
                    NotesSection(noteController: _noteController),
                    const SizedBox(height: 24),

                    // --- SECTION: Bottom Action Buttons ---
                    Row(
                      children: [
                        // CommonOutlineButton(
                        //   content: 'Save Draft',
                        //   colorButton: Colors.grey,
                        //   width: 50,
                        // ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: state.saveStatus == SaveStatus.saving
                                ? null
                                : () {
                                    final draft = Draftmodel(
                                      permissions: [
                                        Permissionmodel(
                                          name: state.cameraPermission.name,
                                          isGranted:
                                              state.cameraPermission ==
                                              PermissionState.granted,
                                        ),
                                        Permissionmodel(
                                          name: state.locationPermission.name,
                                          isGranted:
                                              state.locationPermission ==
                                              PermissionState.granted,
                                        ),
                                        Permissionmodel(
                                          name: state.storagePermission.name,
                                          isGranted:
                                              state.storagePermission ==
                                              PermissionState.granted,
                                        ),
                                      ],
                                      draftId: widget.editingDraft == null
                                          ? state.reportId
                                          : widget.editingDraft!.draftId,
                                      siteLocation:
                                          _siteLocationController.text,
                                      dateTime: state.createdAt,
                                      photoUrls: state.photoPaths,
                                      photoCount: state.photoCount,
                                      longitude: state.longitude,
                                      latitude: state.latitude,
                                      accuracy: state.accuracy,
                                      notes: _noteController.text,
                                      status: ReportStatus.draft,
                                      temp: state.temp,
                                      iconWeather: state.icon,
                                      flagUrl: state.flagUrl,
                                      country: state.countryGuess,
                                      weatherDesc: state.weatherDesc,
                                    );
                                    widget.editingDraft == null
                                        ? context.read<ReportBloc>().add(
                                            SaveDraftPressed(draft),
                                          )
                                        : context.read<ReportBloc>().add(
                                            EditDraftEvent(draft),
                                          );
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF1E293B)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: state.saveStatus == SaveStatus.saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save Draft',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (state.storagePermission ==
                                  PermissionState.granted) {
                                if (!_validateAndScrollToError(state)) {
                                  Apptoast.show(
                                    'Vui lòng điền đầy đủ thông tin bắt buộc',
                                  );
                                  return;
                                }

                                widget.editingDraft == null
                                    ? () {
                                        final report = ReportModel(
                                          permissions: [
                                            Permissionmodel(
                                              name: state.cameraPermission.name,
                                              isGranted:
                                                  state.cameraPermission ==
                                                  PermissionState.granted,
                                            ),

                                            Permissionmodel(
                                              name:
                                                  state.locationPermission.name,
                                              isGranted:
                                                  state.locationPermission ==
                                                  PermissionState.granted,
                                            ),

                                            Permissionmodel(
                                              name:
                                                  state.storagePermission.name,
                                              isGranted:
                                                  state.storagePermission ==
                                                  PermissionState.granted,
                                            ),
                                          ],
                                          reportId: state.reportId,
                                          siteLocation:
                                              _siteLocationController.text,
                                          dateTime: state.createdAt!,
                                          photoUrls: state.photoPaths,
                                          photoCount: state.photoCount,
                                          longitude: state.longitude!,
                                          latitude: state.latitude!,
                                          accuracy: state.accuracy ?? 8,
                                          notes: _noteController.text,
                                          status: ReportStatus.submitted,
                                          weatherDesc: state.weatherDesc!,
                                          temp: state.temp ?? 0,
                                          iconWeather: state.icon!,
                                          country: state.countryGuess!,
                                          flagUrl: state.flagUrl!,
                                        );
                                        context.read<ReportBloc>().add(
                                          SaveAndExportPressed(report),
                                        );
                                      }
                                    : context.read<ReportBloc>().add(
                                        ConvertDraftToReportEvent(
                                          _buildDraftFromCurrentState(state),
                                        ),
                                      );
                              } else {
                                if (state.storagePermission ==
                                        PermissionState.denied ||
                                    state.storagePermission ==
                                        PermissionState.initial) {
                                  context.read<ReportBloc>().add(
                                    ToggleStorageEvent(),
                                  );
                                } else {
                                  PermissionDialogUtils.showSettingsDialog(
                                    context: context,
                                    title: 'Yêu cầu cấp quyền lưu trữ',
                                    content:
                                        'Bạn đã tắt quyền lưu trữ. Để tiếp tục quét mã, vui lòng mở Cài đặt, chọn "Quyền" và bật "Vị trí".',
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Save & Export',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // bottomNavigationBar: BottomNavigationBar(
              //   backgroundColor: const Color(0xFF0F172A),
              //   type: BottomNavigationBarType.fixed,
              //   selectedItemColor: const Color(0xFF2563EB),
              //   unselectedItemColor: Colors.grey,
              //   selectedFontSize: 11,
              //   unselectedFontSize: 11,
              //   currentIndex: _currentBottomNavIndex,
              //   onTap: (index) {
              //     setState(() {
              //       _currentBottomNavIndex = index;
              //     });
              //   },
              //   items: const [
              //     BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              //     BottomNavigationBarItem(
              //       icon: Icon(Icons.assignment),
              //       label: 'Reports',
              //     ),
              //     BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
              //     BottomNavigationBarItem(
              //       icon: Icon(Icons.settings),
              //       label: 'Settings',
              //     ),
              //   ],
              // ),
            ),
          );
        },
      ),
    );
  }

  Draftmodel _buildDraftFromCurrentState(ReportState state) {
    return Draftmodel(
      draftId: widget.editingDraft == null
          ? state.reportId
          : widget.editingDraft!.draftId,
      permissions: [
        Permissionmodel(
          name: state.cameraPermission.name,
          isGranted: state.cameraPermission == PermissionState.granted,
        ),
        Permissionmodel(
          name: state.locationPermission.name,
          isGranted: state.locationPermission == PermissionState.granted,
        ),
        Permissionmodel(
          name: state.storagePermission.name,
          isGranted: state.storagePermission == PermissionState.granted,
        ),
      ],
      siteLocation: _siteLocationController.text,
      dateTime: state.createdAt,
      photoUrls: state.photoPaths,
      photoCount: state.photoCount,
      longitude: state.longitude,
      latitude: state.latitude,
      accuracy: state.accuracy,
      notes: _noteController.text,
      status: ReportStatus.draft,
      temp: state.temp,
      iconWeather: state.icon,
      flagUrl: state.flagUrl,
      country: state.countryGuess,
      weatherDesc: state.weatherDesc,
    );
  }
}
