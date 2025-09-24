// To parse this JSON data, do
//
//     final addContactModel = addContactModelFromJson(jsonString);

import 'dart:convert';

AddContactModel addContactModelFromJson(String str) =>
    AddContactModel.fromJson(json.decode(str));

String addContactModelToJson(AddContactModel data) =>
    json.encode(data.toJson());

class AddContactModel {
  String? companyName;
  String? contactName;
  String? phone;
  String? mobile;
  String? email;

  AddContactModel({
    this.companyName,
    this.contactName,
    this.phone,
    this.mobile,
    this.email,
  });

  factory AddContactModel.fromJson(Map<String, dynamic> json) =>
      AddContactModel(
        companyName: json["companyName"],
        contactName: json["contactName"],
        phone: json["phone"],
        mobile: json["mobile"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "companyName": companyName,
        "contactName": contactName,
        "phone": phone,
        "mobile": mobile,
        "email": email,
      };
}
