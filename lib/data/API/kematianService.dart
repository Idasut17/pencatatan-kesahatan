import 'dart:convert';
import 'package:flutter_application_1/data/API/BaseURL.dart';
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:http/http.dart' as http;
import '../models/kematian.dart'; // Pastikan path ini benar

/// Service untuk mengelola data kematian balita melalui API.
class KematianService {
  /// Membuat data kematian baru.
  /// Melemparkan Exception jika gagal.
  Future<void> createKematian(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/kematian'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      // API yang baik mengembalikan 201 (Created) saat sukses membuat data baru.
      if (response.statusCode != 201) {
        // Jika gagal, lemparkan exception dengan detail dari server.
        throw Exception(
          'Gagal membuat data kematian. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
      print('Data kematian berhasil dibuat.');
    } catch (e) {
      // Lempar kembali exception agar bisa ditangani di UI.
      throw Exception('Terjadi kesalahan saat membuat data kematian: $e');
    }
  }

  /// Menghapus data kematian berdasarkan ID balita.
  /// Melemparkan Exception jika gagal.
  // di file: kematianService.dart

  Future<bool> deleteKematian(int id) async {
    // 1. Ubah dari Future<void> menjadi Future<bool>
    try {
      final response = await http.delete(
        Uri.parse('$base_url/kematian/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Data kematian berhasil dihapus.');
        return true; // 2. Kembalikan 'true' jika berhasil
      } else {
        // Jika gagal, jangan lemparkan error, tapi kembalikan 'false'
        print('Gagal menghapus data kematian. Status: ${response.statusCode}');
        return false; // 3. Kembalikan 'false' jika gagal
      }
    } catch (e) {
      print('Terjadi kesalahan saat menghapus data kematian: $e');
      return false; // 4. Kembalikan 'false' jika ada error koneksi dll.
    }
  }

  /// Mengambil data kematian berdasarkan ID balita.
  /// Mengembalikan objek Kematian jika ada, atau null jika tidak ditemukan (404).
  Future<Kematian?> getKematian(int balitaId) async {
    try {
      // Pastikan endpoint Anda benar, biasanya berdasarkan ID balita
      final response = await http.get(
        Uri.parse('$base_url/kematian/balita/$balitaId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print(
          'DEBUG getKematian response: ' + response.body.toString(),
        ); // Tambahkan log ini
        // Pastikan response memiliki data sebelum di-parse
        if (decodedResponse['data'] != null) {
          return Kematian.fromJson(decodedResponse['data']);
        }
        return null; // Bisa jadi sukses tapi data kosong
      } else if (response.statusCode == 404) {
        // Kasus normal: tidak ada data kematian untuk balita ini.
        return null;
      } else {
        // Untuk error lain, lemparkan exception.
        throw Exception(
          'Gagal memuat data kematian: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  /// Memperbarui data kematian.
  /// Melemparkan Exception jika gagal.
  Future<void> updateKematian(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$base_url/kematian/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memperbarui data kematian. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
      print('Data kematian berhasil diperbarui.');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memperbarui data kematian: $e');
    }
  }

  /// Mengambil semua data kematian (untuk patch frontend filter balita aktif)
  Future<List<Kematian>> getAllKematian() async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/kematian'),
        headers: await AuthService.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['data'] != null && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => Kematian.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Gagal memuat data kematian: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  /// Mengambil data kematian berdasarkan user yang sedang login
  Future<List<Kematian>> getAllKematianByUser() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      final response = await http.get(
        Uri.parse('$base_url/kematian/user/$userId'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['data'] != null && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => Kematian.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Gagal memuat data kematian user: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}
