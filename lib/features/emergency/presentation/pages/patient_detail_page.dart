import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/patient_detail_notifier.dart';
import '../providers/patient_list_notifier.dart';
import '../widgets/triage_badge.dart';
import '../widgets/status_chip.dart';
import 'patient_form_page.dart';

class PatientDetailPage extends StatefulWidget {
  final int patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientDetailNotifier>().loadPatient(widget.patientId);
    });
  }

  void _showUpdateStatusDialog(PatientDetailNotifier notifier) {
    final patient = notifier.patient;
    if (patient == null) return;

    StatusPenanganan? selectedStatus = patient.statusPenanganan;
    final petugasController = TextEditingController(text: patient.petugas ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.updateStatus),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<StatusPenanganan>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: AppStrings.statusPenanganan,
                ),
                items: StatusPenanganan.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: petugasController,
                decoration: const InputDecoration(
                  labelText: AppStrings.petugas,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.batal),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedPatient = patient.copyWith(
                statusPenanganan: selectedStatus,
                petugas: petugasController.text.trim().isEmpty
                    ? null
                    : petugasController.text.trim(),
                updatedAt: DateTime.now(),
              );
              await notifier.savePatient(updatedPatient);
              if (mounted) {
                Navigator.pop(context);
                // Refresh patient list in dashboard
                final listNotifier = context.read<PatientListNotifier>();
                await listNotifier.loadPatients();
              }
            },
            child: const Text(AppStrings.simpan),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.detailPasien),
        actions: [
          Consumer<PatientDetailNotifier>(
            builder: (context, notifier, child) {
              if (notifier.patient == null) return const SizedBox();
              // Hide edit button if status is SELESAI
              if (notifier.patient!.statusPenanganan == StatusPenanganan.selesai) {
                return const SizedBox();
              }
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientFormPage(
                        patient: notifier.patient,
                      ),
                    ),
                  );
                  // Refresh patient detail and list after returning from edit
                  if (mounted) {
                    await notifier.loadPatient(widget.patientId);
                    final listNotifier = context.read<PatientListNotifier>();
                    await listNotifier.loadPatients();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<PatientDetailNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifier.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    notifier.errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notifier.loadPatient(widget.patientId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final patient = notifier.patient;
          if (patient == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isEmergency = patient.kategoriTriage == TriageLevel.merah &&
              patient.statusPenanganan == StatusPenanganan.menunggu;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emergency Alert
                if (isEmergency)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyAlert,
                      border: Border.all(color: AppColors.triageMerah, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.triageMerah),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.emergencyCase,
                            style: const TextStyle(
                              color: AppColors.triageMerah,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Patient Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                patient.nama,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TriageBadge(triage: patient.kategoriTriage),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.person,
                          'Usia',
                          '${patient.usia} tahun',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.wc,
                          'Jenis Kelamin',
                          patient.jenisKelamin.fullName,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.medical_services,
                          'Keluhan Utama',
                          patient.keluhanUtama,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.access_time,
                          'Waktu Kedatangan',
                          DateTimeUtils.formatDateTime(patient.waktuKedatangan),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Status: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            StatusChip(status: patient.statusPenanganan),
                          ],
                        ),
                        if (patient.petugas != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.badge,
                            'Petugas',
                            patient.petugas!,
                          ),
                        ],
                        // Ambulans Info
                        if (patient.isAmbulansCall) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.local_hospital, color: Colors.red[700], size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PANGGILAN AMBULANS',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                      if (patient.statusAmbulans != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Status: ${patient.statusAmbulans}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (patient.alamatLengkap != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.location_on,
                              'Lokasi Pickup',
                              patient.alamatLengkap!,
                            ),
                          ],
                          if (patient.nomorTelepon != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.phone,
                              'Nomor Telepon',
                              patient.nomorTelepon!,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                // Hide button if status is SELESAI
                if (patient.statusPenanganan != StatusPenanganan.selesai) ...[
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: AppStrings.updateStatus,
                    onPressed: () => _showUpdateStatusDialog(notifier),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

