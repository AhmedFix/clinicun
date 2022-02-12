import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../../../app.dart';

class ChatPage extends StatefulWidget {
  final User user;
  const ChatPage({Key? key, required this.user}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isLoading = false;
  var msg;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _msgController = new TextEditingController();
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
    return Material(
      child: Stack(
        children: <Widget>[
          Center(
            child: FutureBuilder<List<ChatMessage>>(
              future: Network.fetchDoctorMessagesRequest(widget.user.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You do not have messages yet",
                        style: TextStyle(color: Colors.red),
                      ),
                      IconButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await Network.fetchQuestionsRequest();
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          icon: _isLoading
                              ? Container(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.red,
                                    color: Colors.red[300],
                                  ),
                                )
                              : Icon(
                                  Icons.refresh_outlined,
                                  color: Colors.red,
                                  size: 35,
                                ))
                    ],
                  );
                } else {
                  return snapshot.hasData
                      ? _BuildQuestionsItemsBody(
                          messages: snapshot.data,
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.teal,
                            color: Colors.teal[300],
                          ),
                        );
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextFormField(
                          controller: _msgController,
                          decoration: InputDecoration(
                            hintText: "Write message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                          validator: (msgValue) {
                            if (msgValue!.isEmpty) {
                              return 'Please enter your message';
                            } else if (msgValue.length < 5) {
                              return 'The message must be at least 5 characters';
                            }
                            msg = msgValue;
                            return null;
                          }),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _sendMsg();
                        }
                      },
                      child: _isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                color: Colors.grey[100],
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                      backgroundColor: Colors.teal,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMsg() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);
    var userId;
    setState(() {
      _isLoading = true;
      userId = user['id'];
    });
    var data = {
      'patient_id': widget.user.id,
      'doctor_id': userId,
      'message': msg
    };
    print(
        'the doctor id is:${userId} \n the user id is: ${widget.user.id} \n the doctor msg is:  $msg');
    String url =
        'https://clinicunapp.herokuapp.com/public/api/doctors/patients/messages';
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
    print(res.body);
    _msgController.clear();
    setState(() {
      _isLoading = false;
    });
    var message = json.decode(res.body)['message'];
    if (res.statusCode == 200) {
      if (message != null) {
        print(res.body);
        _showMsg(message);
      }
      setState(() {});
    } else {
      _showMsg(message);
    }

    setState(() {
      _isLoading = false;
    });
  }
}

class _BuildQuestionsItemsBody extends StatefulWidget {
  final List<ChatMessage>? messages;
  const _BuildQuestionsItemsBody({Key? key, this.messages}) : super(key: key);

  @override
  __BuildQuestionsItemsBodyState createState() =>
      __BuildQuestionsItemsBodyState();
}

class __BuildQuestionsItemsBodyState extends State<_BuildQuestionsItemsBody> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.messages!.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 10, bottom: 55),
      // physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
          child: Align(
            alignment: (widget.messages![index].messageType == "sender"
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (widget.messages![index].messageType == "sender"
                    ? Colors.grey.shade200
                    : Colors.teal[200]),
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                widget.messages![index].message,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }
}
