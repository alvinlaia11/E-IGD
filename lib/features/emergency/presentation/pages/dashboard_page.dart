import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_list_notifier.dart';
import '../widgets/patient_card.dart';
import 'emergency_form_page.dart';
import 'ambulans_form_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientListNotifier>().loadPatients();
    });
  }


  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const AppBarLogo(),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<PatientListNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading && notifier.patients.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifier.errorMessage != null && notifier.patients.isEmpty) {
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
                    onPressed: () => notifier.loadPatients(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final totalPatients = notifier.allPatients.length;
          final filteredCount = notifier.patients.length;

          return RefreshIndicator(
            onRefresh: () => notifier.loadPatients(),
            color: AppColors.triageMerah,
            child: CustomScrollView(
              controller: _scrollController,
            slivers: [
              // Emergency Button - Before Total Pasien
              SliverToBoxAdapter(
                child: _buildEmergencyButton(),
              ),
              // Emergency Alert Banner
              if (notifier.hasEmergencyWaiting)
                SliverToBoxAdapter(
                  child: _buildEmergencyBanner(notifier),
                ),

              // Ambulans Alert Banner
              if (notifier.hasAmbulansWaiting)
                SliverToBoxAdapter(
                  child: _buildAmbulansBanner(notifier),
                ),

              // Header Summary Card
              SliverToBoxAdapter(
                child: _buildHeaderSummary(notifier, totalPatients, filteredCount),
              ),

              // Quick Stats Row (Updated with more stats)
              SliverToBoxAdapter(
                child: _buildQuickStats(notifier),
              ),

              // Ambulans Statistics (if any)
              if (notifier.ambulansCallCount > 0)
                SliverToBoxAdapter(
                  child: _buildAmbulansStatistics(notifier),
                ),

              // Triage Statistics
              SliverToBoxAdapter(
                child: _buildTriageStatistics(notifier),
              ),

              // Charts Section
              SliverToBoxAdapter(
                child: _buildChartsSection(notifier),
              ),

              // Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              // Search and Filter Section
              SliverToBoxAdapter(
                child: _buildSearchAndFilter(notifier),
              ),

              // Patient List
              if (notifier.patients.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: const EmptyState(message: AppStrings.belumAdaPasien),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final patient = notifier.patients[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PatientCard(
                            patient: patient,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.patientDetail,
                                arguments: patient.id,
                              );
                            },
                          ),
                        );
                      },
                      childCount: notifier.patients.length,
                    ),
                  ),
                ),
            ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.patientForm);
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.tambahPasien),
        backgroundColor: AppColors.triageMerah,
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Navigate to login page and clear navigation stack
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.triageMerah,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAmbulansBanner(PatientListNotifier notifier) {
    return GestureDetector(
      onTap: () {
        // Filter untuk menampilkan hanya pasien yang memanggil ambulans
        notifier.setSearchQuery('');
        notifier.setSelectedTriage(null);
        notifier.setFilterAmbulansOnly(true);
        
        // Scroll ke bagian daftar pasien
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              600,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red[700]!,
              Colors.red[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ada pemanggilan ambulans yang menunggu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${notifier.ambulansWaitingCount} pemanggilan menunggu',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbulansStatistics(PatientListNotifier notifier) {
    final totalAmbulans = notifier.ambulansCallCount;
    final waiting = notifier.ambulansWaitingCount;
    final inProgress = notifier.allPatients.where((p) => 
      p.isAmbulansCall && 
      p.statusAmbulans == AppStrings.ambulansDalamPerjalanan
    ).length;
    final arrived = notifier.allPatients.where((p) => 
      p.isAmbulansCall && 
      p.statusAmbulans == AppStrings.ambulansSampai
    ).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
          Row(
            children: [
              Expanded(
                child: _buildAmbulansStatItem(
                  'Total',
                  totalAmbulans.toString(),
                  Colors.blue,
                  Icons.call,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAmbulansStatItem(
                  'Menunggu',
                  waiting.toString(),
                  Colors.orange,
                  Icons.hourglass_empty,
                ),
              ),
            ],
          ),
          if (inProgress > 0 || arrived > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (inProgress > 0)
                  Expanded(
                    child: _buildAmbulansStatItem(
                      'Dalam Perjalanan',
                      inProgress.toString(),
                      Colors.blue,
                      Icons.directions_car,
                    ),
                  ),
                if (inProgress > 0 && arrived > 0) const SizedBox(width: 8),
                if (arrived > 0)
                  Expanded(
                    child: _buildAmbulansStatItem(
                      'Sampai',
                      arrived.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmbulansStatItem(
      String label, String value, Color color, IconData icon) {
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

  Widget _buildEmergencyButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Material(
              elevation: 8 + (_pulseAnimation.value - 1) * 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: AppColors.triageMerah.withOpacity(0.6),
              child: InkWell(
                onTap: () => _showEmergencyDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.triageMerah,
                        AppColors.triageMerah.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.triageMerah.withOpacity(0.4 + (_pulseAnimation.value - 1) * 0.2),
                        blurRadius: 12 + (_pulseAnimation.value - 1) * 8,
                        spreadRadius: 2 + (_pulseAnimation.value - 1) * 2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.triageMerah.withOpacity(0.2 + (_pulseAnimation.value - 1) * 0.1),
                        blurRadius: 20 + (_pulseAnimation.value - 1) * 10,
                        spreadRadius: 4 + (_pulseAnimation.value - 1) * 2,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'LAYANAN GAWAT DARURAT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmergencyBanner(PatientListNotifier notifier) {
    return GestureDetector(
      onTap: () {
        // Set filter ke MERAH dan clear search
        notifier.setSearchQuery('');
        notifier.setSelectedTriage(TriageLevel.merah);
        
        // Scroll ke bagian daftar pasien setelah filter di-set
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            // Scroll ke posisi yang cukup untuk melewati header dan stats
            _scrollController.animateTo(
              600, // Posisi estimasi untuk mencapai daftar pasien
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.triageMerah,
              AppColors.triageMerah.withOpacity(0.9),
            ],
          ),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                AppStrings.emergencyAlert,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummary(
      PatientListNotifier notifier, int total, int filtered) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.triageMerah,
            AppColors.triageMerah.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.triageMerah.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pasien',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    total.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
          if (filtered != total) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Menampilkan $filtered dari $total pasien',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(PatientListNotifier notifier) {
    final menunggu = notifier.allPatients
        .where((p) => p.statusPenanganan == StatusPenanganan.menunggu)
        .length;
    final ditangani = notifier.ditanganiCount;
    final selesai = notifier.allPatients
        .where((p) => p.statusPenanganan == StatusPenanganan.selesai)
        .length;
    final ambulans = notifier.ambulansCallCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // First Row: Menunggu & Ditangani
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Menunggu',
                  menunggu.toString(),
                  AppColors.statusMenunggu,
                  Icons.hourglass_empty,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Ditangani',
                  ditangani.toString(),
                  AppColors.statusDitangani,
                  Icons.medical_services,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second Row: Selesai & Ambulans
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Selesai',
                  selesai.toString(),
                  AppColors.statusSelesai,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Ambulans',
                  ambulans.toString(),
                  Colors.red,
                  Icons.local_hospital,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTriageStatistics(PatientListNotifier notifier) {
    final total = notifier.allPatients.length;
    final merah = notifier.merahCount;
    final kuning = notifier.kuningCount;
    final hijau = notifier.hijauCount;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: AppColors.triageMerah, size: 24),
              const SizedBox(width: 8),
              const Text(
                AppStrings.statistikTriage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTriageStatCard(
            'MERAH',
            merah,
            AppColors.triageMerah,
            Icons.priority_high,
            total > 0 ? (merah / total) : 0.0,
          ),
          const SizedBox(height: 12),
          _buildTriageStatCard(
            'KUNING',
            kuning,
            AppColors.triageKuning,
            Icons.warning_amber_rounded,
            total > 0 ? (kuning / total) : 0.0,
          ),
          const SizedBox(height: 12),
          _buildTriageStatCard(
            'HIJAU',
            hijau,
            AppColors.triageHijau,
            Icons.check_circle_outline,
            total > 0 ? (hijau / total) : 0.0,
          ),
        ],
      ),
    );
  }

  Widget _buildTriageStatCard(
      String label, int count, Color color, IconData icon, double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          if (percentage > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
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

  // Helper method to identify emergency type
  String _getEmergencyType(Patient patient) {
    final keluhan = patient.keluhanUtama.toLowerCase();
    
    // Check for ambulans
    if (patient.isAmbulansCall) {
      return 'ambulans';
    }
    
    // Check for kecelakaan
    if (keluhan.contains('kecelakaan') || 
        keluhan.contains('accident') ||
        keluhan.contains('tabrakan') ||
        keluhan.contains(AppStrings.detailKecelakaan.toLowerCase())) {
      return 'kecelakaan';
    }
    
    // Check for kebakaran
    if (keluhan.contains('kebakaran') || 
        keluhan.contains('fire') ||
        keluhan.contains('bakar') ||
        keluhan.contains(AppStrings.detailKebakaran.toLowerCase())) {
      return 'kebakaran';
    }
    
    return 'lainnya';
  }

  Widget _buildChartsSection(PatientListNotifier notifier) {
    final allPatients = notifier.allPatients;
    
    // Calculate emergency type counts
    int kecelakaanCount = 0;
    int kebakaranCount = 0;
    int ambulansCount = 0;
    
    for (var patient in allPatients) {
      final type = _getEmergencyType(patient);
      switch (type) {
        case 'kecelakaan':
          kecelakaanCount++;
          break;
        case 'kebakaran':
          kebakaranCount++;
          break;
        case 'ambulans':
          ambulansCount++;
          break;
      }
    }
    
    // Only show chart if there's data
    if (kecelakaanCount == 0 && kebakaranCount == 0 && ambulansCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
          // Title with padding
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Icon(Icons.pie_chart, color: AppColors.triageMerah, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Grafik Laporan Masyarakat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Always use column layout for better spacing
          Column(
            children: [
              // Pie Chart with padding
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: SizedBox(
                  height: 220,
                  child: _buildPieChart(
                    kecelakaanCount,
                    kebakaranCount,
                    ambulansCount,
                  ),
                ),
              ),
              // Legend with padding
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: _buildPieChartLegend(
                  kecelakaanCount,
                  kebakaranCount,
                  ambulansCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(int kecelakaan, int kebakaran, int ambulans) {
    final total = kecelakaan + kebakaran + ambulans;
    if (total == 0) {
      return const Center(
        child: Text(
          'Tidak ada data',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: [
          if (kecelakaan > 0)
            PieChartSectionData(
              value: kecelakaan.toDouble(),
              title: '${((kecelakaan / total) * 100).toStringAsFixed(0)}%',
              color: Colors.orange,
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (kebakaran > 0)
            PieChartSectionData(
              value: kebakaran.toDouble(),
              title: '${((kebakaran / total) * 100).toStringAsFixed(0)}%',
              color: Colors.red,
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (ambulans > 0)
            PieChartSectionData(
              value: ambulans.toDouble(),
              title: '${((ambulans / total) * 100).toStringAsFixed(0)}%',
              color: Colors.blue,
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend(int kecelakaan, int kebakaran, int ambulans) {
    final total = kecelakaan + kebakaran + ambulans;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          if (kecelakaan > 0)
            _buildLegendItem(
              'Kecelakaan',
              kecelakaan,
              Colors.orange,
              total,
            ),
          if (kebakaran > 0)
            _buildLegendItem(
              'Kebakaran',
              kebakaran,
              Colors.red,
              total,
            ),
          if (ambulans > 0)
            _buildLegendItem(
              'Ambulans',
              ambulans,
              Colors.blue,
              total,
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count kasus (${((count / total) * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(PatientListNotifier notifier) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.cariPasien,
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: notifier.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () => notifier.setSearchQuery(''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                notifier.setSearchQuery(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Filter Section
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Filter Triage',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context: context,
                  label: AppStrings.semuaTriage,
                  isSelected: notifier.selectedTriage == null && !notifier.filterAmbulansOnly,
                  onTap: () {
                    notifier.setSelectedTriage(null);
                    notifier.setFilterAmbulansOnly(false);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: TriageLevel.merah.displayName,
                  isSelected: notifier.selectedTriage == TriageLevel.merah,
                  color: AppColors.triageMerah,
                  onTap: () => notifier.setSelectedTriage(TriageLevel.merah),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: TriageLevel.kuning.displayName,
                  isSelected: notifier.selectedTriage == TriageLevel.kuning,
                  color: AppColors.triageKuning,
                  onTap: () => notifier.setSelectedTriage(TriageLevel.kuning),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: TriageLevel.hijau.displayName,
                  isSelected: notifier.selectedTriage == TriageLevel.hijau,
                  color: AppColors.triageHijau,
                  onTap: () => notifier.setSelectedTriage(TriageLevel.hijau),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color?.withOpacity(0.15),
      checkmarkColor: color,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppColors.triageMerah) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
