class CategoryList {
  List<Data>? data;
  String? message;
  bool? completed;

  CategoryList({this.data, this.message, this.completed});

  CategoryList.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <Data>[];
      json['Data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  int? activityCategoryID;
  String? ref;
  String? categoryName;

  Data({this.activityCategoryID, this.ref, this.categoryName});

  Data.fromJson(Map<String, dynamic> json) {
    activityCategoryID = json['ActivityCategoryID'];
    ref = json['Ref'];
    categoryName = json['CategoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ActivityCategoryID'] = this.activityCategoryID;
    data['Ref'] = this.ref;
    data['CategoryName'] = this.categoryName;
    return data;
  }
}
