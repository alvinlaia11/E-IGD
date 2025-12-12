import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_list_notifier.dart';

enum EmergencyType {
  kecelakaan,
  kebakaran;

  String get displayName {
    switch (this) {
      case EmergencyType.kecelakaan:
        return AppStrings.penangananKecelakaan;
      case EmergencyType.kebakaran:
        return AppStrings.penangananKebakaran;
    }
  }

  String get keluhanDefault {
    switch (this) {
      case EmergencyType.kecelakaan:
        return 'Kecelakaan';
      case EmergencyType.kebakaran:
        return 'Kebakaran';
    }
  }

  IconData get icon {
    switch (this) {
      case EmergencyType.kecelakaan:
        return Icons.car_crash;
      case EmergencyType.kebakaran:
        return Icons.local_fire_department;
    }
  }
}

class EmergencyFormPage extends StatefulWidget {
  final EmergencyType emergencyType;

  const EmergencyFormPage({
    super.key,
    required this.emergencyType,
  });

  @override
  State<EmergencyFormPage> createState() => _EmergencyFormPageState();
}

class _EmergencyFormPageState extends State<EmergencyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _keluhanController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _jumlahKorbanController = TextEditingController();
  final _kondisiController = TextEditingController();

  JenisKelamin _selectedGender = JenisKelamin.lakiLaki;

  @override
  void initState() {
    super.initState();
    // Set default keluhan berdasarkan jenis emergency
    _keluhanController.text = widget.emergencyType.keluhanDefault;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _keluhanController.dispose();
    _lokasiController.dispose();
    _jumlahKorbanController.dispose();
    _kondisiController.dispose();
    super.dispose();
  }

  Future<void> _saveEmergency() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    
    // Build keluhan utama dengan detail
    String keluhanUtama = widget.emergencyType.keluhanDefault;
    if (_lokasiController.text.trim().isNotEmpty) {
      keluhanUtama += ' - Lokasi: ${_lokasiController.text.trim()}';
    }
    if (_jumlahKorbanController.text.trim().isNotEmpty) {
      keluhanUtama += ' - Jumlah Korban: ${_jumlahKorbanController.text.trim()}';
    }
    if (_kondisiController.text.trim().isNotEmpty) {
      keluhanUtama += ' - Kondisi: ${_kondisiController.text.trim()}';
    }
    if (_keluhanController.text.trim().isNotEmpty && 
        _keluhanController.text.trim() != widget.emergencyType.keluhanDefault) {
      keluhanUtama += ' - Detail: ${_keluhanController.text.trim()}';
    }

    final patient = Patient(
      nama: _namaController.text.trim(),
      usia: int.parse(_usiaController.text.trim()),
      jenisKelamin: _selectedGender,
      keluhanUtama: keluhanUtama,
      kategoriTriage: TriageLevel.merah, // Auto-set MERAH untuk emergency
      statusPenanganan: StatusPenanganan.menunggu, // Auto-set MENUNGGU
      waktuKedatangan: now,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final notifier = context.read<PatientListNotifier>();
      await notifier.addPatient(patient);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.pasienEmergencyBerhasil),
            backgroundColor: AppColors.statusSelesai,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.emergencyType.displayName),
        backgroundColor: AppColors.triageMerah,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.triageMerah.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Emergency Alert Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.triageMerah,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.triageMerah.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.emergencyType.icon,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EMERGENCY CASE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.emergencyType.displayName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Nama Pasien
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.namaPasien,
                    prefixIcon: Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.namaWajib;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Usia
                TextFormField(
                  controller: _usiaController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.usia,
                    prefixIcon: Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.usiaWajib;
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return AppStrings.usiaInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Jenis Kelamin
                DropdownButtonFormField<JenisKelamin>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: AppStrings.jenisKelamin,
                    prefixIcon: Icon(Icons.wc),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: JenisKelamin.values.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender.fullName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGender = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Lokasi Kejadian
                TextFormField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.lokasiKejadian,
                    prefixIcon: Icon(Icons.location_on),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Contoh: Jl. Sudirman No. 123',
                  ),
                ),
                const SizedBox(height: 16),

                // Jumlah Korban
                TextFormField(
                  controller: _jumlahKorbanController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.jumlahKorban,
                    prefixIcon: Icon(Icons.people),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Contoh: 2 orang',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Kondisi Pasien
                TextFormField(
                  controller: _kondisiController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.kondisiPasien,
                    prefixIcon: Icon(Icons.medical_services),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Contoh: Pingsan, Luka ringan, dll',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Keluhan Utama (Detail)
                TextFormField(
                  controller: _keluhanController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.keluhanUtama,
                    prefixIcon: Icon(Icons.description),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Info Auto-set
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.triageMerah.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.triageMerah.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.triageMerah,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Triage otomatis: MERAH | Status: MENUNGGU',
                          style: TextStyle(
                            color: AppColors.triageMerah,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                PrimaryButton(
                  text: AppStrings.simpanEmergency,
                  onPressed: _saveEmergency,
                  backgroundColor: AppColors.triageMerah,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

