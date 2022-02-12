class StatusData {
  late String status;
  late String user;

  StatusData({required this.status, required this.user});

  StatusData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['user'] = this.user;
    return data;
  }
}
