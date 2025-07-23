import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/posyanduModel.dart';
import 'package:flutter_application_1/data/API/BalitaService.dart';
import 'package:flutter_application_1/data/API/ImunisasiService.dart';
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';
import 'package:flutter_application_1/data/models/imunisasi.dart';
import 'package:flutter_application_1/presentation/screens/balita_detail_screen.dart';

class ImunisasiBalitaScreen extends StatefulWidget {
  final PosyanduModel? posyandu;
  const ImunisasiBalitaScreen({super.key, required this.posyandu});

  @override
  State<ImunisasiBalitaScreen> createState() => _ImunisasiBalitaScreenState();
}

class _ImunisasiBalitaScreenState extends State<ImunisasiBalitaScreen> {
  // Filter utama: status ('semua', 'sudah', 'belum', 'segera'), dan jenis imunisasi
  String _filter = 'semua';
  String? _filterJenisImunisasi;
  final List<String> _daftarJenisImunisasi = ['DPT', 'Campak', 'Hepatitis B'];

  Widget _buildFilterOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final count = _filterCounts[value] ?? 0;
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Row(
        children: [
          Expanded(child: Text(label)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      trailing:
          _filter == value ? const Icon(Icons.check, color: Colors.red) : null,
      onTap: () {
        setState(() {
          _filter = value;
          // Refresh data ketika filter berubah
          _loadBalitaData();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildJenisImunisasiFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Imunisasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Semua'),
              selected: _filterJenisImunisasi == null,
              onSelected: (_) {
                setState(() {
                  _filterJenisImunisasi = null;
                  // Refresh data ketika filter direset
                  _loadBalitaData();
                });
              },
            ),
            ..._daftarJenisImunisasi
                .map(
                  (jenis) => ChoiceChip(
                    label: Text(jenis),
                    selected: _filterJenisImunisasi == jenis,
                    onSelected: (_) {
                      setState(() {
                        _filterJenisImunisasi = jenis;
                        // Refresh data ketika filter jenis imunisasi berubah
                        _loadBalitaData();
                      });
                    },
                  ),
                )
                .toList(),
          ],
        ),
        const SizedBox(height: 16),
        // Penjelasan filter Imunisasi Mendatang
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.purple),
                  const SizedBox(width: 6),
                  Text(
                    'Info: Imunisasi Mendatang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Menampilkan balita yang sudah pernah mendapat imunisasi sebelumnya tetapi belum lengkap semua jenis imunisasi yang diperlukan.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  final Balitaservice _balitaService = Balitaservice();
  final ImunisasiService _imunisasiService = ImunisasiService();
  late Future<List<BalitaModel>> _balitaList;
  bool _isAuthenticated = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Tambahan untuk menghitung jumlah setiap filter
  Map<String, int> _filterCounts = {
    'semua': 0,
    'sudah': 0,
    'belum': 0,
    'segera': 0,
    'mendatang': 0,
  };

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadData();
    _debugBalitaData(); // Debug data
  }

  // Fungsi untuk cek autentikasi dan load data
  Future<void> _checkAuthenticationAndLoadData() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final userId = await AuthService.getUserId();

      if (!isLoggedIn || userId == null) {
        // Redirect ke login jika tidak terautentikasi
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      setState(() {
        _isAuthenticated = true;
      });

      // Load data berdasarkan user yang login
      _loadBalitaData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi untuk menghitung jumlah balita untuk setiap filter
  void _calculateFilterCounts(List<BalitaModel> allBalita) {
    final now = DateTime.now();
    
    // Reset counts
    _filterCounts = {
      'semua': 0,
      'sudah': 0,
      'belum': 0,
      'segera': 0,
      'mendatang': 0,
    };

    // Filter balita aktif (berusia di bawah 6 tahun) untuk perhitungan
    final activeBalita = allBalita.where((balita) {
      final age = now.year - balita.tanggalLahir.year -
          ((now.month < balita.tanggalLahir.month ||
                  (now.month == balita.tanggalLahir.month &&
                      now.day < balita.tanggalLahir.day))
              ? 1
              : 0);
      return age < 6; // Hanya balita aktif
    }).toList();

    _filterCounts['semua'] = activeBalita.length;

    for (var balita in activeBalita) {
      // Sudah imunisasi
      if (balita.imunisasiList.isNotEmpty) {
        _filterCounts['sudah'] = _filterCounts['sudah']! + 1;
      }

      // Belum imunisasi
      if (balita.imunisasiList.isEmpty) {
        _filterCounts['belum'] = _filterCounts['belum']! + 1;
      }

      // Segera imunisasi (18+ bulan, belum pernah imunisasi)
      final waktuImunisasi = DateTime(now.year - 1, now.month - 6, now.day);
      final isOldEnough = balita.tanggalLahir.isBefore(waktuImunisasi) ||
          balita.tanggalLahir.isAtSameMomentAs(waktuImunisasi);
      final hasNoImmunization = balita.imunisasiList.isEmpty;
      
      if (isOldEnough && hasNoImmunization) {
        _filterCounts['segera'] = _filterCounts['segera']! + 1;
      }

      // Mendatang (sudah imunisasi tapi belum lengkap)
      if (balita.imunisasiList.isNotEmpty) {
        final jenisYangSudah =
            balita.imunisasiList.map((i) => i.jenisImunisasi).toSet();
        final belumLengkap = _daftarJenisImunisasi.any(
          (jenis) => !jenisYangSudah.contains(jenis),
        );
        if (belumLengkap) {
          _filterCounts['mendatang'] = _filterCounts['mendatang']! + 1;
        }
      }
    }
  }

  // Fungsi untuk memuat data balita berdasarkan filter dan user yang login
  void _loadBalitaData() {
    if (!_isAuthenticated) return;

    setState(() {
      if (widget.posyandu == null) {
        // Jika "Semua Balita Imunisasi" dipilih, ambil berdasarkan user yang login
        _balitaList = _getBalitaByUserWithFilter();
      } else {
        // Jika posyandu dipilih, ambil data posyandu untuk user yang login dan terapkan filter
        _balitaList = _getBalitaByPosyanduAndUserWithFilter();
      }
    });
  }

  // Fungsi untuk filter data posyandu berdasarkan user yang login
  Future<List<BalitaModel>> _getBalitaByPosyanduAndUserWithFilter() async {
    try {
      List<BalitaModel> allBalita =
          await _balitaService.GetBalitaByPosyanduAndUser(widget.posyandu!.id!);
      
      // Hitung jumlah untuk setiap filter
      _calculateFilterCounts(allBalita);
      
      return _applyFilters(allBalita);
    } catch (e) {
      print('Error dalam GetBalitaByPosyanduAndUser: $e');
      return [];
    }
  }

  // Fungsi untuk mengambil data balita berdasarkan user yang login dengan filter
  Future<List<BalitaModel>> _getBalitaByUserWithFilter() async {
    try {
      List<BalitaModel> allBalita = await _balitaService.getAllBalitaByUser();
      
      // Hitung jumlah untuk setiap filter
      _calculateFilterCounts(allBalita);

      // Debug print untuk melihat data yang diterima
      print('=== DEBUG DATA RECEIVED ===');
      print('Total balita received: ${allBalita.length}');
      print('Current filter: $_filter');
      print('Filter counts: $_filterCounts');

      for (var balita in allBalita.take(3)) {
        final now = DateTime.now();
        final age = now.difference(balita.tanggalLahir).inDays ~/ 365;
        final ageInMonths = now.difference(balita.tanggalLahir).inDays ~/ 30;

        print('Balita: ${balita.nama}');
        print('  - Birth date: ${balita.tanggalLahir}');
        print('  - Age: $age years ($ageInMonths months)');
        print('  - ImunisasiList length: ${balita.imunisasiList.length}');
        if (balita.imunisasiList.isNotEmpty) {
          print(
            '  - Jenis imunisasi: ${balita.imunisasiList.map((i) => i.jenisImunisasi).join(', ')}',
          );
        }

        // Check for "segera" criteria
        if (_filter == 'segera') {
          final waktuImunisasi = DateTime(now.year - 1, now.month - 6, now.day);
          final isOldEnough =
              balita.tanggalLahir.isBefore(waktuImunisasi) ||
              balita.tanggalLahir.isAtSameMomentAs(waktuImunisasi);
          final hasNoImmunization = balita.imunisasiList.isEmpty;
          print('  - Old enough (18+ months): $isOldEnough');
          print('  - Has no immunization: $hasNoImmunization');
          print(
            '  - Qualifies for "segera": ${isOldEnough && hasNoImmunization}',
          );
        }
        print('');
      }

      return _applyFilters(allBalita);
    } catch (e) {
      print('Error dalam getAllBalitaByUser: $e');
      return [];
    }
  }

  // Fungsi untuk menerapkan filter pada list balita
  List<BalitaModel> _applyFilters(List<BalitaModel> allBalita) {
    // Filter balita aktif (berusia di bawah 6 tahun) dan filter lainnya
    List<BalitaModel> filtered =
        allBalita.where((balita) {
          // Filter balita aktif - tidak tampilkan yang berusia 6 tahun ke atas
          final now = DateTime.now();
          final age =
              now.year -
              balita.tanggalLahir.year -
              ((now.month < balita.tanggalLahir.month ||
                      (now.month == balita.tanggalLahir.month &&
                          now.day < balita.tanggalLahir.day))
                  ? 1
                  : 0);

          // Jangan tampilkan balita yang tidak aktif (usia >= 6 tahun)
          if (age >= 6) {
            return false;
          }

          // Filter pencarian nama
          if (_searchQuery.isNotEmpty &&
              !balita.nama.toLowerCase().contains(_searchQuery.toLowerCase()) &&
              !balita.nik.toLowerCase().contains(_searchQuery.toLowerCase()) &&
              !balita.namaIbu.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              )) {
            return false;
          }
          // Filter status imunisasi
          if (_filter == 'semua') {
            return true;
          } else if (_filter == 'sudah') {
            // Sudah imunisasi minimal satu kali jenis apapun
            return balita.imunisasiList.isNotEmpty;
          } else if (_filter == 'belum') {
            // Belum pernah imunisasi sama sekali
            return balita.imunisasiList.isEmpty;
          } else if (_filter == 'segera') {
            // Segera Imunisasi: Balita berusia 18 bulan ke atas yang belum imunisasi sama sekali
            // Berdasarkan logika getAllBalitaWithNotImunisasi
            final waktuImunisasi = DateTime(
              now.year - 1,
              now.month - 6,
              now.day,
            ); // 1.5 tahun yang lalu

            // Balita lahir 18 bulan yang lalu atau lebih dan belum pernah imunisasi
            final isOldEnough =
                balita.tanggalLahir.isBefore(waktuImunisasi) ||
                balita.tanggalLahir.isAtSameMomentAs(waktuImunisasi);
            final hasNoImmunization = balita.imunisasiList.isEmpty;

            return isOldEnough && hasNoImmunization;
          } else if (_filter == 'mendatang') {
            // Imunisasi Mendatang: Sudah imunisasi tapi belum lengkap semua jenis
            if (balita.imunisasiList.isNotEmpty) {
              final jenisYangSudah =
                  balita.imunisasiList.map((i) => i.jenisImunisasi).toSet();
              final belumLengkap = _daftarJenisImunisasi.any(
                (jenis) => !jenisYangSudah.contains(jenis),
              );
              return belumLengkap;
            }
            return false;
          }
          return true;
        }).toList();

    // Filter berdasarkan jenis imunisasi jika dipilih
    if (_filterJenisImunisasi != null) {
      filtered =
          filtered
              .where(
                (balita) => balita.imunisasiList.any(
                  (i) => i.jenisImunisasi == _filterJenisImunisasi,
                ),
              )
              .toList();
    }

    print('Hasil filter: ${filtered.length} balita');
    return filtered;
  }

  String _searchQuery = '';

  // Fungsi untuk mengambil data imunisasi balita dari data yang sudah ada
  List<Imunisasi> _getImunisasiBalita(BalitaModel balita) {
    return balita.imunisasiList;
  }

  // Debug function untuk cek data user
  void _debugBalitaData() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final userId = await AuthService.getUserId();

      print('=== DEBUG AUTHENTICATION ===');
      print('Is logged in: $isLoggedIn');
      print('User ID: $userId');

      if (!isLoggedIn || userId == null) {
        print('User tidak terautentikasi, tidak bisa load data');
        return;
      }

      List<BalitaModel> allBalita = await _balitaService.getAllBalitaByUser();
      List<Imunisasi> allImunisasi =
          await _imunisasiService.getImunisasiByCurrentUser();

      print('=== DEBUG DATA BALITA BY USER ===');
      print('Total balita untuk user $userId: ${allBalita.length}');
      print('Total imunisasi untuk user $userId: ${allImunisasi.length}');

      for (int i = 0; i < (allBalita.length > 5 ? 5 : allBalita.length); i++) {
        final balita = allBalita[i];
        print('Balita ${i + 1}:');
        print('  - Nama: ${balita.nama}');
        print('  - sudahImunisasi: ${balita.sudahImunisasi}');
        print('  - imunisasiList length: ${balita.imunisasiList.length}');
        if (balita.imunisasiList.isNotEmpty) {
          print(
            '  - Jenis imunisasi: ${balita.imunisasiList.map((i) => i.jenisImunisasi).toList()}',
          );
        }
        print('');
      }
    } catch (e) {
      print('Error debug: $e');
    }
  }

