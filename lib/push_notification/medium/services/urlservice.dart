import 'package:url_launcher/url_launcher.dart';

class Urlservice {
  static Future<void> openArticle(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("Không mở được url: $url");
    }
  }
}
