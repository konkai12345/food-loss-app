import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_info.dart';
import '../models/recipe.dart';
import '../utils/error_handler.dart';

abstract class ApiService {
  Future<T> get<T>(String endpoint, Map<String, dynamic>? params);
  Future<T> post<T>(String endpoint, Map<String, dynamic>? data);
}

class ApiServiceImpl implements ApiService {
  static const String baseUrl = 'https://api.example.com';
  static const Duration timeout = Duration(seconds: 30);

  @override
  Future<T> get<T>(String endpoint, Map<String, dynamic>? params) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
      final response = await http.get(uri).timeout(timeout);
      
      if (response.statusCode == 200) {
        return _parseResponse<T>(response.body);
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ApiService.get');
      rethrow;
    }
  }

  @override
  Future<T> post<T>(String endpoint, Map<String, dynamic>? data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return _parseResponse<T>(response.body);
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ApiService.post');
      rethrow;
    }
  }

  T _parseResponse<T>(String responseBody) {
    final json = jsonDecode(responseBody);
    // このメソッドは各APIサービスでオーバーライドされる
    return json as T;
  }
}
