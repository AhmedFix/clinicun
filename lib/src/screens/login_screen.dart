import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../app.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var email, password;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _secureText = true;

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
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 72),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 18),
                      TextFormField(
                          cursorColor: Colors.teal,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Email",
                          ),
                          validator: (emailValue) {
                            if (emailValue!.isEmpty) {
                              return 'Please enter your email';
                            }
                            email = emailValue;
                            return null;
                          }),
                      SizedBox(height: 12),
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
                      SizedBox(height: 12),
                      FlatButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          child: Text(
                            _isLoading ? 'Proccessing..' : 'Login',
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
                            _login();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Does'nt have an account? ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => RegisterScreen()));
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 16.0,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    var data = {'email': email, 'password': password};

    var res = await Network().auth(data, '/login');
    var token = json.decode(res.body)['token'];
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
      print("The User Name  is:  " +
          user['name'] +
          '\n User Email is :' +
          user['email'] +
          '\n the Role of User is :' +
          user['role']);
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
        if (errors['name'] != null) {
          _showMsg(errors['name'][0].toString());
        } else if (errors['email'] != null) {
          _showMsg(errors['email'][0].toString());
        } else if (errors['password'] != null) {
          _showMsg(errors['password'][0].toString());
        } else if (errors['password_confirmation'] != null) {
          _showMsg(errors['password_confirmation'][0].toString());
        }
      }
      _showMsg(message);
    }

    setState(() {
      _isLoading = false;
    });
  }
}
