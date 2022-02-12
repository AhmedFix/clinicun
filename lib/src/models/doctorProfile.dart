class DataPatient {
  late int patients;
  late int messages;

  DataPatient({required this.patients, required this.messages});

  DataPatient.fromJson(Map<String, dynamic> json) {
    patients = json['patients'];
    messages = json['messages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['patients'] = this.patients;
    data['messages'] = this.messages;
    return data;
  }
}
