class ChatMessage {
  late int id;
  late String message;
  late int doctorId;
  late int patientId;
  late String messageType;

  ChatMessage(
      {required this.id,
      required this.message,
      required this.doctorId,
      required this.patientId,
      required this.messageType});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    doctorId = json['doctor_id'];
    patientId = json['patient_id'];
    messageType = json['message_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message'] = this.message;
    data['doctor_id'] = this.doctorId;
    data['patient_id'] = this.patientId;
    data['message_type'] = this.messageType;
    return data;
  }
}
