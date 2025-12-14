import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/consultation_enums.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/teleconsultation.dart';
import '../providers/consultation_notifier.dart';
import 'consultation_form_page.dart';
import 'consultation_chat_page.dart';
import 'consultation_detail_page.dart';

class TeleconsultationHomePage extends StatefulWidget {
  const TeleconsultationHomePage({super.key});

  @override
  State<TeleconsultationHomePage> createState() => _TeleconsultationHomePageState();
}

class _TeleconsultationHomePageState extends State<TeleconsultationHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationNotifier>().loadConsultations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(AppStrings.telekonsultasiMedis),
        elevation: 0,
        backgroundColor: AppColors.triageHijau,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ConsultationNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading && notifier.consultations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => notifier.loadConsultations(),
            child: CustomScrollView(
              slivers: [
                // Header dengan tombol konsultasi baru
                SliverToBoxAdapter(
                  child: _buildHeader(context, notifier),
                ),
                // Konsultasi aktif
                if (notifier.activeCount > 0)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      AppStrings.konsultasiAktif,
                      notifier.activeCount,
                    ),
                  ),
                if (notifier.activeCount > 0)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final consultation = notifier.consultations
                            .where((c) => c.isActive)
                            .toList()[index];
                        return _buildConsultationCard(context, consultation, notifier);
                      },
                      childCount: notifier.activeCount,
                    ),
                  ),
                // Konsultasi menunggu
                if (notifier.waitingCount > 0)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      AppStrings.konsultasiMenunggu,
                      notifier.waitingCount,
                    ),
                  ),
                if (notifier.waitingCount > 0)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final consultation = notifier.waitingConsultations[index];
                        return _buildConsultationCard(context, consultation, notifier);
                      },
                      childCount: notifier.waitingCount,
                    ),
                  ),
                // Riwayat konsultasi
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    AppStrings.riwayatKonsultasi,
                    notifier.completedCount,
                  ),
                ),
                if (notifier.completedCount > 0)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final consultation = notifier.consultations
                            .where((c) => c.isCompleted)
                            .toList()[index];
                        return _buildConsultationCard(context, consultation, notifier);
                      },
                      childCount: notifier.completedCount,
                    ),
                  ),
                if (notifier.completedCount == 0 && notifier.activeCount == 0 && notifier.waitingCount == 0)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: EmptyState(
                        message: 'Belum ada konsultasi',
                        icon: Icons.medical_services_outlined,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ConsultationFormPage(),
            ),
          );
          // Refresh setelah form ditutup
          if (mounted) {
            context.read<ConsultationNotifier>().loadConsultations();
          }
        },
        backgroundColor: AppColors.triageHijau,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          AppStrings.konsultasiBaru,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ConsultationNotifier notifier) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.triageHijau,
            AppColors.triageHijau.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.triageHijau.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.telekonsultasiMedis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Konsultasi dengan dokter via WhatsApp',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Isi form konsultasi dan kirim ke WhatsApp untuk memulai konsultasi dengan dokter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Button Buat Konsultasi Baru
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConsultationFormPage(),
                  ),
                );
                // Refresh setelah form ditutup
                if (mounted) {
                  context.read<ConsultationNotifier>().loadConsultations();
                }
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                'Buat Konsultasi Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.triageHijau.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: AppColors.triageHijau,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(
    BuildContext context,
    Teleconsultation consultation,
    ConsultationNotifier notifier,
  ) {
    Color statusColor;
    IconData statusIcon;
    
    switch (consultation.status) {
      case ConsultationStatus.menunggu:
        statusColor = AppColors.statusMenunggu;
        statusIcon = Icons.access_time;
        break;
      case ConsultationStatus.berlangsung:
        statusColor = AppColors.statusDitangani;
        statusIcon = Icons.chat_bubble;
        break;
      case ConsultationStatus.selesai:
        statusColor = AppColors.statusSelesai;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (consultation.isActive) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConsultationChatPage(consultationId: consultation.id!),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConsultationDetailPage(consultationId: consultation.id!),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consultation.doctorName ?? 'Menunggu dokter',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          consultation.complaint,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (consultation.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${consultation.startTime.day}/${consultation.startTime.month}/${consultation.startTime.year} ${consultation.startTime.hour}:${consultation.startTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      consultation.status.displayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

