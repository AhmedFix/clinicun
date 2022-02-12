import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../../app.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({
    Key? key,
  }) : super(key: key);
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var status;
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
      child: WillPopScope(
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
                        children: [
                          SizedBox(height: 48),
                          Card(
                            color: Colors.grey[100],
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  cursorColor: Colors.teal,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 10,
                                  decoration: InputDecoration.collapsed(
                                    hintText: "Enter your status",
                                  ),
                                  validator: (statusValue) {
                                    if (statusValue!.isEmpty) {
                                      return 'Please enter your status';
                                    }
                                    status = statusValue;
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
                                  borderRadius:
                                      new BorderRadius.circular(20.0)),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _SendMsg();
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
      ),
    );
  }

  void _SendMsg() async {
    setState(() {
      _isLoading = true;
    });
    var data = {'status': status};
    String url = 'https://clinicunapp.herokuapp.com/public/api/patients/status';
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
        if (errors['text'] != null) {
          _showMsg(errors['text'][0].toString());
        }
      }
      _showMsg(message);
    }

    setState(() {
      _isLoading = false;
    });
  }
}
