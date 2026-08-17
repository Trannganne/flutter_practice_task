import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/widgets/components/mediatasktile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search uploads...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Failed'),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // History List
          Expanded(
            child: ListView(
              children: const [
                MediaTaskTile(
                  fileName: 'mountains.jpg',
                  subtitleText: '2m ago',
                  url: 'https://i.ibb.co/abc123/mountains.jpg',
                  statusText: 'Done',
                  statusColor: Colors.green,
                  type: TileType.history,
                ),
                MediaTaskTile(
                  fileName: 'city_street.png',
                  subtitleText: '15m ago',
                  url: 'https://i.ibb.co/def456/city-street.png',
                  statusText: 'Done',
                  statusColor: Colors.green,
                  type: TileType.history,
                ),
                MediaTaskTile(
                  fileName: 'pier_evening.jpg',
                  subtitleText: '1h ago',
                  progress: 0.5,
                  statusText: 'Failed',
                  statusColor: Colors.red,
                  statusIcon: Icons.error_outline,
                  type: TileType.queue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
