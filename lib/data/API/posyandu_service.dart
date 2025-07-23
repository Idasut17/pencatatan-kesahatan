import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:flutter_application_1/data/API/BaseURL.dart';

class PosyanduService {
  static const String baseUrl = base_url;

  static Future<Map<String, dynamic>> getAllPosyandu() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'No authentication token found',
          'error_code': 'NO_TOKEN',
        };
      }

      print('Getting posyandu from: $baseUrl/posyandu');
      print('Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/posyandu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Posyandu Response status: ${response.statusCode}');
      print('Posyandu Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Token expired or invalid',
          'error_code': 'UNAUTHORIZED',
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to load posyandu data. Status: ${response.statusCode}',
          'error_code': 'HTTP_ERROR',
        };
      }
    } catch (e) {
      print('Error in getAllPosyandu: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'error_code': 'NETWORK_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> getPosyanduById(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/posyandu/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Failed to load posyandu data'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPosyanduByUser(int userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/posyandu/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Failed to load posyandu by user data',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createPosyandu(
    Map<String, dynamic> posyanduData,
  ) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/posyandu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(posyanduData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Posyandu berhasil ditambahkan',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to create posyandu',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updatePosyandu(
    int id,
    Map<String, dynamic> posyanduData,
  ) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/posyandu/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(posyanduData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Posyandu berhasil diupdate',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update posyandu',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deletePosyandu(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/posyandu/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Posyandu berhasil dihapus'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to delete posyandu',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
