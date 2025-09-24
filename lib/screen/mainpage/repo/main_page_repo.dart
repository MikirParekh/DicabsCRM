import 'dart:convert';
import 'dart:io';
import 'package:dicabs/ALLURL.dart';
import 'package:dicabs/SharedPreference.dart';
import 'package:dicabs/core/show_log.dart';
import 'package:dicabs/screen/dashboard/model/dashboard_Model.dart';
import 'package:dicabs/screen/mainpage/model/add_contact_model.dart';
import 'package:dicabs/screen/mainpage/model/form_data_model.dart';
import 'package:dicabs/screen/mainpage/model/opportunity_Model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/demo_location_Model.dart';

class MainPageRepository {
  Future<List<String>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/GetCategory');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['Data'];

      return data.map((item) => item['CategoryName'] as String).toList();
    } else {
      throw Exception('Failed to load categories:${response.reasonPhrase}');
    }
  }

  Future<List<DashboardModel>> fetchDeshboard(
      String userCode, String salesCode) async {
    final url = Uri.parse(
        '$baseUrl/GetActivity?userCode=$userCode&salesCode=$salesCode');

    showLog(msg: "fetchDeshboard ----> $url");

    final response = await http.get(url);

    showLog(msg: "dashboard data response ----> ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final dashboard = DashboardList.fromJson(jsonBody);
      return dashboard.data ?? [];

      //form submit vada pr jai ne submit kr
    } else {
      throw Exception('Failed to load Deshboard Data:${response.reasonPhrase}');
    }
  }

  Future<List<String>> fetchContactDetails() async {
    final url = Uri.parse('$baseUrl/GetCustomerContact');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['Data'];

      final List<String> filteredContacts = data.where((item) {
        final rawName = item['Name'] ?? "";
        final name = rawName.trim();

        // Exclude blank names and names starting with a digit (likely phone numbers)
        return name.isNotEmpty && name != "~ Contact";
      }).map<String>((item) {
        return item['Name']?.trim() ?? "";
      }).toList();

      return filteredContacts;
    } else {
      throw Exception('Failed to load Categories: ${response.reasonPhrase}');
    }
  }

  Future<OpportunityList> fetchOpportunity() async {
    final url = Uri.parse('$baseUrl/GetRegarding');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final res = json.decode(response.body);

      showLog(msg: "fetchOpportunity response -----> ${response.body}");

      // return res;
      return OpportunityList.fromJson(res);
    } else {
      throw Exception(
          'Failed to load Opportunity Data:${response.reasonPhrase}');
    }
  }

  Future<List<String>> fetchTaskMember() async {
    final url = Uri.parse('$baseUrl/GetCustomerContact');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> data = jsonBody['Data'];

      final salesPersons = data
          .where((item) => item['Type'] == "3")
          .map((item) => item['Name'] as String)
          .toList();
      return salesPersons;

      // return data.map((item) => item['Name'] as String).toList();
    } else {
      throw Exception('Failed to load Task Member:${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> submitForm(
    AddActivityList addActivityList,
    String userCode,
    String salesCode,
    List<File> selectedFiles,
  ) async {
    final requestBody = {
      "Title": addActivityList.title,
      "EndDate": addActivityList.endDate,
      "Category": addActivityList.category,
      "Message": addActivityList.message,
      "Remark": addActivityList.remark,
      "Regarding": addActivityList.regarding,
      "AssignBy": addActivityList.assignBy,
      "TaskTo": addActivityList.taskTo
    };

    logBlue(msg: "submitForm request body ------> $requestBody");

    final headers = {'Content-Type': 'application/json'};

    final url = Uri.parse('$baseUrl/AddActivity');

    showLog(msg: "$baseUrl/AddActivity");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    logGreen(msg: "submit form response ---> ${response.body}");

    final userCODE = await StorageManager.readData("userCode");

    if (response.statusCode == 200) {
//sample response
//       {
//     "Data": 9477, ---> parse this in doc api
//     "Message": "Activity added successfully.",
//     "Completed": true

      showLog(msg: "submit form response ---> ${response.body}");

      var data = jsonDecode(response.body);

// }

      var uploadFileResponse = await uploadFile(
          taskid: data['Data'].toString(),
          userCode: userCODE,
          selectedFiles: selectedFiles);

      return jsonDecode(uploadFileResponse);
    } else {
      logRed(msg: "submit form error ---> ${response.body}");
      throw Exception('Failed to submit form: ${response.statusCode}');
    }
  }

  static Future<LocationResponse?> postLocation({
    required String userCode,
    required String latitude,
    required String longitude,
  }) async {
    final url = Uri.parse('http://180.211.118.210:90/api/Home/v1/Location');

    final entryDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    showLog(msg: "entryDate ---> $entryDate");

    final Map<String, dynamic> body = {
      'Usercode': userCode,
      'Latitude': latitude,
      'Longitude': longitude,
      'EntryDate': entryDate,
    };

    try {
      // showLog(msg: "Post Location body -----> ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // showLog(msg: "post location response ---> ${response.body}");

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        return LocationResponse.fromJson(responseJson);
      } else {
        showLog(msg: '❌ Failed: ${response.statusCode} | ${response.body}');
        return null;
      }
    } catch (e) {
      showLog(msg: 'Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> addNewContact(
      AddContactModel addContactModel) async {
    try {
      final requestBody = {
        "companyName": addContactModel.companyName,
        "contactName": addContactModel.contactName,
        "phone": addContactModel.phone,
        "mobile": addContactModel.mobile,
        "email": addContactModel.email,
      };

      logGreen(msg: "addContact request body ------> $requestBody");

      final headers = {'Content-Type': 'application/json'};

      final url = Uri.parse('$baseUrl/');

      showLog(msg: "$baseUrl/"); //TODO: need to change api endpoint

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        logRed(msg: "add contact error ---> ${response.body}");
        throw Exception('Failed to addContact ${response.statusCode}');
      }
    } catch (e) {
      logRed(msg: "add contact error ---> $e");
      throw Exception('Failed to addContact $e');
    }
  }

  // TODO: need to implement proper logic
  /// upload file
  ///
  ///
  /// TODO: Max 5 files
  ///
  ///
  Future<String> uploadFile({
    required String taskid,
    required String userCode,
    required List<File> selectedFiles,
  }) async {
    try {
      // Construct the URL with the activityId
      var url = Uri.parse('http://192.168.3.50:89/api/Home/v1/uploadmultiple');
      // var url = Uri.parse('$baseUrl/uploadmultiple');
      showLog(msg: "url ---> $url");

      var request = http.MultipartRequest('POST', url);

      request.fields['taskID'] = taskid;
      request.fields['userCode'] = userCode;

      // Add files to the request
      for (var i = 0; i < selectedFiles.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "files", // The field name for the file on the server
            selectedFiles[i].path,
            filename: selectedFiles[i]
                .path
                .split('/')
                .last, // Get file name from path
          ),
        );
      }

      for (var file in selectedFiles) {
        final fileSizeBytes = await file.length();
        final fileSizeMB = (fileSizeBytes / (1024 * 1024))
            .toStringAsFixed(2); // 2 decimal places
        showLog(
            msg:
                "Preparing to upload ${file.path.split('/').last} ($fileSizeMB MB)");
      }

      for (var f in request.files) {
        showLog(msg: "Added file -> ${f.filename}, length: ${f.length}");
      }

      showLog(msg: "upload file request fields ---> ${request.fields}");
      showLog(
          msg:
              "upload file request files ---> ${request.files.map((e) => e.filename)}");

      showLog(msg: "upload file request body ---> ${request.fields}");

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      showLog(
          msg: "upload file response status code ---> ${response.statusCode}");
      showLog(msg: "upload file response body ---> $responseBody");

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to upload files: ${response.statusCode} - $responseBody');
      }

      return responseBody;
    } catch (e) {
      showLog(msg: "Error uploading file: $e");
      throw Exception('Failed to upload files: $e');
    }
  }
}
