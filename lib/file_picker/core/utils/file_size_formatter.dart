class FileSizeFormatter {
  /// Chuyển đổi số byte thành chuỗi hiển thị dễ đọc (KB/MB/GB)
  static String format(int bytes) {
    if (bytes <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    // B và KB không cần số thập phân, từ MB trở lên hiển thị 1-2 chữ số thập phân
    final decimals = unitIndex <= 1 ? 0 : (size < 10 ? 2 : 1);
    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }
}
