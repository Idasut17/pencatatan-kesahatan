import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/API/KunjunganBalitaService.dart';
import 'package:flutter_application_1/data/models/KunjunganBalitaModel.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:flutter_application_1/presentation/widgets/login_background.dart';
import 'package:intl/intl.dart';

class KunjunganFormScreen extends StatefulWidget {
  final BalitaModel balita;
  final KunjunganModel? kunjunganToEdit;
  const KunjunganFormScreen({
    super.key,
    required this.balita,
    this.kunjunganToEdit,
  });

  @override
  State<KunjunganFormScreen> createState() => _KunjunganFormScreenState();
}

class _KunjunganFormScreenState extends State<KunjunganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kunjunganService = Kunjunganbalitaservice();

  final _tanggalController = TextEditingController();
  final _beratBadanController = TextEditingController();
  final _tinggiBadanController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  // State untuk Radio Button
  String? _selectedStatusGizi;
  final Map<String, String> _statusGiziOptions = {
    'N': 'Normal',
    'K': 'Kurang',
    'T': 'Obesitas',
  };

  String? _selectedRambuGizi;
  final List<String> _rambuGiziOptions = [
    'N1',
    'N2',
    'T1',
    'T2',
    'T3',
    '2T',
    'O',
  ];

  // State untuk loading indicator
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tanggalController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
  }

  Future<void> _pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _simpanPemeriksaan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final kunjunganBaru = await _kunjunganService.CreateKunjunganBalita(
          widget.balita.id!,
          _selectedDate,
          // Menggunakan replaceAll untuk memastikan format angka benar
          // jika pengguna memasukkan koma sebagai desimal.
          double.parse(_beratBadanController.text.replaceAll(',', '.')),
          double.parse(_tinggiBadanController.text.replaceAll(',', '.')),
          _selectedStatusGizi!,
          _selectedRambuGizi!,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kunjungan untuk ${widget.balita.nama} berhasil dicatat.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman sebelumnya dengan data baru untuk menandakan sukses
        Navigator.of(context).pop(kunjunganBaru);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showRambuGiziInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Keterangan Rambu Gizi',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rambu Gizi adalah indikator pertumbuhan balita berdasarkan grafik KMS (Kartu Menuju Sehat):',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

                  // Kategori Utama
                  const Text(
                    'KATEGORI UTAMA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRambuDetailInfo(
                    'N',
                    'Naik',
                    'Pertumbuhan anak baik dan sesuai harapan',
                    Colors.green,
                  ),
                  _buildRambuDetailInfo(
                    'T',
                    'Tidak Naik',
                    'Pertumbuhan anak bermasalah dan perlu perhatian khusus',
                    Colors.red,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'PERTUMBUHAN BAIK (Sub-kategori N)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRambuDetailInfo(
                    'N1',
                    'Tumbuh Kejar',
                    'Percepatan pertumbuhan setelah sembuh dari sakit',
                    Colors.green,
                  ),
                  _buildRambuDetailInfo(
                    'N2',
                    'Tumbuh Normal',
                    'Pertumbuhan stabil mengikuti jalur standar',
                    Colors.green,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'PERTUMBUHAN BERMASALAH (Sub-kategori T)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRambuDetailInfo(
                    'T1',
                    'Pertumbuhan Kurang',
                    'Kenaikan berat badan melambat dari harapan',
                    Colors.orange,
                  ),
                  _buildRambuDetailInfo(
                    'T2',
                    'Berat Badan Tetap',
                    'Tidak ada kenaikan berat badan (stagnan)',
                    Colors.red,
                  ),
                  _buildRambuDetailInfo(
                    'T3',
                    'Berat Badan Menurun',
                    'Kehilangan berat badan (paling mengkhawatirkan)',
                    Colors.red,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'KODE KHUSUS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRambuDetailInfo(
                    '2T',
                    'Dua Kali Tidak Naik',
                    'Tidak naik berturut-turut - sinyal bahaya!',
                    Colors.red,
                  ),
                  _buildRambuDetailInfo(
                    'O',
                    'Tidak Ditimbang',
                    'Tidak ditimbang bulan lalu - tidak bisa ditentukan tren',
                    Colors.grey,
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Pilih rambu gizi yang sesuai dengan hasil penimbangan dan analisis grafik pertumbuhan balita.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRambuDetailInfo(
    String code,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _beratBadanController.dispose();
    _tinggiBadanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Form Kunjungan Balita',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black, size: 24),
            onPressed: _showRambuGiziInfo,
            tooltip: 'Info Rambu Gizi',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const LoginBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Pencatatan Kunjungan',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Balita: ${widget.balita.nama}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _tanggalController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Kunjungan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _pilihTanggal,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal kunjungan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _beratBadanController,
                          decoration: const InputDecoration(
                            labelText: 'Berat Badan (kg)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.monitor_weight_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Berat badan tidak boleh kosong';
                            }
                            if (double.tryParse(value.replaceAll(',', '.')) ==
                                null) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tinggiBadanController,
                          decoration: const InputDecoration(
                            labelText: 'Tinggi Badan (cm)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.height_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tinggi badan tidak boleh kosong';
                            }
                            if (double.tryParse(value.replaceAll(',', '.')) ==
                                null) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // --- Radio Button untuk Status Gizi ---
                        FormField<String>(
                          validator: (value) {
                            if (_selectedStatusGizi == null) {
                              return 'Status gizi harus dipilih.';
                            }
                            return null;
                          },
                          builder:
                              (state) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Status Gizi',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Row(
                                    children:
                                        _statusGiziOptions.entries.map((entry) {
                                          return Expanded(
                                            child: RadioListTile<String>(
                                              title: Text(entry.value),
                                              value: entry.key,
                                              groupValue: _selectedStatusGizi,
                                              onChanged: (value) {
                                                setState(
                                                  () =>
                                                      _selectedStatusGizi =
                                                          value,
                                                );
                                                state.didChange(value);
                                              },
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Text(
                                        state.errorText!,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 16),
                        // --- Radio Button untuk Rambu Gizi ---
                        FormField<String>(
                          validator: (value) {
                            if (_selectedRambuGizi == null) {
                              return 'Rambu gizi harus dipilih.';
                            }
                            return null;
                          },
                          builder:
                              (state) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rambu Gizi',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Column(
                                    children: [
                                      // Baris pertama: N1, N2, T1
                                      Row(
                                        children:
                                            _rambuGiziOptions
                                                .sublist(0, 3)
                                                .map(
                                                  (option) => Expanded(
                                                    child: RadioListTile<
                                                      String
                                                    >(
                                                      title: Text(option),
                                                      value: option,
                                                      groupValue:
                                                          _selectedRambuGizi,
                                                      onChanged: (value) {
                                                        setState(
                                                          () =>
                                                              _selectedRambuGizi =
                                                                  value,
                                                        );
                                                        state.didChange(value);
                                                      },
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                      // Baris kedua: T2, T3, 2T
                                      Row(
                                        children:
                                            _rambuGiziOptions
                                                .sublist(3, 6)
                                                .map(
                                                  (option) => Expanded(
                                                    child: RadioListTile<
                                                      String
                                                    >(
                                                      title: Text(option),
                                                      value: option,
                                                      groupValue:
                                                          _selectedRambuGizi,
                                                      onChanged: (value) {
                                                        setState(
                                                          () =>
                                                              _selectedRambuGizi =
                                                                  value,
                                                        );
                                                        state.didChange(value);
                                                      },
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                      // Baris ketiga: O (di tengah)
                                      Row(
                                        children: [
                                          Expanded(child: Container()),
                                          Expanded(
                                            child: RadioListTile<String>(
                                              title: const Text('O'),
                                              value: 'O',
                                              groupValue: _selectedRambuGizi,
                                              onChanged: (value) {
                                                setState(
                                                  () =>
                                                      _selectedRambuGizi =
                                                          value,
                                                );
                                                state.didChange(value);
                                              },
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                          Expanded(child: Container()),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Text(
                                        state.errorText!,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _simpanPemeriksaan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : const Text('Simpan'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
