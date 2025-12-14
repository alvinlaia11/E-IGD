import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/consultation_enums.dart';
import '../../../../core/utils/whatsapp_utils.dart';
import '../../domain/entities/teleconsultation.dart';
import '../providers/consultation_notifier.dart';

class ConsultationFormPage extends StatefulWidget {
  const ConsultationFormPage({super.key});

  @override
  State<ConsultationFormPage> createState() => _ConsultationFormPageState();
}

class _ConsultationFormPageState extends State<ConsultationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _keluhanController = TextEditingController();
  final _infoTambahanController = TextEditingController();

  ConsultationType _selectedType = ConsultationType.umum;
  ConsultationPriority _selectedPriority = ConsultationPriority.normal;

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _keluhanController.dispose();
    _infoTambahanController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final now = DateTime.now();
      
      // Buat entity konsultasi
      final consultation = Teleconsultation(
        patientName: _namaController.text.trim(),
        patientPhone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        patientEmail: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        complaint: _keluhanController.text.trim(),
        consultationType: _selectedType,
        priority: _selectedPriority,
        status: ConsultationStatus.menunggu,
        startTime: now,
        createdAt: now,
        updatedAt: now,
      );

      // Simpan ke database terlebih dahulu
      await context.read<ConsultationNotifier>().createNewConsultation(consultation);

      // Setelah berhasil disimpan, kirim ke WhatsApp
      await WhatsAppUtils.openWhatsAppWithConsultation(
        nama: _namaController.text.trim(),
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        keluhan: _keluhanController.text.trim(),
        jenisKonsultasi: _selectedType.displayName,
        prioritas: _selectedPriority.displayName,
        informasiTambahan: _infoTambahanController.text.trim().isEmpty 
            ? null 
            : _infoTambahanController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konsultasi berhasil dibuat dan dikirim ke WhatsApp'),
            backgroundColor: AppColors.triageHijau,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(AppStrings.konsultasiBaru),
        backgroundColor: AppColors.triageHijau,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.triageHijau.withOpacity(0.1),
                      AppColors.triageHijau.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, color: AppColors.triageHijau, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Isi form di bawah untuk memulai konsultasi dengan dokter',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: AppStrings.namaLengkap,
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.namaWajibAuth;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: AppStrings.nomorTelepon,
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: 'Opsional',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: 'Opsional',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Keluhan Utama
              TextFormField(
                controller: _keluhanController,
                decoration: const InputDecoration(
                  labelText: AppStrings.keluhanUtamaKonsultasi,
                  prefixIcon: Icon(Icons.medical_information),
                  border: OutlineInputBorder(),
                  hintText: 'Jelaskan keluhan Anda...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.keluhanWajib;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Jenis Konsultasi
              const Text(
                AppStrings.jenisKonsultasi,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...ConsultationType.values.map((type) => RadioListTile<ConsultationType>(
                title: Text(type.displayName),
                value: type,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              )),
              const SizedBox(height: 16),
              // Prioritas
              const Text(
                AppStrings.prioritasKonsultasi,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...ConsultationPriority.values.map((priority) => RadioListTile<ConsultationPriority>(
                title: Text(priority.displayName),
                value: priority,
                groupValue: _selectedPriority,
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              )),
              const SizedBox(height: 16),
              // Informasi Tambahan
              TextFormField(
                controller: _infoTambahanController,
                decoration: const InputDecoration(
                  labelText: AppStrings.informasiTambahan,
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                  hintText: 'Riwayat penyakit, alergi, obat yang sedang dikonsumsi, dll...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              // Button Kirim ke WhatsApp
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Kirim ke WhatsApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.triageHijau,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Button Batal
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.triageHijau, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    AppStrings.batal,
                    style: TextStyle(
                      color: AppColors.triageHijau,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

