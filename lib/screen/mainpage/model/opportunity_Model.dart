class OpportunityList {
  List<Data>? data;
  String? message;
  bool? completed;

  OpportunityList({this.data, this.message, this.completed});

  OpportunityList.fromJson(Map<String, dynamic> json) {
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
  String? no;
  String? searchName;

  Data({this.no, this.searchName});

  Data.fromJson(Map<String, dynamic> json) {
    no = json['No_'];
    searchName = json['Search Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['No_'] = this.no;
    data['Search Name'] = this.searchName;
    return data;
  }
}
