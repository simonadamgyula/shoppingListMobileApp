import 'dart:convert';

import 'package:http/http.dart' as http;

const apiUrl = "http://192.168.1.93:8001";

Future<dynamic> sendApiRequest(String url, Map<String, dynamic> body,
    {Map<String, String>? headers}) async {
  return http.post(Uri.parse(apiUrl + url), body: jsonEncode(body), headers: {"Content-Type": "application/json"}..addAll(headers ?? {}),);
}
