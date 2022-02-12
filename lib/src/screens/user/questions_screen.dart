import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../../app.dart';

class QuestionsScreen extends StatefulWidget {
  final Question question;
  final int user_id;

  const QuestionsScreen(
      {Key? key, required this.question, required this.user_id})
      : super(key: key);
  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var answer;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
    );
    _scaffoldKey.currentState!.showSnackBar(snackBar);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
            builder: (context) => DashboardUserScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 72),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.question.question}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 48),
                        Card(
                          color: Colors.grey[100],
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: TextFormField(
                                cursorColor: Colors.teal,
                                keyboardType: TextInputType.multiline,
                                maxLines: 8,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter your answer",
                                ),
                                validator: (answerValue) {
                                  if (answerValue!.isEmpty) {
                                    return 'Please enter your answer';
                                  }
                                  answer = answerValue;
                                  return null;
                                }),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: FlatButton(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              child: Text(
                                _isLoading ? 'Proccessing..' : 'Send',
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            color: Colors.teal,
                            disabledColor: Colors.grey,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _sendMsg();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendMsg() async {
    setState(() {
      _isLoading = true;
    });
    var data = {
      'user_id': widget.user_id,
      'question_id': widget.question.id,
      'answer': answer
    };
    String url =
        'https://clinicunapp.herokuapp.com/public/api/questions/answers';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);
    http.Response res = await http.post(
      Uri.parse(url),
      body: jsonEncode(data),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    var message = json.decode(res.body)['message'];
    var errors = json.decode(res.body)['errors'];
    if (res.statusCode == 200) {
      if (message != null) {
        print(res.body);
        _showMsg(message);
      }
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
          builder: (context) => DashboardUserScreen(),
        ),
      );
    } else {
      if (errors != null) {
        if (errors['question_id'] != null) {
          _showMsg(errors['question_id'][0].toString());
        } else if (errors['user_id'] != null) {
          _showMsg(errors['user_id'][0].toString());
        } else if (errors['answer'] != null) {
          _showMsg(errors['answer'][0].toString());
        }
      }
      _showMsg(message);
    }

    setState(() {
      _isLoading = false;
    });
  }
}
