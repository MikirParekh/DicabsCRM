class DashboardList {
  List<DashboardModel>? data;
  String? message;
  bool? completed;

  DashboardList({this.data, this.message, this.completed});

  DashboardList.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <DashboardModel>[];
      json['Data'].forEach((v) {
        data!.add(new DashboardModel.fromJson(v));
      });
    }
    message = json['Message'];
    completed = json['Completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['Message'] = this.message;
    data['Completed'] = this.completed;
    return data;
  }
}

class DashboardModel {
  int? iD;
  String? subject;
  int? regardingType;
  String? regarding;
  String? regardingName;
  String? remark;
  String? opportunityNo;
  String? category;
  int? activityType;
  String? taskStatus;
  String? salesPerson;
  String? to;
  String? creationDate;
  String? createdOn;

  DashboardModel(
      {this.iD,
        this.subject,
        this.regardingType,
        this.regarding,
        this.regardingName,
        this.remark,
        this.opportunityNo,
        this.category,
        this.activityType,
        this.taskStatus,
        this.salesPerson,
        this.to,
        this.creationDate,
        this.createdOn});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    subject = json['Subject'];
    regardingType = json['RegardingType'];
    regarding = json['Regarding'];
    regardingName = json['RegardingName'];
    remark = json['Remark'];
    opportunityNo = json['OpportunityNo'];
    category = json['Category'];
    activityType = json['ActivityType'];
    taskStatus = json['TaskStatus'];
    salesPerson = json['SalesPerson'];
    to = _stripHtml(json['To']);
    creationDate = json['CreationDate'];
    createdOn = json['CreatedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['Subject'] = this.subject;
    data['RegardingType'] = this.regardingType;
    data['Regarding'] = this.regarding;
    data['RegardingName'] = this.regardingName;
    data['Remark'] = this.remark;
    data['OpportunityNo'] = this.opportunityNo;
    data['Category'] = this.category;
    data['ActivityType'] = this.activityType;
    data['TaskStatus'] = this.taskStatus;
    data['SalesPerson'] = this.salesPerson;
    data['To'] = this.to;
    data['CreationDate'] = this.creationDate;
    data['CreatedOn'] = this.createdOn;
    return data;
  }

  static String _stripHtml(dynamic htmlString){
    if(htmlString==null) return '';
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlString.toString().replaceAll(regex, '').trim();
  }
}
