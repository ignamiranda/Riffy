import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  final http.Client _client = http.Client();

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    return _client.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(String url, {Map<String, String>? headers, Object? body}) async {
    return _client.post(Uri.parse(url), headers: headers, body: body);
  }

  void dispose() {
    _client.close();
  }
}
