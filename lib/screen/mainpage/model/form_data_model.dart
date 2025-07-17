import 'package:intl/intl.dart';

class AddActivityList {
  String? title;
  String? startDate;
  String? endDate;
  String? assignBy;
  String? assignTo;
  String? taskDetail;
  String? regarding;
  String? category;
  String? priority;
  String? remark;
  int? regardingType;
  String? iPAddress;
  String? browser;
  String? webURL;
  String? modifiedBy;
  String? subject;
  String? message;
  String? taskTo;
  String? type;
  int? taskID;
  String? date;
  String? time;


  AddActivityList(
      {this.title,
        this.startDate,
        this.endDate,
        this.assignBy,
        this.assignTo,
        this.taskDetail,
        this.regarding,
        this.category,
        this.priority,
        this.remark,
        this.regardingType,
        this.iPAddress,
        this.browser,
        this.webURL,
        this.modifiedBy,
        this.subject,
        this.message,
        this.taskTo,
        this.type,
        this.taskID,
        this.date,
        this.time

      });

  AddActivityList.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
    assignBy = json['AssignBy'];
    assignTo = json['AssignTo'];
    taskDetail = json['TaskDetail'];
    regarding = json['Regarding'];
    category = json['Category'];
    priority = json['Priority'];
    remark = json['Remark'];
    regardingType = json['RegardingType'];
    iPAddress = json['IPAddress'];
    browser = json['Browser'];
    webURL = json['WebURL'];
    modifiedBy = json['ModifiedBy'];
    subject = json['Subject'];
    message = json['Message'];
    taskTo = json['TaskTo'];
    type = json['Type'];
    taskID = json['TaskID'];
    date=json['Date'];
    time=json['Time'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Title'] = this.title;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    data['AssignBy'] = this.assignBy;
    data['AssignTo'] = this.assignTo;
    data['TaskDetail'] = this.taskDetail;
    data['Regarding'] = this.regarding;
    data['Category'] = this.category;
    data['Priority'] = this.priority;
    data['Remark'] = this.remark;
    data['RegardingType'] = this.regardingType;
    data['IPAddress'] = this.iPAddress;
    data['Browser'] = this.browser;
    data['WebURL'] = this.webURL;
    data['ModifiedBy'] = this.modifiedBy;
    data['Subject'] = this.subject;
    data['Message'] = this.message;
    data['TaskTo'] = this.taskTo;
    data['Type'] = this.type;
    data['TaskID'] = this.taskID;
    data['Date']=this.date;
    data['Time']=this.time;

    return data;
  }

  String get formattedEndDate {
    if (endDate == null || endDate!.isEmpty) return "N/A";
    try {
      DateTime date = DateFormat('dd/MM/yyyy HH:mm').parse(endDate!);
      return DateFormat('dd MMM yyyy • hh:mm a').format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }
}
