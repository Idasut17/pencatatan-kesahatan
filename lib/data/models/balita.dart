class Balita {
  final int id;
  final String nama;
  final String nik;
  final String namaIbu;
  final DateTime tanggalLahir;
  final String alamat;
  final String jenisKelamin;
  final int posyanduId;
  final String bukuKIA;
  final List<Imunisasi>? imunisasi;
  final Posyandu? posyandu;
  final Kematian? kematian;
  final List<KunjunganBalita>? kunjunganBalita;

  Balita({
    required this.id,
    required this.nama,
    required this.nik,
    required this.namaIbu,
    required this.tanggalLahir,
    required this.alamat,
    required this.jenisKelamin,
    required this.posyanduId,
    required this.bukuKIA,
    this.imunisasi,
    this.posyandu,
    this.kematian,
    this.kunjunganBalita,
  });

  factory Balita.fromJson(Map<String, dynamic> json) {
    print('Parsing Balita JSON: $json');
    return Balita(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      nik: json['nik'] ?? '',
      namaIbu: json['nama_ibu'] ?? '',
      tanggalLahir:
          json['tanggal_lahir'] != null
              ? DateTime.parse(json['tanggal_lahir'])
              : DateTime.now(),
      alamat: json['alamat'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      posyanduId: json['posyandu_id'] ?? 0,
      bukuKIA: json['Buku_KIA'] ?? '',
      imunisasi:
          (json['imunisasi'] is List)
              ? (json['imunisasi'] as List)
                  .map((i) => Imunisasi.fromJson(i))
                  .toList()
              : [],
      posyandu:
          json['posyandu'] != null ? Posyandu.fromJson(json['posyandu']) : null,
      kematian:
          json['kematian'] != null ? Kematian.fromJson(json['kematian']) : null,
      kunjunganBalita:
          json['kunjungan_balita'] != null
              ? (json['kunjungan_balita'] as List)
                  .map((k) => KunjunganBalita.fromJson(k))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nik': nik,
      'nama_ibu': namaIbu,
      'tanggal_lahir': tanggalLahir.toIso8601String(),
      'alamat': alamat,
      'jenis_kelamin': jenisKelamin,
      'posyandu_id': posyanduId,
      'Buku_KIA': bukuKIA,
    };
  }
}

class Imunisasi {
  final int id;
  final String jenisImunisasi;
  final DateTime tanggalImunisasi;
  final int balitaId;

  Imunisasi({
    required this.id,
    required this.jenisImunisasi,
    required this.tanggalImunisasi,
    required this.balitaId,
  });

  factory Imunisasi.fromJson(Map<String, dynamic> json) {
    return Imunisasi(
      id: json['id'] ?? 0,
      jenisImunisasi: json['jenis_imunisasi'] ?? '',
      tanggalImunisasi:
          json['tanggal_imunisasi'] != null
              ? DateTime.parse(json['tanggal_imunisasi'])
              : DateTime.now(),
      balitaId: json['balita_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenis_imunisasi': jenisImunisasi,
      'tanggal_imunisasi': tanggalImunisasi.toIso8601String(),
      'balita_id': balitaId,
    };
  }
}

class Posyandu {
  final int id;
  final String nama;
  final String alamat;
  final int userId;

  Posyandu({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.userId,
  });

  factory Posyandu.fromJson(Map<String, dynamic> json) {
    try {
      return Posyandu(
        id: json['id'] ?? 0,
        nama: json['nama'] ?? '',
        alamat: json['alamat'] ?? '',
        userId: json['user_id'] ?? 0,
      );
    } catch (e) {
      print('Error parsing Posyandu JSON: $e');
      return Posyandu(id: 0, nama: 'Unknown', alamat: '', userId: 0);
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama, 'alamat': alamat, 'user_id': userId};
  }
}

class Kematian {
  final int id;
  final DateTime tanggalKematian;
  final String sebabKematian;
  final int balitaId;

  Kematian({
    required this.id,
    required this.tanggalKematian,
    required this.sebabKematian,
    required this.balitaId,
  });

  factory Kematian.fromJson(Map<String, dynamic> json) {
    return Kematian(
      id: json['id'] ?? 0,
      tanggalKematian:
          json['tanggal_kematian'] != null
              ? DateTime.parse(json['tanggal_kematian'])
              : DateTime.now(),
      sebabKematian: json['sebab_kematian'] ?? '',
      balitaId: json['balita_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal_kematian': tanggalKematian.toIso8601String(),
      'sebab_kematian': sebabKematian,
      'balita_id': balitaId,
    };
  }
}

class KunjunganBalita {
  final int id;
  final DateTime tanggalKunjungan;
  final double beratBadan;
  final double tinggiBadan;
  final String statusGizi;
  final int balitaId;

  KunjunganBalita({
    required this.id,
    required this.tanggalKunjungan,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.statusGizi,
    required this.balitaId,
  });

  factory KunjunganBalita.fromJson(Map<String, dynamic> json) {
    return KunjunganBalita(
      id: json['id'] ?? 0,
      tanggalKunjungan:
          json['tanggal_kunjungan'] != null
              ? DateTime.parse(json['tanggal_kunjungan'])
              : DateTime.now(),
      beratBadan: (json['berat_badan'] ?? 0).toDouble(),
      tinggiBadan: (json['tinggi_badan'] ?? 0).toDouble(),
      statusGizi: json['status_gizi'] ?? '',
      balitaId: json['balita_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal_kunjungan': tanggalKunjungan.toIso8601String(),
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'status_gizi': statusGizi,
      'balita_id': balitaId,
    };
  }
}
