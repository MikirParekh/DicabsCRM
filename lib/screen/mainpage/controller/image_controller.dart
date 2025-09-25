import 'package:get/get.dart';

class ImageController extends GetxController {
  RxList<String> capturedImages = <String>[].obs;

  void addImage(String imagePath) {
    capturedImages.add(imagePath);
  }

  void removeImage(String imagePath) {
    capturedImages.remove(imagePath);
  }
}
