import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../../app.dart';

class ProfileUserScreen extends StatefulWidget {
  @override
  _ProfileUserScreenState createState() => _ProfileUserScreenState();
}

class _ProfileUserScreenState extends State<ProfileUserScreen> {
  var id;
  var name;
  var email;
  var doctor;
  var role;
  bool isOpen = false;
  bool _secureText = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  var password;
  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
    );
    _scaffoldKey.currentState!.showSnackBar(snackBar);
    setState(() {
      isOpen = false;
    });
  }

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);

    if (user != null) {
      setState(() {
        id = user['id'];
        name = user['name'];
        email = user['email'];
        doctor = user['doctor']['name'];
        role = user['role'];
      });
    } else {
      doctor = "\t don't yet";
    }
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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  child: Container(
                width: double.infinity,
                height: 350.0,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/images/doctor.jpg"),
                        radius: 50.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "$name",
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "$email",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 5.0),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 22.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "your doctor",
                                      style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      "$doctor",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Questions",
                                      style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      "6",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Answers",
                                      style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      "4",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
              SizedBox(
                height: 20.0,
              ),
              isOpen
                  ? Form(
                      key: _formKey,
                      child: Container(
                        margin: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.only(top: 60, left: 20, right: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Enter the new Password",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                                cursorColor: Colors.teal,
                                keyboardType: TextInputType.text,
                                obscureText: _secureText,
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  suffixIcon: IconButton(
                                    onPressed: showHide,
                                    icon: Icon(_secureText
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                  ),
                                ),
                                validator: (passwordValue) {
                                  if (passwordValue!.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  password = passwordValue;
                                  return null;
                                }),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                FlatButton(
                                  child: Text('cancel'),
                                  onPressed: () {
                                    setState(() {
                                      isOpen = false;
                                    });
                                  },
                                ),
                                FlatButton(
                                  child: Text("send"),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      changePassword();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : RaisedButton(
                      onPressed: () {
                        setState(() {
                          isOpen = true;
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      elevation: 0.0,
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [Colors.teal, Colors.teal]),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: 200.0, minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Chenge Password",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      )),
            ],
          ),
        ),
      ),
    );
  }

  changePassword() async {
    // setState(() {
    //   isOpen = true;
    // });
    var data = {'password': password};
    print('the new pass is:' + password);
    String url = 'https://clinicunapp.herokuapp.com/public/api/users/password';
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
    token = json.decode(res.body)['token'];
    var user = json.decode(res.body)['user'];
    var message = json.decode(res.body)['message'];
    var errors = json.decode(res.body)['errors'];
    if (res.statusCode == 200) {
      if (message != null) {
        print(res.body);
        _showMsg(message);
      }
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(token));
      localStorage.setString('user', json.encode(user));
      switch (user['role']) {
        case "patient":
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
              builder: (context) => DashboardUserScreen(),
            ),
          );
          break;
        case "doctor":
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => DashboardDoctorScreen()),
          );
          break;
        default:
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => DashboardAdminScreen()),
          );
          break;
      }
    } else {
      if (errors != null) {
        if (errors['text'] != null) {
          _showMsg(errors['text'][0].toString());
        }
      }
      _showMsg(message);
    }

    setState(() {
      isOpen = false;
    });
  }
}
