import 'dart:convert';
import 'package:http/http.dart' as http;
// my imports
import '../../app.dart';

// Future<List<Question>> fetchProducts() async {
//   try {
//     var res = await Network().getData('/questions');
//     var responseJson = json.decode(res.body);
//     print(responseJson);
//     return (responseJson as List).map((p) => Question.fromJson(p)).toList();
//   } finally {
//     //...
//   }
// }
