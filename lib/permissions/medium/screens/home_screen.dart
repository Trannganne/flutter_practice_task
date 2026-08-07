import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterpractisetasks/permissions/medium/bloc/country_bloc.dart';
import 'package:flutterpractisetasks/permissions/medium/bloc/country_event.dart';
import 'package:flutterpractisetasks/permissions/medium/bloc/country_state.dart';
import 'package:flutterpractisetasks/permissions/medium/model/country_filter.dart';
import 'package:flutterpractisetasks/permissions/medium/screens/countrydetails_screen.dart';
//import 'package:flutterpractisetasks/permissions/model/country.dart'; // model THẬT, không tự khai báo lại
import 'package:flutterpractisetasks/push_notification/easy/screen/components/apptoast.dart';
import 'package:flutterpractisetasks/permissions/medium/core/convert.dart';

// ===================== ENTRY POINT =====================
// Widget này CHỈ làm 1 việc: tạo CountryBloc đúng 1 lần rồi giao cho _CountryView.
// Không có setState nào ở đây -> BlocProvider không bao giờ bị tạo lại giữa chừng.
class CountryScreen extends StatelessWidget {
  const CountryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CountryBloc()..add(FetchCountryEvent()),
      child: const _CountryView(),
    );
  }
}

// ===================== UI =====================
// Widget này KHÔNG tự giữ list countries nữa -> luôn đọc từ state của Bloc.
class _CountryView extends StatefulWidget {
  const _CountryView();

  @override
  State<_CountryView> createState() => _CountryViewState();
}

