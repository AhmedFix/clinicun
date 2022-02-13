import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../../app.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final User doctor;
  const DoctorDetailsScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  _DoctorDetailsScreenState createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool _isLoading = false;
  bool _isSelected = false;
  var msg;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _msgController = new TextEditingController();

  @override
  void initState() {
    _chickDoctorSelect(widget.doctor.name);
    super.initState();
  }

  _chickDoctorSelect(String doctor) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);
    var name = user['doctor']['name'];

    if (widget.doctor.name == name) {
      setState(() {
        _isSelected = true;
      });
    }
  }

  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
    );
    _scaffoldKey.currentState!.showSnackBar(snackBar);
    setState(() {
      _isLoading = false;
      _isSelected = false;
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
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => DashboardUserScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/images/doctor.jpg"),
                    maxRadius: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.doctor.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          widget.doctor.email,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  _isSelected
                      ? IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.done,
                            color: Colors.teal[400],
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            _addDoctor(widget.doctor.id);
                          },
                          icon: Icon(
                            Icons.add,
                            color: Colors.grey[600],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: FutureBuilder<List<ChatMessage>>(
                future: Network.fetchMessagesRequest(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(
                      child: Text(
                        "You do not have messages yet",
                        style: TextStyle(color: Colors.teal),
                      ),
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
      ),
    );
  }

  void _sendMsg() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);
    dynamic user_id;
    setState(() {
      _isLoading = true;
      user_id = user['id'];
    });
    var data = {
      'patient_id': user_id,
      'doctor_id': widget.doctor.id,
      'message': msg
    };
    print('${user_id}//// ${widget.doctor.id}  /////  $msg');
    String url =
        'https://clinicunapp.herokuapp.com/public/api/patients/messages';
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

  void _addDoctor(var doctorId) async {
    setState(() {
      _isSelected = true;
    });
    var data = {'doctor_id': doctorId};
    String url =
        'https://clinicunapp.herokuapp.com/public/api/patients/doctors';
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
    var user = json.decode(res.body)['user'];
    var message = json.decode(res.body)['message'];
    var errors = json.decode(res.body)['errors'];
    if (res.statusCode == 200) {
      if (message != null) {
        print(res.body);
        _showMsg(message);
      }
      localStorage.setString('user', json.encode(user));
    } else {
      if (errors != null) {
        if (errors['doctor_id'] != null) {
          _showMsg(errors['doctor_id'][0].toString());
        }
      }
      _showMsg(message);
    }

    setState(() {
      _isSelected = true;
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
            alignment: (widget.messages![index].messageType == "reciver"
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (widget.messages![index].messageType == "reciver"
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
