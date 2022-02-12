import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../app.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _secureText = true;
  late String name, email, password, confirmPassword;

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
                        "Register",
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
                            hintText: "Full Name",
                          ),
                          validator: (nameValue) {
                            if (nameValue!.isEmpty) {
                              return 'Please enter your full name';
                            }
                            name = nameValue;
                            return null;
                          }),
                      SizedBox(height: 12),
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
                      TextFormField(
                          cursorColor: Colors.teal,
                          keyboardType: TextInputType.text,
                          obscureText: _secureText,
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            suffixIcon: IconButton(
                              onPressed: showHide,
                              icon: Icon(_secureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                          validator: (confirmPasswordValue) {
                            if (confirmPasswordValue!.isEmpty) {
                              return 'Please Confirm password';
                            }
                            confirmPassword = confirmPasswordValue;
                            return null;
                          }),
                      SizedBox(height: 12),
                      FlatButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          child: Text(
                            _isLoading ? 'Proccessing..' : 'Register',
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
                            _register();
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
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    child: Text(
                      'Login',
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

  void _register() async {
    setState(() {
      _isLoading = true;
    });
    var data = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword
    };

    var res = await Network().auth(data, '/register');
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

    setState(() {
      _isLoading = false;
    });
  }
}
