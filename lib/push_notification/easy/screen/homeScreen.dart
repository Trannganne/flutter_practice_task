import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/home_bloc/post_bloc.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/home_bloc/post_event.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/home_bloc/post_state.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';
import 'package:flutterpractisetasks/widgets/components/card.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostBloc()..add(FetchPostEvent()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search_outlined, color: Colors.white),
            ),
          ],
          title: Commontext(
            title: 'My feed',
            fontWeight: FontWeight.bold,
            fontSize: '16',
            colorText: Colors.white,
          ),
        ),
        body: BlocListener<PostBloc, PostState>(
          listener: (context, state) {
            if (state is PostLoadSuccess && state.actionMessage != null) {
              Apptoast.show(state.actionMessage!);
            }
          },
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              // Trạng thái loading
              return switch (state) {
                PostInitial() => const SizedBox.shrink(),
                PostLoading() => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Đang tải...'),
                    ],
                  ),
                ),
                PostLoadFailure(:final message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Commontext(
                        title: message,
                        fontSize: '14',
                        colorText: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<PostBloc>().add(FetchPostEvent()),
                        child: Commontext(title: 'Thử lại'),
                      ),
                    ],
                  ),
                ),
                PostLoadSuccess() => _buildPostList(
                  context,
                  state as PostLoadSuccess,
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostList(BuildContext context, PostLoadSuccess state) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: state.posts.length,
        itemBuilder: (_, index) => PostCard(post: state.posts[index]),
      ),
    );
  }
}
