import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../../../app.dart';

class StatusPage extends StatefulWidget {
  final User user;
  const StatusPage({Key? key, required this.user}) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  late Future<Status> status;

  @override
  void initState() {
    super.initState();
    status = Network.fetchStatus(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FutureBuilder<Status>(
          future: status,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.status);
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text(
                "This User Don\' have status yet",
                style: TextStyle(color: Colors.red),
              );
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class _BuildStatusItemsBody extends StatefulWidget {
  final User user;
  final StatusData? status;
  const _BuildStatusItemsBody(
      {Key? key, required this.status, required this.user})
      : super(key: key);

  @override
  __BuildStatusItemsBodyState createState() => __BuildStatusItemsBodyState();
}

class __BuildStatusItemsBodyState extends State<_BuildStatusItemsBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(widget.status!.status),
      ),
    );
  }
}
