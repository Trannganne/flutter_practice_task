import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/image/image_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_event.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_state.dart';
import 'package:flutterpractisetasks/permissions/hard/models/draftmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/report_mapper.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/report_card_screen.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/report_details_screen.dart';
import '../bloc/report/report_bloc.dart';

class ReportlistScreen extends StatefulWidget {
  const ReportlistScreen({super.key});

  @override
  State<ReportlistScreen> createState() => _ReportlistScreenState();
}

class _ReportlistScreenState extends State<ReportlistScreen> {
  int _selectedFilterIndex = 0;
  // Bỏ 'All', chỉ giữ lại 2 danh mục rõ ràng
  final List<String> _filters = ['Drafts', 'Submitted'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadReportEvent());
    context.read<ReportBloc>().add(LoadDraftsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          title: const Text(
            'Reports History',
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
        body: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            final isDraftTab = _selectedFilterIndex == 0;
            final items = isDraftTab
                ? state.filteredDrafts
                : state.filteredReports;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // 1. Search Box
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: isDraftTab
                          ? 'Search drafts...'
                          : 'Search submitted reports...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ReportBloc>().add(
                                  const SearchReportEvent(''),
                                );
                                setState(() {}); // để suffixIcon ẩn đi ngay
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      context.read<ReportBloc>().add(SearchReportEvent(value));
                      setState(
                        () {},
                      ); // trigger rebuild để suffixIcon hiện/ẩn đúng lúc
                    },
                  ),
                  const SizedBox(height: 12),

                  // 2. Filter Tabs (Drafts vs Submitted)
                  Row(
                    children: List.generate(_filters.length, (index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index == 0 ? 8.0 : 0),
                          child: ChoiceChip(
                            label: Center(
                              child: Text(
                                // Hiển thị thêm số lượng items cho chuyên nghiệp (ví dụ: Drafts (3))
                                '${_filters[index]} (${index == 0 ? state.drafts.length : state.reports.length})',
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF2563EB),
                            backgroundColor: const Color(0xFF1E293B),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF334155),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedFilterIndex = index);
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // 3. Render List theo Tab đang chọn
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        if (isDraftTab) {
                          context.read<ReportBloc>().add(LoadDraftsEvent());
                        } else {
                          context.read<ReportBloc>().add(LoadReportEvent());
                        }
                      },
                      child: _buildListContent(items, isDraftTab),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Hàm render nội dung danh sách
  Widget _buildListContent(List<dynamic> items, bool isDraftTab) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isDraftTab ? 'No drafts saved' : 'No submitted reports',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (isDraftTab) {
          // Tab 0: Hiển thị Drafts
          final draft = items[index] as Draftmodel;
          return ReportCardItem(
            reportId: draft.cardTitle,
            siteLocation: draft.cardLocation,
            dateTime: draft.dateTime ?? DateTime.now(),
            status: draft.cardStatus,
            onTap: () {
              final reportBloc = context.read<ReportBloc>();
              final imageBloc = context.read<ImageBloc>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: reportBloc),
                      BlocProvider.value(value: imageBloc),
                    ],
                    child: ReportDetailScreen(
                      draft: draft,
                      // reportId: draft.cardTitle,
                      // siteLocation: draft.cardLocation,
                      // dateTime: Formatdatetime().formatDateTime(draft.cardDate),
                      // status: draft.cardStatus,
                      // notes: draft.notes,
                      // photoPaths: draft.photoUrls!,
                    ),
                  ),
                ),
              );
            },
            // onDelete: () {
            //   // Bắn Event xóa Draft
            // },
          );
        } else {
          // Tab 1: Hiển thị Reports đã gửi
          final report = items[index] as ReportModel;
          return ReportCardItem(
            reportId: report.cardTitle,
            siteLocation: report.cardLocation,
            dateTime: report.cardDate,
            status: report.cardStatus,
            onTap: () {
              // Mở màn hình Chi Tiết Báo Cáo (Read-only)
              final reportBloc = context.read<ReportBloc>();
              final imageBloc = context.read<ImageBloc>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: reportBloc),
                      BlocProvider.value(value: imageBloc),
                    ],
                    child: ReportDetailScreen(
                      report: report,
                      // reportId: report.cardTitle,
                      // siteLocation: report.cardLocation,
                      // dateTime: Formatdatetime().formatDateTime(
                      //   report.dateTime,
                      // ),
                      // status: report.cardStatus,
                      // notes: report.notes,
                      // photoPaths: report.photoUrls,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
