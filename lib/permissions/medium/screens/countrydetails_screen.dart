import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterpractisetasks/permissions/medium/model/country.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/apptoast.dart';
import 'package:flutterpractisetasks/push_notification/medium/services/urlservice.dart';

class CountryDetailScreen extends StatelessWidget {
  final Country country;

  const CountryDetailScreen({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          country.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Khối hiển thị Lá cờ & Tên chính thức
            _buildFlagAndHeader(),
            const SizedBox(height: 20),

            // 2. Thông tin Tổng quan (Bản đồ thu nhỏ giả lập / Thẻ chính)
            _buildSectionTitle('Overview'),
            const SizedBox(height: 8),
            _buildOverviewGrid(),
            const SizedBox(height: 20),

            // 3. Thông tin Chi tiết Địa lý & Kinh tế
            _buildSectionTitle('Details'),
            const SizedBox(height: 8),
            _buildDetailsCard(),
            const SizedBox(height: 20),

            // 4. Danh sách tổ chức tham gia (Memberships)
            if (country.membership != null &&
                country.membership!.isNotEmpty) ...[
              _buildSectionTitle('International Memberships'),
              const SizedBox(height: 8),
              _buildMemberships(),
              const SizedBox(height: 20),
            ],

            // 5. Khối liên kết ngoài (Wikipedia, Google Maps)
            _buildSectionTitle('External Links'),
            const SizedBox(height: 8),
            _buildExternalLinksRow(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS THÀNH PHẦN ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212529),
      ),
    );
  }

  Widget _buildFlagAndHeader() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Hiển thị cờ SVG bảo mật tránh crash khi link null
            Container(
              width: 100,
              height: 66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              clipBehavior: Clip.antiAlias,
              child: country.flagUrl != null
                  ? SvgPicture.network(
                      country.flagUrl!,
                      fit: BoxFit.cover,
                      placeholderBuilder: (context) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.flag,
                        size: 40,
                        color: Colors.grey,
                      ), // fal
                    )
                  : const Icon(Icons.flag, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (country.officialName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      country.officialName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildInfoTile(Icons.location_city, 'Capital', country.capital),
        _buildInfoTile(
          Icons.people,
          'Population',
          _formatPopulation(country.population),
        ),
        _buildInfoTile(Icons.public, 'Region', country.region ?? '—'),
        _buildInfoTile(
          Icons.monetization_on,
          'Currency',
          country.currencies_code != null
              ? '${country.currencies_code} (${country.currencies_symbol ?? ''})'
              : '—',
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D6EFD), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildDetailRow(
              'Area (sq km)',
              country.area_km != null
                  ? '${_formatNumber(country.area_km!)} km²'
                  : '—',
            ),
            _buildDetailRow(
              'Area (sq miles)',
              country.area_m != null
                  ? '${_formatNumber(country.area_m!)} mi²'
                  : '—',
            ),
            _buildDetailRow(
              'Driving Side',
              country.driving_side != null
                  ? country.driving_side!.toUpperCase()
                  : '—',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF212529),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberships() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: country.membership!.map((org) {
        return Chip(
          label: Text(
            org,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D6EFD),
            ),
          ),
          backgroundColor: const Color(0xFFE7F1FF),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildExternalLinksRow() {
    final hasGgmaps =
        country.links_ggmaps != null && country.links_ggmaps!.trim().isNotEmpty;
    final hasWiki =
        country.links_wiki != null && country.links_wiki!.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: _buildIconButton(
            icon: Icons.map_outlined,
            label: 'Google Maps',
            color: hasGgmaps ? const Color(0xFF198754) : Colors.grey,
            onTap: hasGgmaps
                ? () => Urlservice.openArticle(country.links_ggmaps!)
                : () => Apptoast.show('Link không khả dụng'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildIconButton(
            icon: Icons.article_outlined,
            label: 'Wikipedia',
            color: hasWiki ? const Color(0xFF6C757D) : Colors.grey,
            onTap: hasWiki
                ? () => Urlservice.openArticle(country.links_wiki!)
                : () => Apptoast.show('Link không khả dụng'),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: color.withOpacity(0.05),
      ),
    );
  }

  // --- HÀM HELPER ĐỂ ĐỊNH DẠNG SỐ VÀ POPULATION ---

  String _formatPopulation(int population) {
    if (population >= 1000000000) {
      return '${(population / 1000000000).toStringAsFixed(2)} B';
    } else if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)} M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(1)} K';
    }
    return population.toString();
  }

  String _formatNumber(double number) {
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
