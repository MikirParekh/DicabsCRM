import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/screen/mainpage/controller/image_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ImageController imageController = Get.find<ImageController>();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();
      if (!mounted) return;

      imageController.addImage(image.path);

      showLog(
        msg: "Image controller image ---> ${imageController.capturedImages}",
      );

      Navigator.pop(context, image.path);
    } catch (e) {
      showLog(msg: "❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                /// Camera Preview
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),

                /// Bottom capture controls
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // const Icon(Icons.photo_library,
                        //     color: Colors.white, size: 32),

                        // Capture Button
                        GestureDetector(
                          onTap: _captureImage,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                          ),
                        ),

                        // const Icon(Icons.cameraswitch,
                        //     color: Colors.white, size: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // final ImageController imageController = Get.put(ImageController());

    return Scaffold(
      appBar: AppBar(title: const Text('Picture Preview')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            showLog(msg: "Confirm button pressed");
            // Handle the confirmation of the image.
            // You might want to pass the imagePath back to the previous screen
            // or perform an upload here.

            // imageController.setImage(imagePath);

            // showLog(
            //     msg:
            //         "Image controller image ---> ${imageController.capturedImage}");

            // Navigator.pop(context);

            // Navigator.popUntil(context, (route) => route.);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            'Confirm Image',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
