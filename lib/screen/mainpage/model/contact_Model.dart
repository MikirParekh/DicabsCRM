class ContactList {
  List<Data>? data;
  String? message;
  bool? completed;

  ContactList({this.data, this.message, this.completed});

  ContactList.fromJson(Map<String, dynamic> json) {
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
  String? code;
  String? name;
  String? type;

  Data({this.code, this.name, this.type});

  Data.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    name = json['Name'];
    type = json['Type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Name'] = this.name;
    data['Type'] = this.type;
    return data;
  }
}
