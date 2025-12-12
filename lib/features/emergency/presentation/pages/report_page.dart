import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/export_utils.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_list_notifier.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime _selectedDate = DateTime.now();
  List<Patient> _patients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = context.read<PatientListNotifier>();
      await notifier.loadPatients();
      final allPatients = notifier.allPatients;
      _patients = allPatients.where((p) {
        return DateTimeUtils.isSameDay(p.waktuKedatangan, _selectedDate);
      }).toList();
    } catch (e) {
      _patients = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReport();
    }
  }

  int _getCountByTriage(TriageLevel triage) {
    return _patients.where((p) => p.kategoriTriage == triage).length;
  }

  int _getCountByStatus(StatusPenanganan status) {
    return _patients.where((p) => p.statusPenanganan == status).length;
  }

  double _getPercentage(int count, int total) {
    if (total == 0) return 0.0;
    return (count / total) * 100;
  }

  String _getDayName(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return days[date.weekday % 7];
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.file_download, color: AppColors.triageMerah, size: 28),
              const SizedBox(width: 8),
              const Text(AppStrings.exportLaporan),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.pilihFormatExport,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // Export CSV
              _buildExportOption(
                context: dialogContext,
                icon: Icons.table_chart,
                title: AppStrings.exportCSV,
                subtitle: 'Format untuk Excel/Spreadsheet',
                color: Colors.green,
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _exportData('csv');
                },
              ),
              const SizedBox(height: 12),
              // Export Text
              _buildExportOption(
                context: dialogContext,
                icon: Icons.description,
                title: AppStrings.exportText,
                subtitle: 'Format teks yang mudah dibaca',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _exportData('text');
                },
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(String format) async {
    try {
      final total = _patients.length;
      final merahCount = _getCountByTriage(TriageLevel.merah);
      final kuningCount = _getCountByTriage(TriageLevel.kuning);
      final hijauCount = _getCountByTriage(TriageLevel.hijau);
      final menungguCount = _getCountByStatus(StatusPenanganan.menunggu);
      final ditanganiCount = _getCountByStatus(StatusPenanganan.ditangani);
      final selesaiCount = _getCountByStatus(StatusPenanganan.selesai);

      final ambulansCount = _getAmbulansCount();
      final ambulansWaiting = _getAmbulansWaitingCount();
      final ambulansInProgress = _getAmbulansInProgressCount();
      final ambulansArrived = _getAmbulansArrivedCount();

      final statistics = {
        'total': total,
        'merah': merahCount,
        'kuning': kuningCount,
        'hijau': hijauCount,
        'menunggu': menungguCount,
        'ditangani': ditanganiCount,
        'selesai': selesaiCount,
        'ambulans': ambulansCount,
        'ambulans_waiting': ambulansWaiting,
        'ambulans_in_progress': ambulansInProgress,
        'ambulans_arrived': ambulansArrived,
      };

      String content;
      String fileName;

      if (format == 'csv') {
        content = ExportUtils.exportToCSV(
          _patients,
          selectedDate: _selectedDate,
          statistics: statistics,
        );
        fileName = 'Laporan_E-IGD_${DateTimeUtils.formatDate(_selectedDate).replaceAll('/', '-')}.csv';
      } else {
        content = ExportUtils.exportToText(
          _patients,
          selectedDate: _selectedDate,
          statistics: statistics,
        );
        fileName = 'Laporan_E-IGD_${DateTimeUtils.formatDate(_selectedDate).replaceAll('/', '-')}.txt';
      }

      // Create temporary file and share
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);
      
      // Share file
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Pasien E-IGD - ${DateTimeUtils.formatDate(_selectedDate)}',
      );

      if (mounted) {
        if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.laporanBerhasilDiexport),
              backgroundColor: AppColors.statusSelesai,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.exportGagal}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _getAmbulansCount() {
    return _patients.where((p) => p.isAmbulansCall).length;
  }

  int _getAmbulansWaitingCount() {
    return _patients.where((p) => 
      p.isAmbulansCall && 
      (p.statusAmbulans == AppStrings.menungguAmbulans || p.statusAmbulans == null)
    ).length;
  }

  int _getAmbulansInProgressCount() {
    return _patients.where((p) => 
      p.isAmbulansCall && 
      p.statusAmbulans == AppStrings.ambulansDalamPerjalanan
    ).length;
  }

  int _getAmbulansArrivedCount() {
    return _patients.where((p) => 
      p.isAmbulansCall && 
      p.statusAmbulans == AppStrings.ambulansSampai
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    final total = _patients.length;
    final merahCount = _getCountByTriage(TriageLevel.merah);
    final kuningCount = _getCountByTriage(TriageLevel.kuning);
    final hijauCount = _getCountByTriage(TriageLevel.hijau);
    final menungguCount = _getCountByStatus(StatusPenanganan.menunggu);
    final ditanganiCount = _getCountByStatus(StatusPenanganan.ditangani);
    final selesaiCount = _getCountByStatus(StatusPenanganan.selesai);
    final ambulansCount = _getAmbulansCount();
    final ambulansWaiting = _getAmbulansWaitingCount();
    final ambulansInProgress = _getAmbulansInProgressCount();
    final ambulansArrived = _getAmbulansArrivedCount();

    return Scaffold(
      appBar: AppBar(
        title: const AppBarLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _showExportDialog,
            tooltip: AppStrings.exportLaporan,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Picker Card - Modern Design
                    _buildDatePickerCard(),
                    const SizedBox(height: 20),

                    // Total Pasien - Hero Card
                    _buildHeroCard(total),
                    const SizedBox(height: 20),

                    // Triage Statistics - Enhanced
                    _buildTriageSection(merahCount, kuningCount, hijauCount, total),
                    const SizedBox(height: 20),

                    // Status Statistics - Enhanced
                    _buildStatusSection(menungguCount, ditanganiCount, selesaiCount, total),
                    const SizedBox(height: 20),

                    // Ambulans Statistics (if any)
                    if (ambulansCount > 0) ...[
                      _buildAmbulansSection(
                        ambulansCount,
                        ambulansWaiting,
                        ambulansInProgress,
                        ambulansArrived,
                        total,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Additional Info
                    if (_patients.isNotEmpty) _buildAdditionalInfo(total, ambulansCount),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDatePickerCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.triageMerah, AppColors.triageMerah.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.triageMerah.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Tanggal Laporan',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getDayName(_selectedDate)}, ${DateTimeUtils.formatDate(_selectedDate)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pasien',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    total.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.triageMerah,
                      height: 1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.triageMerah.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 40,
                  color: AppColors.triageMerah,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTriageSection(int merah, int kuning, int hijau, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flag, color: AppColors.triageMerah, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Statistik Berdasarkan Triage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTriageCard(
          'MERAH',
          merah,
          AppColors.triageMerah,
          Icons.priority_high,
          _getPercentage(merah, total),
          total,
        ),
        const SizedBox(height: 12),
        _buildTriageCard(
          'KUNING',
          kuning,
          AppColors.triageKuning,
          Icons.warning_amber_rounded,
          _getPercentage(kuning, total),
          total,
        ),
        const SizedBox(height: 12),
        _buildTriageCard(
          'HIJAU',
          hijau,
          AppColors.triageHijau,
          Icons.check_circle_outline,
          _getPercentage(hijau, total),
          total,
        ),
      ],
    );
  }

  Widget _buildTriageCard(
    String label,
    int count,
    Color color,
    IconData icon,
    double percentage,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count pasien',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection(int menunggu, int ditangani, int selesai, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_outlined, color: AppColors.statusDitangani, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Statistik Berdasarkan Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatusCard(
          'MENUNGGU',
          menunggu,
          AppColors.statusMenunggu,
          Icons.hourglass_empty,
          _getPercentage(menunggu, total),
          total,
        ),
        const SizedBox(height: 12),
        _buildStatusCard(
          'DITANGANI',
          ditangani,
          AppColors.statusDitangani,
          Icons.medical_services,
          _getPercentage(ditangani, total),
          total,
        ),
        const SizedBox(height: 12),
        _buildStatusCard(
          'SELESAI',
          selesai,
          AppColors.statusSelesai,
          Icons.check_circle,
          _getPercentage(selesai, total),
          total,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String label,
    int count,
    Color color,
    IconData icon,
    double percentage,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count pasien',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmbulansSection(
    int totalAmbulans,
    int waiting,
    int inProgress,
    int arrived,
    int totalPatients,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.red[700], size: 24),
            const SizedBox(width: 8),
            const Text(
              'Statistik Ambulans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Total Ambulans
              _buildAmbulansStatRow(
                'Total Pemanggilan',
                totalAmbulans.toString(),
                Colors.blue,
                Icons.call,
                _getPercentage(totalAmbulans, totalPatients),
                totalPatients,
              ),
              const SizedBox(height: 16),
              // Status Breakdown
              Row(
                children: [
                  Expanded(
                    child: _buildAmbulansMiniCard(
                      'Menunggu',
                      waiting.toString(),
                      Colors.orange,
                      Icons.hourglass_empty,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (inProgress > 0)
                    Expanded(
                      child: _buildAmbulansMiniCard(
                        'Dalam Perjalanan',
                        inProgress.toString(),
                        Colors.blue,
                        Icons.directions_car,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (inProgress > 0 && arrived > 0) const SizedBox(width: 12),
                  if (arrived > 0)
                    Expanded(
                      child: _buildAmbulansMiniCard(
                        'Sampai',
                        arrived.toString(),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmbulansStatRow(
    String label,
    String value,
    Color color,
    IconData icon,
    double percentage,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$value dari $total pasien',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${percentage.toStringAsFixed(1)}% dari total pasien',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmbulansMiniCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(int total, int ambulansCount) {
    // Calculate peak hour
    final hourCounts = <int, int>{};
    for (var patient in _patients) {
      final hour = patient.waktuKedatangan.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    final peakHour = hourCounts.entries.isNotEmpty
        ? hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    // Calculate average response time (if we have completion data)
    final completedPatients = _patients.where((p) => 
      p.statusPenanganan == StatusPenanganan.selesai
    ).toList();
    
    String? avgResponseTime;
    if (completedPatients.isNotEmpty) {
      final totalMinutes = completedPatients.fold<int>(0, (sum, p) {
        final diff = p.updatedAt.difference(p.waktuKedatangan);
        return sum + diff.inMinutes;
      });
      final avgMinutes = (totalMinutes / completedPatients.length).round();
      if (avgMinutes < 60) {
        avgResponseTime = '$avgMinutes menit';
      } else {
        final hours = avgMinutes ~/ 60;
        final minutes = avgMinutes % 60;
        avgResponseTime = minutes > 0 ? '$hours jam $minutes menit' : '$hours jam';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.statusDitangani, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Informasi Tambahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (peakHour != null)
            _buildInfoRow(
              Icons.access_time,
              'Jam Puncak',
              '${peakHour.toString().padLeft(2, '0')}:00 - ${(peakHour + 1).toString().padLeft(2, '0')}:00',
            ),
          if (peakHour != null) const SizedBox(height: 12),
          _buildInfoRow(
            Icons.trending_up,
            'Pasien Emergency (MERAH)',
            '${_getCountByTriage(TriageLevel.merah)} pasien',
            AppColors.triageMerah,
          ),
          const SizedBox(height: 12),
          if (ambulansCount > 0)
            _buildInfoRow(
              Icons.local_hospital,
              'Pemanggilan Ambulans',
              '$ambulansCount pemanggilan',
              Colors.red,
            ),
          if (ambulansCount > 0) const SizedBox(height: 12),
          if (avgResponseTime != null)
            _buildInfoRow(
              Icons.timer,
              'Rata-rata Waktu Respon',
              avgResponseTime,
              AppColors.statusDitangani,
            ),
          if (avgResponseTime != null) const SizedBox(height: 12),
          _buildInfoRow(
            Icons.check_circle_outline,
            'Pasien Selesai',
            '${_getCountByStatus(StatusPenanganan.selesai)} pasien',
            AppColors.statusSelesai,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, [Color? color]) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.grey[900],
          ),
        ),
      ],
    );
  }
}
