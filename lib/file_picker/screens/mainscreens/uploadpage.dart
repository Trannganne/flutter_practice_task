import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_bloc.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_event.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_state.dart';
import 'package:flutterpractisetasks/file_picker/core/utils/file_size_formatter.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/dialog/dialog.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/photo_section.dart';
import 'package:flutterpractisetasks/widgets/common_tabbar/custom_tabbar.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:flutterpractisetasks/widgets/components/completedCard.dart';
import 'package:flutterpractisetasks/widgets/components/file_card.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class Uploadpage extends StatefulWidget {
  const Uploadpage({super.key});

  @override
  State<Uploadpage> createState() => _UploadpageState();
}

class _UploadpageState extends State<Uploadpage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _completedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<FileBloc>()
      ..add(UploadQueueStarted())
      ..add(LoadCompletedTasks());

    // Lắng nghe cuộn — khi gần chạm đáy, tự tải thêm
    _completedScrollController.addListener(() {
      final position = _completedScrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200) {
        context.read<FileBloc>().add(LoadMoreCompletedTasks());
      }
    });
  }

  @override
  void dispose() {
    _completedScrollController.dispose(); // tránh memory leak
    super.dispose();
  }

  Future<void> _copyUrl(String? url) async {
    debugPrint('[Copy] URL nhận được: $url');

    if (url == null || url.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Không tìm thấy đường dẫn để sao chép')),
        );

      return;
    }

    await Clipboard.setData(ClipboardData(text: url));

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Đã sao chép đường dẫn')));

    debugPrint('[Copy] Đã sao chép: $url');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FileBloc, FileState>(
      listener: (context, state) {
        if (state.rejectMessage != null && state.rejectMessage!.isNotEmpty) {
          Apptoast.show(state.rejectMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          // appBar: CustomAppbar(
          //   title: 'Cloud Media Uploader',
          //   actions: [
          //     IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          //     IconButton(
          //       onPressed: () {},
          //       icon: Icon(Icons.notifications_outlined),
          //     ),
          //   ],
          // ),
          body: CustomScrollView(
            controller: _completedScrollController,
            slivers: [
              SliverAppBar(
                title: Commontext(
                  title: 'Cloud Media Uploader',
                  colorText: Colors.white,
                  fontSize: '18',
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.black,
                pinned: false,
                floating: true,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications_outlined),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      color: Colors.black,
                      child: CustomTabBar(
                        tabController: _tabController,
                        labels: ['Upload', 'Gallery'],
                        //icons: [Icons.cloud_upload, Icons.album],
                      ),
                    ),
                    const SizedBox(height: 8),

                    PhotoSection(
                      title: 'Add Media',
                      colorText: Colors.black,
                      photoUrls: state.files.map((f) => f.filePath).toList(),
                      photoCount: 0,
                      onTakePhotoPressed: () {
                        context.read<FileBloc>().add(
                          ToggleAddMoreEvent(ImageSource.gallery),
                        );
                      },
                      onRemovePhotoPressed: (path) {
                        context.read<FileBloc>().add(RemoveFileEvent(path));
                      },
                      icon: Icons.add,
                      content: 'Add More',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Commontext(
                            title: 'Queue(${state.files.length})',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Commontext(
                            title: 'Clear Completed',
                            colorText: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),

                    // Completed section
                  ],
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = state.files[index];
                  return FileCard(
                    taskId: task.id,
                    title: task.filePath.split('/').last,
                    status: task.status.name,
                    width: task.width ?? 0,
                    height: task.height ?? 0,
                    fileSize: FileSizeFormatter.format(task.sizeByte ?? 0),
                    progress: task.progress,
                    imagePath: task.filePath,
                    onCopyPressed: () {
                      debugPrint("[FileCard] Đã nhấn copy taskId: ${task.id}");
                      _copyUrl(task.remoteUrl);
                    },
                    onPausePressed: () {
                      debugPrint(
                        '[Uploadpage] Gửi PauseUploadEvent: ${task.id}',
                      );
                      ;
                      context.read<FileBloc>().add(PauseUploadEvent(task.id));
                    },
                    onResumePressed: () {
                      context.read<FileBloc>().add(ResumeUploadEvent(task.id));
                    },
                    onCancelPressed: () async {
                      final result = await CustomDialog().showCusTomDialog(
                        context,
                        title: 'Xác nhận',
                        content: 'Bạn có chắc chắn muốn hủy upload file này?',
                        button1: 'Tiếp tục',
                        button2: 'Xác nhận hủy',
                      );

                      if (result == DialogResult.confirm) {
                        context.read<FileBloc>().add(
                          CancelUploadEvent(task.id),
                        );
                      } else if (result == DialogResult.cancel) {
                        context.pop(context);
                      }
                    },
                  );
                }, childCount: state.files.length),
              ),

              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Commontext(
                        title: 'Completed(${state.completedFiles.length})',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Thay ListView.builder bằng SliverList
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = state.completedFiles[index];

                  return Completedcard(
                    title: task.filePath.split('/').last,
                    completedAt:
                        (DateTime.now().millisecondsSinceEpoch -
                            task.updatedAt) ~/
                        1000,
                    sourcePath: task.remoteUrl,
                    imagePath: task.filePath,
                    onCopyPressed: () async {
                      // Kiểm tra xem đã copy chưa
                      debugPrint(
                        "[Completed Card] Đã nhấn copy taskId: ${task.id}",
                      );
                      _copyUrl(task.remoteUrl);
                    },
                  );
                }, childCount: state.completedFiles.length),
              ),
            ],
          ),
        );
      },
    );
  }
}
