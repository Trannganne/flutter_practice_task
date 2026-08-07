class FormValidationResult {
  final Map<String, String> fieldErrors;
  const FormValidationResult(this.fieldErrors);
  bool get isValid => fieldErrors.isEmpty;

  String? errorFor(String field) => fieldErrors[field];

  // Trả về field lỗi đầu tiên theo đúng thứ tự khai báo, dùng để scroll tới
  String? get firstErrorField =>
      fieldErrors.isEmpty ? null : fieldErrors.keys.first;
  FormValidationResult clearField(String field) {
    if (!fieldErrors.containsKey(field))
      return this; // không có lỗi thì khỏi tạo object mới
    final newErrors = Map<String, String>.from(fieldErrors)..remove(field);
    return FormValidationResult(newErrors);
  }
}

class ReportValidator {
  /// Field name constants — dùng chung giữa validator và UI, tránh gõ tay sai chính tả
  static const fieldSiteLocation = 'siteLocation';
  static const fieldPhoto = 'photo';
  static const fieldGps = 'gps';

  static FormValidationResult validate({
    required String siteLocation,
    required List<String> photoPaths,
    required double? latitude,
    required double? longitude,
  }) {
    // Dùng LinkedHashMap-like behavior của Map thường trong Dart
    // để đảm bảo thứ tự lỗi đúng theo thứ tự khai báo (Dart Map giữ thứ tự insert)
    final errors = <String, String>{};

    if (siteLocation.trim().isEmpty) {
      errors[fieldSiteLocation] = 'Vui lòng nhập địa điểm';
    }
    if (photoPaths.isEmpty) {
      errors[fieldPhoto] = 'Cần ít nhất 1 ảnh hiện trường';
    }
    if (latitude == null || longitude == null) {
      errors[fieldGps] = 'Vui lòng lấy vị trí GPS';
    }

    return FormValidationResult(errors);
  }
}
