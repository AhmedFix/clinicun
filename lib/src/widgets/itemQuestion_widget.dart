import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// my imports
import '../../app.dart';

class ItemQuestionWidget extends StatefulWidget {
  final int user_id;
  final Future<List<Question>> question;
  const ItemQuestionWidget(
      {Key? key, required this.question, required this.user_id})
      : super(key: key);

  @override
  _ItemQuestionWidgetState createState() => _ItemQuestionWidgetState();
}

class _ItemQuestionWidgetState extends State<ItemQuestionWidget> {
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
        setState(
          () {},
        );
      },
      child: Material(
        child: Center(
          child: FutureBuilder<List<Question>>(
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
                    ? _BuildQuestionsItemsBody(
                        questions: snapshot.data,
                        user_id: widget.user_id,
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

class _BuildQuestionsItemsBody extends StatefulWidget {
  final int user_id;
  final List<Question>? questions;
  const _BuildQuestionsItemsBody(
      {Key? key, required this.questions, required this.user_id})
      : super(key: key);

  @override
  __BuildQuestionsItemsBodyState createState() =>
      __BuildQuestionsItemsBodyState();
}

class __BuildQuestionsItemsBodyState extends State<_BuildQuestionsItemsBody> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  int _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.questions!.isEmpty
        ? Material(
            child: IndexedStack(
              index: _stackToView,
              children: [
                Column(
                  children: <Widget>[
                    Expanded(
                        child: WebView(
                      initialUrl: "https://youtu.be/7eiW5KSTQPk",
                      javascriptMode: JavascriptMode.unrestricted,
                      onPageFinished: _handleLoad,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                    )),
                  ],
                ),
                Container(
                    child: Center(
                  child: CircularProgressIndicator(),
                )),
              ],
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.only(bottom: 10),
            child: ListView.builder(
                itemCount: widget.questions!.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => QuestionsScreen(
                            user_id: widget.user_id,
                            question: widget.questions![index],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 12),
                          child: Text(widget.questions![index].question)),
                    ),
                  );
                }));
  }
}
