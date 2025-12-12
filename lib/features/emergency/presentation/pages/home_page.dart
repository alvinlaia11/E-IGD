import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/patient_list_notifier.dart';
import 'dashboard_page.dart';
import 'report_page.dart';
import 'emergency_form_page.dart';
import 'ambulans_form_page.dart';
import '../../../teleconsultation/presentation/pages/teleconsultation_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const TeleconsultationHomePage(),
    const ReportPage(),
  ];

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showEmergencyTypeDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.triageMerah,
                        AppColors.triageMerah.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.layananGawatDarurat,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppStrings.pilihJenisEmergency,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Kecelakaan
                      _buildEmergencyOption(
                        context: dialogContext,
                        icon: Icons.car_crash,
                        title: AppStrings.penangananKecelakaan,
                        subtitle: 'Untuk pasien korban kecelakaan',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmergencyFormPage(
                                emergencyType: EmergencyType.kecelakaan,
                              ),
                            ),
                          ).then((_) {
                            // Refresh data setelah kembali
                            if (mounted) {
                              context.read<PatientListNotifier>().loadPatients();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Kebakaran
                      _buildEmergencyOption(
                        context: dialogContext,
                        icon: Icons.local_fire_department,
                        title: AppStrings.penangananKebakaran,
                        subtitle: 'Untuk pasien korban kebakaran',
                        color: Colors.red,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmergencyFormPage(
                                emergencyType: EmergencyType.kebakaran,
                              ),
                            ),
                          ).then((_) {
                            // Refresh data setelah kembali
                            if (mounted) {
                              context.read<PatientListNotifier>().loadPatients();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Ambulans
                      _buildEmergencyOption(
                        context: dialogContext,
                        icon: Icons.local_hospital,
                        title: AppStrings.layananAmbulans,
                        subtitle: 'Panggil ambulans dengan Google Maps',
                        color: AppColors.triageMerah,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AmbulansFormPage(),
                            ),
                          ).then((_) {
                            // Refresh data setelah kembali
                            if (mounted) {
                              context.read<PatientListNotifier>().loadPatients();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.08),
                color.withOpacity(0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon dengan gradient background
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              // Text content
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
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Arrow icon dengan background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Dashboard Button
          Expanded(
            child: InkWell(
              onTap: () => _navigateToPage(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard,
                    color: _currentIndex == 0
                        ? AppColors.triageMerah
                        : Colors.grey[600],
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentIndex == 0
                          ? AppColors.triageMerah
                          : Colors.grey[600],
                      fontWeight: _currentIndex == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Telekonsultasi Button
          Expanded(
            child: InkWell(
              onTap: () => _navigateToPage(1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    color: _currentIndex == 1
                        ? AppColors.triageHijau
                        : Colors.grey[600],
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Konsultasi',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentIndex == 1
                          ? AppColors.triageHijau
                          : Colors.grey[600],
                      fontWeight: _currentIndex == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Laporan Button
          Expanded(
            child: InkWell(
              onTap: () => _navigateToPage(2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment,
                    color: _currentIndex == 2
                        ? AppColors.triageMerah
                        : Colors.grey[600],
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Laporan',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentIndex == 2
                          ? AppColors.triageMerah
                          : Colors.grey[600],
                      fontWeight: _currentIndex == 2
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

