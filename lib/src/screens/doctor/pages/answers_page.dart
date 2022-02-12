import 'package:flutter/material.dart';
// my imports
import '../../../../app.dart';

class AnswersPage extends StatefulWidget {
  final int userId;
  final Future<List<AnswerQuestion>> question;
  const AnswersPage({Key? key, required this.question, required this.userId})
      : super(key: key);

  @override
  _AnswersPageState createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
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
        await Network.fetchAnswersRequest(widget.userId);
        setState(
          () {},
        );
      },
      child: Material(
        child: Center(
          child: FutureBuilder<List<AnswerQuestion>>(
            future: widget.question,
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
                          await Network.fetchAnswersRequest(widget.userId);
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
                    ? _BuildAnswersItemsBody(
                        answers: snapshot.data,
                        userId: widget.userId,
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
      ),
    );
  }
}

class _BuildAnswersItemsBody extends StatefulWidget {
  final int userId;
  final List<AnswerQuestion>? answers;
  const _BuildAnswersItemsBody(
      {Key? key, required this.answers, required this.userId})
      : super(key: key);

  @override
  __BuildAnswersItemsBodyState createState() => __BuildAnswersItemsBodyState();
}

class __BuildAnswersItemsBodyState extends State<_BuildAnswersItemsBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(bottom: 10),
        child: ListView.builder(
            itemCount: widget.answers!.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                        title: Text(widget.answers![index].question),
                        subtitle: Text(widget.answers![index].answer)),
                  ),
                ),
              );
            }));
  }
}
