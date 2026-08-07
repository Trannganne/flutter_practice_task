import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final Color labelColor;
  final List<String> labels;
  final List<IconData>? icons;

  const CustomTabBar({
    super.key,
    required this.tabController,
    this.labelColor = Colors.white,
    required this.labels,
    this.icons,
  }) : assert(
         labels.length == icons?.length,
         'labels và icons phải có cùng độ dài',
       );

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      labelColor: labelColor,
      tabs: List.generate(labels.length, (index) {
        return Tab(icon: Icon(icons?[index]), text: labels[index]);
      }),
    );
  }
}
