import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/consultation_enums.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../providers/consultation_notifier.dart';

class ConsultationDetailPage extends StatefulWidget {
  final int consultationId;

  const ConsultationDetailPage({super.key, required this.consultationId});

  @override
  State<ConsultationDetailPage> createState() => _ConsultationDetailPageState();
}

class _ConsultationDetailPageState extends State<ConsultationDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationNotifier>().loadConsultationById(widget.consultationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(AppStrings.detailPasien),
        backgroundColor: AppColors.triageHijau,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ConsultationNotifier>(
        builder: (context, notifier, child) {
          final consultation = notifier.selectedConsultation;

          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (consultation == null) {
            return const Center(child: Text('Konsultasi tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(consultation),
                const SizedBox(height: 16),
                // Informasi Konsultasi
                _buildInfoCard(consultation),
                const SizedBox(height: 16),
                // Diagnosis & Resep
                if (consultation.diagnosis != null || consultation.prescription != null)
                  _buildDiagnosisCard(consultation),
                if (consultation.diagnosis != null || consultation.prescription != null)
                  const SizedBox(height: 16),
                // Rekomendasi
                if (consultation.recommendation != null)
                  _buildRecommendationCard(consultation),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(consultation) {
    Color statusColor;
    switch (consultation.status) {
      case ConsultationStatus.menunggu:
        statusColor = AppColors.statusMenunggu;
        break;
      case ConsultationStatus.berlangsung:
        statusColor = AppColors.statusDitangani;
        break;
      case ConsultationStatus.selesai:
        statusColor = AppColors.statusSelesai;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.triageHijau.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: AppColors.triageHijau,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.doctorName ?? 'Menunggu dokter',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        consultation.patientName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    consultation.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateTimeUtils.formatDateTime(consultation.startTime),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                if (consultation.endTime != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateTimeUtils.formatDateTime(consultation.endTime!),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(consultation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Konsultasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Keluhan Utama', consultation.complaint),
            const Divider(height: 24),
            _buildInfoRow('Jenis Konsultasi', consultation.consultationType.displayName),
            const Divider(height: 24),
            _buildInfoRow('Prioritas', consultation.priority.displayName),
            if (consultation.patientPhone != null) ...[
              const Divider(height: 24),
              _buildInfoRow('Nomor Telepon', consultation.patientPhone!),
            ],
            if (consultation.patientEmail != null) ...[
              const Divider(height: 24),
              _buildInfoRow('Email', consultation.patientEmail!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard(consultation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (consultation.diagnosis != null) ...[
              const Text(
                AppStrings.diagnosis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                consultation.diagnosis!,
                style: const TextStyle(fontSize: 14),
              ),
              if (consultation.prescription != null) const SizedBox(height: 16),
            ],
            if (consultation.prescription != null) ...[
              const Text(
                AppStrings.resepObat,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                consultation.prescription!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(consultation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.rekomendasi,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              consultation.recommendation!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

