import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/image_caching/core/customappbar.dart';
import 'package:flutterpractisetasks/video_player/bloc/playerbloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/playerstate.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerBloc, Playerstate>(
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppbar(
            title: 'Video Explorer',
            actions: [Icon(Icons.search, color: Colors.white, size: 18)],
          ),
        );
      },
      listener: (context, state) {
        if (state.actionMessage != null && state.actionMessage!.isNotEmpty) {
          Apptoast.show(state.actionMessage!);
        }
      },
    );
  }
}
