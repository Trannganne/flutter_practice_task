import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<List<XFile>?> imageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      return pickedFile == null ? null : <XFile>[pickedFile];
    } catch (e) {
      throw Exception('Không thể chọn ảnh: $e');
    }
  }
}
