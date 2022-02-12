class AnswerQuestion {
  late int id;
  late String answer;
  late String question;

  AnswerQuestion(
      {required this.id, required this.answer, required this.question});

  AnswerQuestion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    answer = json['answer'];
    question = json['question'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['answer'] = this.answer;
    data['question'] = this.question;
    return data;
  }
}
