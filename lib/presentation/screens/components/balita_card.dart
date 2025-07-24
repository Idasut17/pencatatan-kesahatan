import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';

class BalitaCard extends StatelessWidget {
  final BalitaModel balita;
  final int age;
  final bool isDeceased;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BalitaCard({
    Key? key,
    required this.balita,
    required this.age,
    required this.isDeceased,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String subtitleText = 'NIK: ${balita.nik}\n';
    if (isDeceased) {
      subtitleText +=
          balita.tanggalKematian != null
              ? 'Meninggal: ${balita.tanggalKematian!.day.toString().padLeft(2, '0')}-${balita.tanggalKematian!.month.toString().padLeft(2, '0')}-${balita.tanggalKematian!.year}'
              : 'Meninggal: Tanggal tidak tersedia';
    } else {
      subtitleText += 'Ibu: ${balita.namaIbu} | Usia: $age tahun';
    }

    return Card(
      color:
          isDeceased
              ? Colors.red.withOpacity(0.1)
              : age >= 6
              ? Colors.orange.withOpacity(0.1)
              : Colors.white.withOpacity(0.9),
      child: ListTile(
        leading: Icon(
          isDeceased
              ? Icons.person_off_outlined
              : age >= 6
              ? Icons.history
              : Icons.child_care,
          color:
              isDeceased
                  ? Colors.red.shade700
                  : age >= 6
                  ? Colors.orange
                  : Colors.teal,
        ),
        title: Text(
          balita.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitleText),
            // Container untuk status imunisasi (hanya untuk balita yang hidup)
            if (!isDeceased) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    ['DPT', 'Campak', 'Hepatitis B'].map((jenis) {
                      final sudah = balita.imunisasiList.any(
                        (i) => i.jenisImunisasi == jenis,
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sudah ? Colors.green[300] : Colors.red[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              sudah ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              jenis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
        isThreeLine: true,
        onTap: onTap,
        trailing:
            isDeceased
                ? null
                : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Hapus Balita',
                ),
      ),
    );
  }
}
