import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/customewidget/global_button.dart';
import 'package:dicabs/screen/mainpage/model/add_contact_model.dart';
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:flutter/material.dart';

class AddContactBottomView extends StatefulWidget {
  const AddContactBottomView({super.key});

  @override
  State<AddContactBottomView> createState() => _AddContactBottomViewState();
}

class _AddContactBottomViewState extends State<AddContactBottomView> {
  final Map<String, TextEditingController> controllers = {};
  final Map<String, FocusNode> focusNodes = {};

  final List<String> fields = [
    "companyName",
    "contactName",
    "Phone",
    "Mobile",
    "Email",
  ];

  @override
  void initState() {
    super.initState();
    for (var field in fields) {
      controllers[field] = TextEditingController();
      focusNodes[field] = FocusNode();
    }
  }

  @override
  dispose() {
    for (var field in fields) {
      controllers[field]?.clear();
      focusNodes[field]?.unfocus();
      controllers[field]?.dispose();
      focusNodes[field]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const Text(
                      "New Contact Details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("information",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600))),
                    FormField(
                      labelText: "Company Name",
                      hintText: "Enter Company Name",
                      controller: controllers['companyName'],
                      focusNode: focusNodes['companyName'],
                    ),
                    FormField(
                      labelText: "Contact Name",
                      hintText: "Enter Contact Name",
                      controller: controllers['contactName'],
                      focusNode: focusNodes['contactName'],
                    ),
                    FormField(
                      labelText: "Phone",
                      hintText: "Enter Phone",
                      controller: controllers['Phone'],
                      focusNode: focusNodes['Phone'],
                      keyboardType: TextInputType.phone,
                    ),
                    FormField(
                      labelText: "Mobile",
                      hintText: "Enter Mobile",
                      controller: controllers['Mobile'],
                      focusNode: focusNodes['Mobile'],
                      keyboardType: TextInputType.phone,
                    ),
                    FormField(
                      labelText: "Email",
                      hintText: "Enter Email",
                      controller: controllers['Email'],
                      focusNode: focusNodes['Email'],
                    ),
                    // const SizedBox(height: 10),
                    // const Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text("Other",
                    //         style: TextStyle(
                    //             fontSize: 16, fontWeight: FontWeight.w600))),
                    // FormField(
                    //   labelText: "Street 1",
                    //   hintText: "Enter Street 1",
                    //   controller: controllers['Street 1'],
                    //   focusNode: focusNodes['Street 1'],
                    // ),
                    // FormField(
                    //   labelText: "Street 2",
                    //   hintText: "Enter Street 2",
                    //   controller: controllers['Street 2'],
                    //   focusNode: focusNodes['Street 2'],
                    // ),
                    // FormField(
                    //   labelText: "City",
                    //   hintText: "Enter City",
                    //   controller: controllers['City'],
                    //   focusNode: focusNodes['City'],
                    // ),
                    // FormField(
                    //   labelText: "State",
                    //   hintText: "Enter State",
                    //   controller: controllers['State'],
                    //   focusNode: focusNodes['State'],
                    // ),
                    // FormField(
                    //   labelText: "Country",
                    //   hintText: "Enter Country",
                    //   controller: controllers['Country'],
                    //   focusNode: focusNodes['Country'],
                    // ),
                    // FormField(
                    //   labelText: "Pin Code",
                    //   hintText: "Enter Pin Code",
                    //   controller: controllers['Pin Code'],
                    //   focusNode: focusNodes['Pin Code'],
                    // ),
                    // FormField(
                    //   labelText: "Date Of Birth",
                    //   hintText: "Select Date",
                    //   controller: controllers['Date Of Birth'],
                    //   focusNode: focusNodes['Date Of Birth'],
                    //   keyboardType: TextInputType.none,
                    //   onTap: () async {
                    //     DateTime? pickedDate = await showDatePicker(
                    //       context: context,
                    //       initialDate: DateTime.now(),
                    //       firstDate: DateTime(2000),
                    //       lastDate: DateTime(2101),
                    //     );
                    //     if (pickedDate != null) {
                    //       // dueDateController.text =
                    //       //     DateFormat('yyyy-MM-dd HH:mm:ss')
                    //       //         .format(pickedDate);
                    //     }
                    //   },
                    // ),
                    // Row(
                    //   children: [
                    //     const Text(
                    //       "Gender",
                    //       style: TextStyle(
                    //           fontSize: 16, fontWeight: FontWeight.w600),
                    //     ),
                    //     const Spacer(),
                    //     Radio(
                    //       value: 1,
                    //       groupValue: _genderSelected,
                    //       // activeColor: Colors.blue,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _genderSelected = value!;
                    //           _radioVal = 'male';
                    //         });
                    //       },
                    //     ),
                    //     const Text('Male',
                    //         style: TextStyle(
                    //             fontSize: 14, fontWeight: FontWeight.w600)),
                    //     Radio(
                    //       value: 2,
                    //       groupValue: _genderSelected,
                    //       // activeColor: Colors.pink,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _genderSelected = value!;
                    //           _radioVal = 'female';
                    //         });
                    //       },
                    //     ),
                    //     const Text('Female',
                    //         style: TextStyle(
                    //             fontSize: 14, fontWeight: FontWeight.w600)),
                    //   ],
                    // ),
                    // Row(
                    //   children: [
                    //     const Text(
                    //       "Marketing \nMaterial",
                    //       style: TextStyle(
                    //           fontSize: 16, fontWeight: FontWeight.w600),
                    //     ),
                    //     // const SizedBox(
                    //     //   width: 50,
                    //     // ),
                    //     const Spacer(),
                    //     Radio(
                    //       value: 1,
                    //       groupValue: _mmSelected,
                    //       // activeColor: Colors.blue,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _mmSelected = value!;
                    //           _radioVal = 'send';
                    //         });
                    //       },
                    //     ),
                    //     const Text('Send',
                    //         style: TextStyle(
                    //             fontSize: 14, fontWeight: FontWeight.w600)),
                    //     Radio(
                    //       value: 2,
                    //       groupValue: _mmSelected,
                    //       // activeColor: Colors.pink,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _mmSelected = value!;
                    //           _radioVal = 'do not send';
                    //         });
                    //       },
                    //     ),
                    //     const Text('Do not send',
                    //         style: TextStyle(
                    //             fontSize: 14, fontWeight: FontWeight.w600)),
                    //   ],
                    // ),
                    const SizedBox(height: 10),
                    GlobalButton(
                        text: "Save",
                        onPressed: () async {
                          showLog(msg: "Add contact : Save Button Clicked");
                          await submitNewContact();
                          Navigator.pop(context);
                        })
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> submitNewContact() async {
    final model = AddContactModel(
      companyName: controllers['companyName']?.text,
      contactName: controllers['contactName']?.text,
      phone: controllers['Phone']?.text,
      mobile: controllers['Mobile']?.text,
      email: controllers['Email']?.text,
    );

    await MainPageRepository().addNewContact(model);
  }
}

class FormField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final TextInputType keyboardType;

  const FormField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    this.onTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            labelText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        TextField(
          onTap: onTap,
          keyboardType: keyboardType,
          focusNode: focusNode,
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
