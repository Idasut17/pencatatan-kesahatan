import 'dart:convert';
import 'package:flutter_application_1/data/API/BaseURL.dart';
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:flutter_application_1/data/models/posyanduModel.dart';
import 'package:http/http.dart' as http;

class Posyanduservice {
  // Search posyandu
  Future<List<PosyanduModel>> searchPosyandu(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/posyandu/search?keyword=$keyword'),
        headers: await AuthService.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responDecode = json.decode(response.body);
        final List<dynamic> data = responDecode['data'];
        return data.map((item) => PosyanduModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mencari posyandu: ${response.reasonPhrase}');
      }
    } catch (e) {
      print(e);
      throw Exception('Gagal mencari posyandu: $e');
    }
  }

  // Get posyandu with balita count
  Future<PosyanduModel?> getWithBalitaCount(int posyanduId) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/posyandu/with-balita-count/$posyanduId'),
        headers: await AuthService.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responDecode = json.decode(response.body);
        if (responDecode['data'] != null) {
          return PosyanduModel.fromJson(responDecode['data']);
        }
        return null;
      } else {
        throw Exception(
          'Gagal mengambil data posyandu: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print(e);
      throw Exception('Gagal mengambil data posyandu: $e');
    }
  }

  Future<void> CreatePosyandu(String namaPosyandu, String namaDesa) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('Sesi pengguna tidak valid. Silakan login ulang.');
      }

      final response = await http.post(
        Uri.parse('$base_url/posyandu'),
        headers: await AuthService.getAuthHeaders(),
        body: json.encode({
          'nama_posyandu': namaPosyandu,
          'nama_desa': namaDesa,
          'user_id': userId,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // Lemparkan exception dengan pesan error dari server jika ada
        throw Exception(
          'Gagal membuat Posyandu. Status: ${response.statusCode}, Pesan: ${response.body}',
        );
      }
    } catch (e) {
      print(e);
      // Lemparkan kembali error agar bisa ditangkap oleh UI
      rethrow;
    }
  }

  Future<List<PosyanduModel>> GetPosyanduByUser() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User tidak ditemukan, silakan login ulang.');
      }
      final response = await http.get(
        Uri.parse(base_url + '/posyandu/user/${userId}'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        final Map<String, dynamic> responDecode = json.decode(response.body);
        final List<dynamic> data = responDecode['data'];
        print("Data: $data");

        // Konversi list json menjadi list PosyanduModel dan kembalikan
        return data.map((item) => PosyanduModel.fromJson(item)).toList();
      } else {
        print('Error: ${response.reasonPhrase}');
        // Lemparkan exception agar bisa ditangani oleh UI
        throw Exception(
          'Gagal mengambil data Posyandu: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print(e);
      // Lemparkan kembali exception agar UI tahu ada error
      rethrow;
    }
  }

  UpdatePosyandu(int id, String namaPosyandu, String namaDesa) async {
    try {
      final response = await http.put(
        Uri.parse(base_url + '/posyandu/${id}'),
        headers: await AuthService.getAuthHeaders(),
        body: json.encode({
          'nama_posyandu': namaPosyandu,
          'nama_desa': namaDesa,
        }),
      );

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        return true;
      } else {
        print('Error: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  DeletePosyandu(id) async {
    try {
      final response = await http.delete(
        Uri.parse(base_url + '/posyandu/${id}'),
        headers: await AuthService.getAuthHeaders(),
      );

      print("Request URL: ${base_url}/posyandu/${id}");

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        return true;
      } else {
        print('Error: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
