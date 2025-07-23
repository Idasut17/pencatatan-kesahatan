import 'dart:convert';
import 'package:flutter_application_1/data/API/BaseURL.dart';
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:http/http.dart' as http;
import '../models/imunisasi.dart';

/// List global untuk menyimpan data imunisasi yang diambil dari API.
List<Imunisasi> daftarImunisasiGlobal = [];

class ImunisasiService {
  /// CREATE: Membuat data imunisasi baru.
  /// Return true jika sukses, false jika gagal.
  Future<bool> createImunisasi(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/imunisasi'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 201) {
        print('Imunisasi berhasil dibuat. Status: ${response.statusCode}');
        return true;
      } else {
        print(
          'Gagal membuat imunisasi. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat membuat imunisasi: $e');
      return false;
    }
  }

  /// READ: Mengambil data imunisasi berdasarkan balitaId sesuai route backend.
  /// Return list imunisasi, atau list kosong jika gagal.
  Future<List<Imunisasi>> getImunisasiByBalita(int balitaId) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/imunisasi/balita/$balitaId'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['success'] == true) {
          List<dynamic> data = decodedResponse['data'];
          daftarImunisasiGlobal =
              data.map((json) => Imunisasi.fromJson(json)).toList();
          return daftarImunisasiGlobal;
        } else {
          print('Gagal mengambil data: ${decodedResponse['message']}');
          return [];
        }
      } else {
        print('Error server: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('Terjadi exception saat mengambil imunisasi: $e');
      return [];
    }
  }

  /// READ: Mengambil data imunisasi berdasarkan user ID.
  /// Return list imunisasi, atau list kosong jika gagal.
  Future<List<Imunisasi>> getImunisasiByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/imunisasi/user/$userId'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['success'] == true) {
          List<dynamic> data = decodedResponse['data'];
          List<Imunisasi> imunisasiList =
              data.map((json) => Imunisasi.fromJson(json)).toList();
          return imunisasiList;
        } else {
          print(
            'Gagal mengambil data imunisasi user: ${decodedResponse['message']}',
          );
          return [];
        }
      } else {
        print(
          'Error server saat mengambil imunisasi user: ${response.reasonPhrase}',
        );
        return [];
      }
    } catch (e) {
      print('Terjadi exception saat mengambil imunisasi user: $e');
      return [];
    }
  }

  /// READ: Mengambil data imunisasi berdasarkan user yang sedang login.
  /// Return list imunisasi, atau list kosong jika gagal.
  Future<List<Imunisasi>> getImunisasiByCurrentUser() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        print('User tidak terautentikasi');
        return [];
      }

      return await getImunisasiByUser(userId);
    } catch (e) {
      print('Terjadi exception saat mengambil imunisasi user saat ini: $e');
      return [];
    }
  }

  /// UPDATE: Memperbarui data imunisasi berdasarkan id.
  /// Return true jika sukses, false jika gagal.
  Future<bool> updateImunisasi(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$base_url/imunisasi/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        print('Imunisasi berhasil diperbarui. Status: ${response.statusCode}');
        return true;
      } else {
        print(
          'Gagal memperbarui imunisasi. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat memperbarui imunisasi: $e');
      return false;
    }
  }

  /// DELETE: Menghapus data imunisasi berdasarkan id.
  /// Return true jika sukses, false jika gagal.
  Future<bool> deleteImunisasi(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$base_url/imunisasi/$id'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Imunisasi berhasil dihapus. Status: ${response.statusCode}');
        return true;
      } else {
        print(
          'Gagal menghapus imunisasi. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat menghapus imunisasi: $e');
      return false;
    }
  }
}
