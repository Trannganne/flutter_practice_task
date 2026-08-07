import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/image/image_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_event.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_state.dart';
import 'package:flutterpractisetasks/permissions/hard/core/format/formatdatetime.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/weather_section.dart';
import 'package:flutterpractisetasks/permissions/hard/models/draftmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/report_mapper.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/field_report_screen.dart';
import 'package:flutterpractisetasks/permissions/medium/bloc/country_event.dart';

class ReportDetailScreen extends StatelessWidget {
  final Draftmodel? draft;
  final ReportModel? report;
  // final String reportId;
  // final String siteLocation;
  // final String dateTime;
  // final ReportStatus status; // 'Draft' hoặc 'Submitted' / 'Exported'
  // final String? notes;
  // final List<String> photoPaths;

  const ReportDetailScreen({
    super.key,
    this.draft,
    this.report,
    // required this.reportId,
    // required this.siteLocation,
    // required this.dateTime,
    // required this.status,
    // this.notes,
    // this.photoPaths = const [],
  });

  bool get isDraft => draft != null;

  String get reportId => draft?.cardTitle ?? report!.cardTitle;
  String get siteLocation => draft?.cardLocation ?? report!.cardLocation;
  DateTime get dateTime => draft?.cardDate ?? report!.cardDate;
  ReportStatus get status => draft?.cardStatus ?? report!.cardStatus;
  Color get statusColor => draft?.cardStatusColor ?? report!.cardStatusColor;
  String get notes => draft?.cardNote ?? report!.cardNote;
  List<String> get photoPaths => draft?.cardPhotoUrl ?? report!.cardPhotoUrl;

  double? get longitude => draft?.longitude ?? report?.longitude;
  double? get latitude => draft?.latitude ?? report?.latitude;

  String? get weatherDesc => draft?.weatherDesc ?? report?.weatherDesc;
  double? get temp => draft?.temp ?? report?.temp;
  String? get iconWeather => draft?.iconWeather ?? report?.iconWeather;
  String? get country => draft?.country ?? report?.country;
  String? get flagUrl => draft?.flagUrl ?? report?.flagUrl;

  // bool get isDraft => status.name.toLowerCase() == 'draft';

  // --- Hộp thoại xác nhận xóa ---
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận Xóa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          draft != null
              ? 'Bạn chắc chắn muốn xóa bản nháp? Hành động này sẽ không hoàn tác.'
              : 'Bạn chắc chắn muốn xóa lịch sử báo cáo này?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), // Red
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext); // Đóng Dialog

              draft != null
                  ? context.read<ReportBloc>().add(DeleteDraftEvent(reportId))
                  : context.read<ReportBloc>().add(DeleteReportEvent(reportId));

              Navigator.pop(context); // Quay về danh sách
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${draft != null ? "Draft" : "Report"} deleted successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor;
    if (draft != null) {
      cardColor = draft?.cardStatusColor;
    } else {
      cardColor = report?.cardStatusColor;
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          draft != null ? 'Draft Details' : 'Report Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Nút Xóa trên AppBar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed: () => _showDeleteDialog(context),
            tooltip: 'Delete',
          ),
          // Nút Sửa trên AppBar (chỉ hiện khi là Draft)
          if (draft != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
              onPressed: () {
                // Mở form chỉnh sửa hoặc submit draft
                final reportBloc = context.read<ReportBloc>();
                final imageBloc = context.read<ImageBloc>();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: reportBloc),
                        BlocProvider.value(value: imageBloc),
                      ],
                      child: FieldReportScreen(editingDraft: draft),
                    ),
                  ),
                );
              },
              tooltip: 'Edit Draft',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status Banner & ID Card
            _buildHeaderCard(cardColor),
            const SizedBox(height: 16),

            // 2. Photo Evidence Section
            _buildSectionTitle('Photo Evidence (${photoPaths.length})'),
            const SizedBox(height: 8),
            _buildPhotoSection(),
            const SizedBox(height: 16),

            // 3. Location (GPS) Section
            _buildSectionTitle('Location Info'),
            const SizedBox(height: 8),
            _buildLocationCard(),
            const SizedBox(height: 16),
            // Weather với quốc gia
            WeatherCountrySection(
              status: weatherDesc == null
                  ? WeatherStatus.initial
                  : WeatherStatus.success,
              weatherDesc: weatherDesc,
              temp: temp,
              countryGuess: country,
              icon: iconWeather,
              flagUrl: flagUrl,
            ),

            // 4. Notes Section
            _buildSectionTitle('Notes'),
            const SizedBox(height: 8),
            _buildNotesCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // Bottom Bar hành động chính
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  // --- Widget 1: Header Card (ID, Site, Time, Badge) ---
  Widget _buildHeaderCard(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reportId,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  status.name,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF334155), height: 24),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Site / Location',
            siteLocation,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            'Date & Time',
            Formatdatetime().formatDateTime(dateTime),
          ),
        ],
      ),
    );
  }

  // --- Widget 2: Danh sách hình ảnh ---
  Widget _buildPhotoSection() {
    if (photoPaths.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Center(
          child: Text(
            'No photos attached',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoPaths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final path = photoPaths[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: path.startsWith('http')
                ? Image.network(
                    path,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: const Color(0xFF334155),
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white38,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  // --- Widget 3: Tọa độ GPS ---
  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Color(0xFF16A34A), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$longitude°N, $latitude°E',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget 4: Ghi chú ---
  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        (notes != null && notes.isNotEmpty) ? notes : 'No notes added.',
        style: TextStyle(
          color: (notes != null && notes.isNotEmpty)
              ? Colors.white
              : const Color(0xFF64748B),
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  // --- Bottom Action Bar ---
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: SafeArea(
        child: isDraft
            ? Row(
                children: [
                  // Nút 1: Xóa Draft
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nút 2: Tiếp tục sửa/Gửi Draft
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Mở form chỉnh sửa hoặc submit draft
                        final reportBloc = context.read<ReportBloc>();
                        final imageBloc = context.read<ImageBloc>();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: reportBloc),
                                BlocProvider.value(value: imageBloc),
                              ],
                              child: FieldReportScreen(editingDraft: draft),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Continue Editing',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Export PDF / Share logic
                  },
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text(
                    'Export & Share Report',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
      ),
    );
  }

  // Helper row cho thông tin
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Helper title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
