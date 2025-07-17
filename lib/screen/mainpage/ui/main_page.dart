import 'package:dicabs/customewidget/global_dropdown.dart';
import 'package:dicabs/customewidget/global_text_field.dart';
import 'package:dicabs/screen/mainpage/widgets/category_bottom_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
  List<AddActivityList> originalData=[];
  List<AddActivityList> filteredData=[];
  final MethodChannel platform = const MethodChannel('com.uniqtech.dicabs/tracking');

  bool isLoading = false;
  List<String>selectedTaskMembers=[];

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
          print("❌ Location fetch failed: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to get location")),
          );
          setState(() => isLoading = false);
          return;
        }
      }

      print("📍 Sending Lat: $globalLatitude, Long: $globalLongitude");

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
        await submit.submitForm(model, widget.userCode, widget.salesCode);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submit Successful')),
        );
        Navigator.pop(context);
      } catch (error) {
        print("❌ Submit error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submit Failed')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
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
      // backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return TaskMemberBottomView(
            onTaskMemberSelected: (List<String>taskMembers){
              setState(() {
                selectedTaskMembers=taskMembers;
                selectedTaskMember.text=taskMembers.join(',');
              });
              // Navigator.pop(context);
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("  Add Activity"),
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
                            if (pickedDate != null) {
                              dueDateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedDate);

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
                              children: selectedTaskMembers.map((member){
                                return Chip(
                                  label: Text(member),
                                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                  backgroundColor: Colors.blueAccent,
                                  avatar: const Icon(Icons.person,color: Colors.white,size:18 ),
                                  onDeleted: (){
                                    setState(() {
                                      selectedTaskMembers.remove(member);
                                      selectedTaskMember.text=selectedTaskMembers.join(',');
                                    });
                                  },
                                );
                              }).toList(),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GlobalButton(
                  text: "Submit",
                  onPressed: _startTracking,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