class _CountryViewState extends State<_CountryView> {
  bool showPermissionBox = true;
  bool showSuccessBox =
      false; // chỉ hiện SAU KHI export thật sự xong, không mặc định true

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
          title: const Text(
            'Countries',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                // Gửi EVENT -> gọi Bloc từ UI
                onPressed: () =>
                    context.read<CountryBloc>().add(ExportCsvEvent()),
                icon: const Icon(Icons.download, size: 18, color: Colors.white),
                label: const Text(
                  'Export CSV',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        // Gõ search -> gửi event lọc, KHÔNG tự lọc list local trong screen
                        onChanged: (value) {
                          final currentFilter =
                              (context.read<CountryBloc>().state
                                      as CountryLoadSuccess)
                                  .filter;
                          context.read<CountryBloc>().add(
                            ApplyFilterEvent(
                              currentFilter.copyWith(keyword: value),
                            ),
                          );
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search countries...',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.black54,
                      ),
                      onPressed: () => _showFilterSheet(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // BlocConsumer đặt NGOÀI cùng của body: builder để VẼ, listener để làm side-effect
        // (toast, mở file...) — 2 việc tách biệt, không lẫn vào nhau.
        body: BlocConsumer<CountryBloc, CountryState>(
          listener: (context, state) {
            if (state is CountryLoadSuccess) {
              if (state.actionMessage != null) {
                Apptoast.show(state.actionMessage!);
              }

              if (state.isPermissionGranted) {
                setState(() {
                  showPermissionBox = false;
                });
              }

              if (state.isSuccess == true) {
                setState(() => showSuccessBox = true);
              } else if (state.isSuccess == false) {
                setState(
                  () => showSuccessBox = false,
                ); // export lỗi -> chắc chắn KHÔNG hiện box success
              }
            }
          },
          builder: (context, state) {
            // ===== 1. LOADING =====
            if (state is CountryLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // ===== 2. ERROR + RETRY =====
            if (state is CountryLoadFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        // =>                          context.read<CountryBloc>().add(RetryCountryEvent()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ===== 3. SUCCESS (kể cả rỗng -> tự nhiên rơi vào empty state bên dưới) =====
            if (state is CountryLoadSuccess) {
              final countries = state.countries; // <-- LIST THẬT từ Bloc

              return ListView(
                padding: const EdgeInsets.all(16.0),

                children: [
                  if (showPermissionBox) ...[
                    _buildPermissionBox(context),
                    const SizedBox(height: 16),
                  ],
                  if (showSuccessBox) _buildSuccessBox(state.exportPath),

                  Text(
                    'Total: ${countries.length} countries',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ===== EMPTY STATE =====
                  if (countries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text('Không tìm thấy quốc gia nào.'),
                      ),
                    )
                  else
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: countries.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.grey.shade100, height: 1),
                        itemBuilder: (context, index) {
                          final country = countries[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                3,
                              ), // chỉnh số này để bo nhiều/ít
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child:
                                    (country.flagUrl != null &&
                                        country.flagUrl!.trim().isNotEmpty)
                                    ? SvgPicture.network(
                                        country.flagUrl!,
                                        fit: BoxFit
                                            .cover, // đổi sang cover để lấp đầy khung bo góc, không để trắng viền
                                        placeholderBuilder: (_) => Container(
                                          color: Colors.grey.shade200,
                                        ),
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.flag_outlined,
                                            size: 16,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.flag_outlined,
                                          size: 16,
                                        ),
                                      ),
                              ),
                            ),
                            title: Text(
                              country.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              country.capital,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  country
                                      .region!, // 'region', không phải 'continent' - khớp API
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CountryDetailScreen(country: country),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              );
            }

            return const SizedBox.shrink(); // CountryInitial hoặc state chưa xử lý
          },
        ),
      ),
    );
  }

  Widget _buildPermissionBox(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F1FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder_open_outlined,
                    color: Color(0xFF0D6EFD),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export to device storage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'We need storage access to save the countries list as a CSV file on your device.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => setState(() => showPermissionBox = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Xin quyền -> đây cũng nên là 1 event
                // (permission_handler) thay vì screen tự gọi thẳng permission_handler.
                onPressed: () => context.read<CountryBloc>().add(
                  RequestStoragePermissionEvent(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Allow storage access',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBox(String? filePath) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF198754), size: 36),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export successful',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'File CSV đã lưu.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: filePath == null
                  ? null
                  : () =>
                        context.read<CountryBloc>()
                          ..add(OpenExportedFileEvent(filePath)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View file',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final bloc = context.read<CountryBloc>();
    final current = bloc.state as CountryLoadSuccess;

    // Tính khoảng dân số THẬT từ data, không hard-code — country nhỏ nhất/lớn nhất có thể đổi theo API
    final populations = current.allCountries.map((c) => c.population).toList();
    final minBound = populations.reduce((a, b) => a < b ? a : b).toDouble();
    final maxBound = populations.reduce((a, b) => a > b ? a : b).toDouble();

    // Buffer tạm — khởi tạo từ filter hiện có, hoặc full range nếu chưa lọc gì
    RangeValues tempRange = RangeValues(
      (current.filter.minPopulation ?? minBound.toInt()).toDouble(),
      (current.filter.maxPopulation ?? maxBound.toInt()).toDouble(),
    );
    String? tempDrivingSide = current.filter.drivingSide;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Dân số',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempRange = RangeValues(minBound, maxBound);
                            tempDrivingSide = null;
                          });
                          context.read<CountryBloc>().add(
                            ApplyFilterEvent(const CountryFilter()),
                          );
                        },
                        child: Text('Xóa tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Convert().formatPopulation(tempRange.start)} — ${Convert().formatPopulation(tempRange.end)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RangeSlider(
                    min: minBound,
                    max: maxBound,
                    values: tempRange,
                    labels: RangeLabels(
                      tempRange.start.round().toString(),
                      tempRange.end.round().toString(),
                    ),
                    onChanged: (values) =>
                        setSheetState(() => tempRange = values),
                    // ^ chỉ setSheetState LOCAL, KHÔNG add Event ở đây
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chiều lái xe',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Tất cả')),
                      ButtonSegment(value: 'right', label: Text('Bên phải')),
                      ButtonSegment(value: 'left', label: Text('Bên trái')),
                    ],
                    selected: {tempDrivingSide},
                    onSelectionChanged: (selected) =>
                        setSheetState(() => tempDrivingSide = selected.first),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        bloc.add(
                          ApplyFilterEvent(
                            current.filter.copyWith(
                              minPopulation: tempRange.start.round(),
                              maxPopulation: tempRange.end.round(),
                              drivingSide: tempDrivingSide,
                              clearDrivingSide: tempDrivingSide == null,
                            ),
                          ),
                        );
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
