import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/customewidget/global_dropdown.dart';
import 'package:dicabs/customewidget/global_text_field.dart';
import 'package:dicabs/screen/mainpage/controller/image_controller.dart';
import 'package:dicabs/screen/mainpage/ui/camera_screen.dart';
import 'package:dicabs/screen/mainpage/widgets/category_bottom_view.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../customewidget/global_button.dart';
import '../../../global_location.dart';
import '../model/form_data_model.dart';
import '../repo/main_page_repo.dart';
import '../widgets/contact_bottom_view.dart';
import '../widgets/opportunity_bottom_view.dart';
import '../widgets/taskMember_bottom_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.userCode, required this.salesCode});
  final String userCode;
  final String salesCode;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController selectedCategory = TextEditingController();
  final TextEditingController selectedContacts = TextEditingController();
  final TextEditingController selectedOpportunity = TextEditingController();
  final TextEditingController selectedTaskMember = TextEditingController();
  List<AddActivityList> originalData = [];
  List<AddActivityList> filteredData = [];
  final MethodChannel platform =
      const MethodChannel('com.uniqtech.dicabs/tracking');

  final ImageController imageController = Get.put(ImageController());

  bool isLoading = false;
  List<String> selectedTaskMembers = [];
  List<File> selectedFiles = []; // New list to store selected files

  final MainPageRepository submit = MainPageRepository();

  Future<void> _startTracking() async {
    if (_validateForm()) {
      setState(() {
        isLoading = true;
      });

      // 🛠️ Fallback: Fetch location immediately if global values are null
      if (globalLatitude == null || globalLongitude == null) {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          globalLatitude = position.latitude.toStringAsFixed(5);
          globalLongitude = position.longitude.toStringAsFixed(5);
        } catch (e) {
          showLog(msg: "❌ Location fetch failed: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to get location")),
          );
          setState(() => isLoading = false);
          return;
        }
      }

      showLog(msg: "📍 Sending Lat: $globalLatitude, Long: $globalLongitude");

      final model = AddActivityList(
        title: titleController.text.trim(),
        endDate: dueDateController.text.trim(),
        category: selectedCategory.text.trim(),
        message: descriptionController.text.trim(),
        remark: noteController.text.trim(),
        regarding: selectedOpportunity.text.trim(),
        assignBy: selectedContacts.text.trim(),
        taskTo: selectedTaskMember.text.trim(),
      );

      try {
        await submit.submitForm(
            model, widget.userCode, widget.salesCode, selectedFiles);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submit Successful'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (error) {
        logRed(msg: "❌ Submit error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submit Failed'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.amber,
        ),
      );
    }
  }

  bool _validateForm() {
    return titleController.text.isNotEmpty &&
        dueDateController.text.isNotEmpty &&
        selectedCategory.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        noteController.text.isNotEmpty &&
        selectedOpportunity.text.isNotEmpty &&
        selectedContacts.text.isNotEmpty &&
        selectedTaskMember.text.isNotEmpty;
  }

  void _openCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: CategoryBottomView(
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory.text = category;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _openContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: ContactBottomView(
                onContactSelected: (contacts) {
                  setState(() {
                    selectedContacts.text = contacts;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _openOpportunityBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: OpportunityBottomView(
                onOpportunitySelected: (opportunity) {
                  setState(() {
                    selectedOpportunity.text = opportunity;
                    showLog(
                        msg:
                            "Selected Opportunity: ${selectedOpportunity.text}");
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _openTaskMemberBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return TaskMemberBottomView(
            onTaskMemberSelected: (List<String> taskMembers) {
          setState(() {
            selectedTaskMembers = taskMembers;
            selectedTaskMember.text = taskMembers.join(',');
          });
          // Navigator.pop(context);
        });
      },
    );
  }

  // --- File Selection and Processing ---
  Future<void> _handleFileSelection() async {
    // 1. Pick files
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true, // Necessary to get bytes for cloud files
      type: FileType.custom,
      allowedExtensions: [
        // Images
        'jpg', 'jpeg', 'png', 'webp',

        // Documents
        'pdf', 'doc', 'docx', 'txt',

        // Excel
        'xls', 'xlsx'
      ],
    );

    if (result == null) {
      showLog(msg: "User canceled the picker.");
      return;
    }

    // 🔹 Check max file limit (5)
    if (result.files.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only select up to 5 files.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop processing
    }

    // 2. Process the results and convert to File objects
    // selectedFiles = await _processFileFilePickerResult(result);

    // Process picked files
    final pickedFiles = await _processFileFilePickerResult(result);

    // Combine with already added files (camera)
    for (var file in pickedFiles) {
      if (selectedFiles.length < 5 && !selectedFiles.contains(file)) {
        selectedFiles.add(file);
      }
    }

    // 3. Now you have a list of usable File objects for upload
    showLog(msg: "Number of files ready for upload: ${selectedFiles.length}");
    for (var file in selectedFiles) {
      showLog(msg: "File path: ${file.path}");
    }
    setState(() {});
  }

  Future<void> prepareFilesForUpload() async {
    // Clear old list first
    selectedFiles.clear();

    // Add camera images first
    await _addCameraImages();

    // If user also picks files, combine them
    await _handleFileSelection();

    // Now selectedFiles contains camera + picked files (max 5)
    showLog(msg: "✅ Final files for upload ---> $selectedFiles");
  }

  ///upload document
  // Future<void> _uploadDocument() async {
  //   try {
  //     await submit.uploadFile(
  //         taskid: "9504", userCode: "1053", selectedFiles: selectedFiles);
  //   } catch (e) {
  //     showLog(msg: "Error uploading document: $e");
  //   }
  // }

  /// Upload document
  Future<void> _uploadDocument() async {
    try {
      // 🔹 Extra safeguard: limit max 5 files
      if (selectedFiles.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can upload a maximum of 5 files only.'),
            backgroundColor: Colors.red,
          ),
        );
        showLog(msg: "Upload blocked: more than 5 files selected.");
        return; // ❌ stop upload
      }

      if (selectedFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one file to upload.'),
            backgroundColor: Colors.orange,
          ),
        );
        showLog(msg: "Upload blocked: no files selected.");
        return;
      }

      // ✅ Proceed with upload
      await submit.uploadFile(
        taskid: "9504",
        userCode: "1053",
        selectedFiles: selectedFiles,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Files uploaded successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      showLog(msg: "Error uploading document: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Add captured images from camera to selectedFiles
  Future<void> _addCameraImages() async {
    try {
      for (var path in imageController.capturedImages) {
        final file = File(path);
        // Only add if we haven't reached max 5
        if (selectedFiles.length < 5 && !selectedFiles.contains(file)) {
          selectedFiles.add(file);
        }
      }
      showLog(msg: "✅ Camera images added ---> $selectedFiles");

      // await prepareFilesForUpload();
    } catch (e) {
      showLog(msg: "Error adding captured images: $e");
    }
    setState(() {});
  }

  /// Converts FilePickerResult to a List<File>, handling cloud files by saving them temporarily.
  Future<List<File>> _processFileFilePickerResult(
      FilePickerResult result) async {
    const int maxFileSize = 5 * 1024 * 1024; // 10 MB in bytes
    List<File> processedFiles = [];
    List<String> skippedFiles = [];
    const int maxFileCount = 5;

    if (result.files.length > maxFileCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You can select a maximum of 5 files. Only the first 5 will be processed.'),
          backgroundColor: Colors.orange,
        ),
      );
      showLog(
          msg: "User selected more than 5 files, only first 5 will be used.");
    }

    // 🔹 Take only first 5 files
    final limitedFiles = result.files.take(maxFileCount).toList();

    for (PlatformFile platformFile in limitedFiles) {
      File file;

      if (platformFile.path != null) {
        // --- Case 1: File has a local path (most common scenario) ---
        file = File(platformFile.path!);
      } else {
        if (platformFile.bytes == null) {
          showLog(
              msg: "Skipping file ${platformFile.name}: No bytes available.");
          skippedFiles.add(platformFile.name);
          continue;
        }

        // --- Case 2: File path is null (common for cloud files or web) ---
        // Read bytes and write to a temporary file.
        showLog(
            msg:
                "File path was null. Reading from bytes and creating temporary file.");
        final tempDir = await getTemporaryDirectory();
        file = File('${tempDir.path}/${platformFile.name}');

        try {
          await file.writeAsBytes(platformFile.bytes!);
        } catch (e) {
          showLog(msg: "Error writing temporary file: $e");
          continue; // Skip this file if writing fails
        }
      }

      // Check file size
      if (await file.length() > maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File Must be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        showLog(msg: "Skipping file ${platformFile.name}: Size exceeds 5MB.");
        skippedFiles.add(platformFile.name);
        continue;
      }

      processedFiles.add(file);
    }

    return processedFiles;
  }

  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    // Initialize selectedTaskMember.text if needed, e.g., from a saved state
    selectedTaskMember.text = selectedTaskMembers.join(',');

    // Obtain a list of the available cameras on the device.
    availableCameras().then((availableCameras) {
      setState(() => cameras = availableCameras);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Activity"),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlobalTextFormField(
                          labelText: 'Subject',
                          controller: titleController,
                          keyboardType: TextInputType.text,
                        ),
                        GlobalTextFormField(
                          labelText: 'Due Date',
                          controller: dueDateController,
                          keyboardType: TextInputType.text,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            // if (pickedDate != null) {
                            //   dueDateController.text =
                            //       DateFormat('yyyy-MM-dd HH:mm:ss')
                            //           .format(pickedDate);

                            //   showLog(
                            //       msg:
                            //           "Current date time ---> ${DateTime.now()}");
                            //   showLog(
                            //       msg:
                            //           "Selected Date: ${dueDateController.text}");
                            // }

                            if (pickedDate != null) {
                              final now = DateTime.now();

                              // Combine selected date with current time
                              final selectedDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                now.hour,
                                now.minute,
                                now.second,
                              );

                              dueDateController.text =
                                  DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(selectedDateTime);

                              showLog(msg: "Current date time ---> $now");
                              showLog(
                                  msg:
                                      "Selected DateTime: ${dueDateController.text}");
                            }
                          },
                        ),
                        InkWell(
                          onTap: _openCategoryBottomSheet,
                          child: GlobalDropdown(
                            labelText: selectedCategory.text.isEmpty
                                ? "Select Category"
                                : selectedCategory.text,
                            isSelected: selectedCategory.text.isNotEmpty,
                          ),
                        ),
                        GlobalTextFormField(
                          labelText: 'Description',
                          controller: descriptionController,
                          keyboardType: TextInputType.text,
                          maxLine: 2,
                        ),
                        GlobalTextFormField(
                          labelText: 'Note',
                          controller: noteController,
                          keyboardType: TextInputType.text,
                          maxLine: 2,
                        ),
                        InkWell(
                          onTap: _openOpportunityBottomSheet,
                          child: GlobalDropdown(
                            labelText: selectedOpportunity.text.isEmpty
                                ? "Select Opportunity"
                                : selectedOpportunity.text,
                            isSelected: selectedOpportunity.text.isNotEmpty,
                          ),
                        ),
                        InkWell(
                          onTap: _openContactBottomSheet,
                          child: GlobalDropdown(
                            labelText: selectedContacts.text.isEmpty
                                ? "Select Customer/Contact"
                                : selectedContacts.text,
                            isSelected: selectedContacts.text.isNotEmpty,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: _openTaskMemberBottomSheet,
                              child: GlobalDropdown(
                                labelText: selectedTaskMembers.isNotEmpty
                                    ? "👥 Assigned to ${selectedTaskMembers.length} ${selectedTaskMembers.length == 1 ? 'member' : 'members'}"
                                    : "👥 Assign Task Members",
                                isSelected: selectedTaskMembers.isNotEmpty,
                              ),
                            ),
                            const Gap(8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedTaskMembers.map((member) {
                                return Chip(
                                  label: Text(member),
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.white),
                                  backgroundColor: Colors.blueAccent,
                                  avatar: const Icon(Icons.person,
                                      color: Colors.white, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      selectedTaskMembers.remove(member);
                                      selectedTaskMember.text =
                                          selectedTaskMembers.join(',');
                                    });
                                  },
                                );
                              }).toList(),
                            )
                          ],
                        ),
                        const Gap(8),

                        if (selectedFiles.isNotEmpty) ...[
                          const Gap(16),
                          Text(
                            "Selected Files:",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Gap(8),
                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   itemCount: selectedFiles.length,
                          //   itemBuilder: (context, index) {
                          //     final file = selectedFiles[index];
                          //     return Card(
                          //       margin: const EdgeInsets.only(bottom: 8),
                          //       child: ListTile(
                          //         leading: const Icon(Icons.insert_drive_file),
                          //         title: Text(file.path.split('/').last),
                          //         trailing: IconButton(
                          //           icon: const Icon(Icons.delete,
                          //               color: Colors.red),
                          //           onPressed: () {
                          //             setState(
                          //                 () => selectedFiles.removeAt(index));
                          //           },
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: selectedFiles.length,
                            itemBuilder: (context, index) {
                              final file = selectedFiles[index];
                              final extension =
                                  file.path.split('.').last.toLowerCase();

                              Widget thumbnail;

                              // Image file extensions
                              const imageExtensions = [
                                'jpg',
                                'jpeg',
                                'png',
                                'gif',
                                'webp',
                                'bmp'
                              ];

                              if (imageExtensions.contains(extension)) {
                                // Show image preview
                                thumbnail = Image.file(
                                  file,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                );
                              } else if (extension == 'pdf') {
                                thumbnail = const Icon(Icons.picture_as_pdf,
                                    color: Colors.red, size: 50);
                              } else if (['doc', 'docx', 'txt', 'rtf']
                                  .contains(extension)) {
                                thumbnail = const Icon(Icons.description,
                                    color: Colors.blue, size: 50);
                              } else if (['xls', 'xlsx'].contains(extension)) {
                                thumbnail = const Icon(Icons.grid_on,
                                    color: Colors.green, size: 50);
                              } else {
                                // Default file icon
                                thumbnail = const Icon(Icons.insert_drive_file,
                                    size: 50);
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: thumbnail,
                                  title: Text(file.path.split('/').last),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        selectedFiles.removeWhere(
                                            (f) => f.path == file.path);
                                        imageController.capturedImages
                                            .removeWhere((f) => f == file.path);
                                      });
                                      showLog(
                                          msg:
                                              "Removed file ---> ${file.path}");
                                      showLog(
                                          msg:
                                              "Selected files ---> $selectedFiles");
                                      showLog(
                                          msg:
                                              "Captured images ---> ${imageController.capturedImages}");
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const Gap(8),
                        ],

                        // file selection -- doted box
                        GestureDetector(
                          onTap: () async {
                            showLog(msg: "file picker");
                            // await _handleFileSelection();
                            await prepareFilesForUpload();
                          }, // Trigger the callback function provided.
                          child: DottedBorder(
                            options: const RoundedRectDottedBorderOptions(
                                radius: Radius.circular(12)),
                            child: Container(
                              width:
                                  double.infinity, // Take full available width.
                              height: 150, // Fixed height for the container.
                              decoration: BoxDecoration(
                                // color: Colors.grey[
                                //     100], // Light background color for the drop zone.
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 50,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Tap to select a document",
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Max file size: 5MB",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Gap(8),
                        // Obx(() {
                        //   if (imageController.capturedImages.isEmpty) {
                        //     return const SizedBox.shrink();
                        //   }

                        //   return ListView.builder(
                        //     shrinkWrap: true,
                        //     physics: const NeverScrollableScrollPhysics(),
                        //     itemCount: imageController.capturedImages.length,
                        //     itemBuilder: (context, index) {
                        //       final imagePath =
                        //           imageController.capturedImages[index];
                        //       return Padding(
                        //         padding: const EdgeInsets.only(bottom: 8),
                        //         child: Stack(
                        //           children: [
                        //             // Show the image
                        //             Image.file(
                        //               File(imagePath),
                        //               height: 200,
                        //               width: double.infinity,
                        //               fit: BoxFit.cover,
                        //             ),

                        //             // Delete button (top-right corner)
                        //             Positioned(
                        //               top: 8,
                        //               right: 8,
                        //               child: InkWell(
                        //                 onTap: () {
                        //                   setState(() {
                        //                     selectedFiles.removeWhere(
                        //                         (f) => f.path == file.path);
                        //                     imageController.capturedImages
                        //                         .removeWhere(
                        //                             (f) => f == file.path);
                        //                   });
                        //                   showLog(
                        //                       msg:
                        //                           "Removed file ---> ${file.path}");
                        //                   showLog(
                        //                       msg:
                        //                           "Selected files ---> $selectedFiles");
                        //                   showLog(
                        //                       msg:
                        //                           "Captured images ---> ${imageController.capturedImages}");
                        //                 },
                        //                 child: Container(
                        //                   decoration: const BoxDecoration(
                        //                     color: Colors.black54,
                        //                     shape: BoxShape.circle,
                        //                   ),
                        //                   padding: const EdgeInsets.all(6),
                        //                   child: const Icon(
                        //                     Icons.delete,
                        //                     color: Colors.red,
                        //                     size: 20,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       );
                        //     },
                        //   );
                        // }),

                        const Gap(8),

                        GestureDetector(
                          onTap: () async {
                            showLog(msg: "Capture image");

                            // Wait until user takes picture
                            final capturedImagePath =
                                await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CameraScreen(cameras: cameras),
                              ),
                            );

                            if (capturedImagePath != null) {
                              // Only now add to selectedFiles
                              await _addCameraImages();
                              showLog(msg: "Camera images added after capture");
                              // await prepareFilesForUpload();
                            }
                          }, // Trigger the callback function provided.
                          child: DottedBorder(
                            options: const RoundedRectDottedBorderOptions(
                                radius: Radius.circular(12)),
                            child: Container(
                              width:
                                  double.infinity, // Take full available width.
                              height: 150, // Fixed height for the container.
                              decoration: BoxDecoration(
                                // color: Colors.grey[
                                //     100], // Light background color for the drop zone.
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 50,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Take a picture",
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  // const SizedBox(height: 4),
                                  // Text(
                                  //   "Max file size: 5MB",
                                  //   style: TextStyle(
                                  //     color: Colors.grey[500],
                                  //     fontSize: 12,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Gap(8),
                      ],
                    ),
                  ),
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GlobalButton(
                        text: "Submit",
                        onPressed: _startTracking,
                        // onPressed: _uploadDocument,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
