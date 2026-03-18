import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  Future<Map<String, dynamic>?> getLinearPoints({
    required double m,
    required double c,
  }) async {
    return _post('/linear/points', {'m': m, 'c': c, 'x_min': -10, 'x_max': 10});
  }

  Future<Map<String, dynamic>?> getQuadraticPoints({
    required double a,
    required double b,
    required double c,
  }) async {
    return _post('/quadratic/points', {'a': a, 'b': b, 'c': c, 'x_min': -10, 'x_max': 10});
  }

  Future<Map<String, dynamic>?> getCircleData(double radius) async {
    return _post('/geometry/circle', {'radius': radius});
  }

  Future<Map<String, dynamic>?> getTriangleData(double base, double height) async {
    return _post('/geometry/triangle', {'base': base, 'height': height});
  }

  Future<Map<String, dynamic>?> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.apiBase}$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Backend unavailable — local computation is primary
    }
    return null;
  }
}
