import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../app.dart';

class ItemUserWidget extends StatefulWidget {
  final Future<List<User>> users;
  const ItemUserWidget({Key? key, required this.users}) : super(key: key);

  @override
  _ItemUserWidgetState createState() => _ItemUserWidgetState();
}

class _ItemUserWidgetState extends State<ItemUserWidget> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 250,
      backgroundColor: Colors.teal,
      color: Colors.white,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        await Network.fetchQuestionsRequest();
        setState(() {});
      },
      child: Material(
        child: Center(
          child: FutureBuilder<List<User>>(
            future: widget.users,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Check your internet Connection and try again",
                      style: TextStyle(color: Colors.red),
                    ),
                    IconButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await Network.fetchQuestionsRequest();
                          setState(() {
                            isLoading = false;
                          });
                        },
                        icon: isLoading
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
                    ? _BuildUsersItemsBody(users: snapshot.data)
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
      ),
    );
  }
}

class _BuildUsersItemsBody extends StatefulWidget {
  final List<User>? users;
  const _BuildUsersItemsBody({Key? key, required this.users}) : super(key: key);

  @override
  __BuildUsersItemsBodyState createState() => __BuildUsersItemsBodyState();
}

class __BuildUsersItemsBodyState extends State<_BuildUsersItemsBody> {
  bool _isLoading = false;
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
      body: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: ListView.builder(
              itemCount: widget.users!.length,
              itemBuilder: (context, index) {
                User user = widget.users![index];
                return InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => UserListScreen(user: user)),
                    );
                  },
                  child: Card(
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage("assets/images/doctor.jpg"),
                              maxRadius: 25,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(widget.users![index].name),
                          ],
                        )),
                  ),
                );
              })),
    );
  }
}
