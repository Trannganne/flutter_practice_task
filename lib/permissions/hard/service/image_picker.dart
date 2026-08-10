import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<List<XFile>?> imageButtonPressed(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        return await _picker.pickMultiImage();
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile == null) return [];

      return [pickedFile];
    } catch (e) {
      throw Exception('Không thể chọn ảnh: $e');
    }
  }
}
