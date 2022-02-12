import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// my imports
import '../../app.dart';

class Network {
  static String _url = 'https://clinicunapp.herokuapp.com/public/api';
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token')!);
    print('the token is:  ' + token);
  }

  auth(data, apiURL) async {
    var fullUrl = _url + apiURL;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  setData(data, apiURL) async {
    var fullUrl = _url + apiURL;
    print(fullUrl + "\n" + jsonEncode(data));
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(apiURL) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.get(
      Uri.parse(fullUrl),
      headers: _setHeaders(),
    );
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Future<List<Question>> fetchQuestionsRequest() async {
    var fullUrl = _url + '/questions';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);
    final res = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('the token that sended is: ' + token);
    if (res.statusCode == 200) {
      var responseJson = json.decode(res.body);
      print(responseJson);
      return (responseJson as List).map((b) => Question.fromJson(b)).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  static Future<List<AnswerQuestion>> fetchAnswersRequest(var userId) async {
    var fullUrl = _url + '/doctors/patients/$userId/answers';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);
    final res = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('the token that sended is: ' + token);
    if (res.statusCode == 200) {
      var responseJson = json.decode(res.body)['data'];
      print(responseJson);
      return (responseJson as List)
          .map((b) => AnswerQuestion.fromJson(b))
          .toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  static Future<Status> fetchStatus(var UserId) async {
    var fullUrl = _url + '/doctors/patients/$UserId/show';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);
    final response = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body)['status']);
      return Status.fromJson(jsonDecode(response.body)['status']);
    } else {
      throw Exception('Failed to load status');
    }
  }

  static Future<DataPatient> fetchPetientDataRequest() async {
    var fullUrl = _url + '/doctors/profile';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);
    final response = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return DataPatient.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load status');
    }
  }

  static Future<List<User>> fetchUsersRequest() async {
    var fullUrl = _url + '/doctors/patients/index';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);
    final res = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('the token that sended is: ' + token);
    if (res.statusCode == 200) {
      var responseJson = json.decode(res.body)['patients'];
      print(responseJson);
      return (responseJson as List).map((b) => User.fromJson(b)).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  static Future<List<ChatMessage>> fetchMessagesRequest() async {
    var fullUrl = _url + '/patients/messages';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);

    final res = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('the token that sended is: ' + token);
    if (res.statusCode == 200) {
      var responseJson = json.decode(res.body)['data'];
      print(responseJson);
      return (responseJson as List)
          .map((b) => ChatMessage.fromJson(b))
          .toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  static Future<List<ChatMessage>> fetchDoctorMessagesRequest(
      var userId) async {
    var fullUrl = _url + '/doctors/patients/$userId/messages';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);

    final res = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('the token that sended is: ' + token);
    if (res.statusCode == 200) {
      var responseJson = json.decode(res.body)['data'];
      print(responseJson);
      return (responseJson as List)
          .map((b) => ChatMessage.fromJson(b))
          .toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  static Future<List<User>> fetchDoctorsRequest() async {
    var fullUrl = _url + '/doctors';
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token')!);
    final res = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('the token that sended is: ' + token);
    if (res.statusCode == 200) {
      var responseJson = json.decode(res.body);
      print(responseJson);
      return (responseJson as List).map((b) => User.fromJson(b)).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}