  // Method untuk refresh data setelah ada perubahan
  void refreshData() {
    if (mounted) {
      setState(() {
        _loadBalitaData();
      });
      print('Data di-refresh karena ada perubahan');
    }
  }

  // Fungsi untuk navigasi ke detail balita
  Future<void> _navigateToBalitaDetail(BalitaModel balita) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BalitaDetailScreen(balita: balita),
      ),
    );
    
    // Refresh data jika ada perubahan dari detail screen
    if (result == true && mounted) {
      refreshData();
    }
  }

  // Fungsi untuk handle logout
  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        await AuthService.logout();
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Kembali',
        ),
        title: const Text(
          'Imunisasi Balita',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal, size: 26),
            onPressed: () {
              refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data telah diperbarui'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.teal, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Filter',
          ),
          if (_isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red, size: 24),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
        ],
      ),
      drawer: Drawer(
        width: 280,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Filter Imunisasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih status dan jenis imunisasi untuk filter',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Status Imunisasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    'semua',
                    'Semua Balita',
                    Icons.list,
                    Colors.grey,
                  ),
                  _buildFilterOption(
                    'sudah',
                    'Sudah Imunisasi',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildFilterOption(
                    'belum',
                    'Belum Imunisasi',
                    Icons.close,
                    Colors.orange,
                  ),
                  _buildFilterOption(
                    'segera',
                    'Segera Imunisasi',
                    Icons.warning,
                    Colors.red,
                  ),
                  _buildFilterOption(
                    'mendatang',
                    'Imunisasi Mendatang',
                    Icons.schedule,
                    Colors.purple,
                  ),
                  const SizedBox(height: 24),
                  _buildJenisImunisasiFilter(),
                ],
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<BalitaModel>>(
        future: _balitaList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data: \\${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data balita.'));
          }
          // Search bar dan info jumlah data
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari nama balita...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.teal,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            // Refresh data ketika search query berubah
                            _loadBalitaData();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FutureBuilder<List<BalitaModel>>(
                        future: _balitaList,
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return Text(
                            '$count Balita',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<BalitaModel>>(
                  future: _balitaList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LoadingIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final balitaList = snapshot.data ?? [];

                    if (balitaList.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada data balita sesuai filter.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: balitaList.length,
                      itemBuilder: (context, index) {
                        final balita = balitaList[index];
                        final isDeceased = balita.tanggalKematian != null;

                        // Debug posyandu data
                        print('=== DEBUG POSYANDU FOR ${balita.nama} ===');
                        print('Posyandu ID: ${balita.posyanduId}');
                        print(
                          'Posyandu: ${balita.posyandu?.toString() ?? "null"}',
                        );
                        if (balita.posyandu != null) {
                          print(
                            'Posyandu name: ${balita.posyandu!.namaPosyandu}',
                          );
                        }

                        return Card(
                          color:
                              isDeceased
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.9),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: InkWell(
                            onTap: () => _navigateToBalitaDetail(balita),
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    isDeceased
                                        ? Icons.person_off_outlined
                                        : Icons.child_care,
                                    color:
                                        isDeceased
                                            ? Colors.red.shade700
                                            : Colors.teal,
                                  ),
                                  title: Text(
                                    balita.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('NIK: ${balita.nik}'),
                                      if (isDeceased)
                                        Text(
                                          balita.tanggalKematian != null
                                              ? 'Meninggal: ${balita.tanggalKematian!.day.toString().padLeft(2, '0')}-${balita.tanggalKematian!.month.toString().padLeft(2, '0')}-${balita.tanggalKematian!.year}'
                                              : 'Meninggal: Tanggal tidak tersedia',
                                        )
                                      else ...[
                                        Text('Ibu: ${balita.namaIbu}'),
                                        Text(
                                          'Usia: ${DateTime.now().year - balita.tanggalLahir.year} tahun',
                                        ),
                                        Text(
                                          'Posyandu: ${balita.posyandu?.namaPosyandu ?? "-"}',
                                        ),
                                      ],
                                    ],
                                  ),
                                  isThreeLine: true,
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              // Kontainer untuk jenis imunisasi
                              Builder(
                                builder: (context) {
                                  final imunisasiList = _getImunisasiBalita(
                                    balita,
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Status Imunisasi:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children:
                                              _daftarJenisImunisasi.map((
                                                jenis,
                                              ) {
                                                final sudah = imunisasiList.any(
                                                  (i) =>
                                                      i.jenisImunisasi == jenis,
                                                );
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        sudah
                                                            ? Colors.green[300]
                                                            : Colors.red[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        sudah
                                                            ? Icons.check
                                                            : Icons.close,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        jenis,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    ); // End of Scaffold
  }
}
