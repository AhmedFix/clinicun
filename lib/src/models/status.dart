class StatusPatientData {
  int? id;
  String? name;
  String? email;
  Status? status;

  StatusPatientData({this.id, this.name, this.email, this.status});

  StatusPatientData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    return data;
  }
}

class Status {
  late int id;
  late String status;
  late int userId;
  late String createdAt;
  late String updatedAt;

  Status(
      {required this.id,
      required this.status,
      required this.userId,
      required this.createdAt,
      required this.updatedAt});

  Status.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
