import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'features/emergency/data/datasources/patient_local_datasource.dart';
import 'features/emergency/data/repositories/patient_repository_impl.dart';
import 'features/emergency/domain/usecases/get_all_patients.dart';
import 'features/emergency/domain/usecases/get_patient_by_id.dart';
import 'features/emergency/domain/usecases/insert_patient.dart';
import 'features/emergency/domain/usecases/update_patient.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/emergency/presentation/pages/splash_page.dart';
import 'features/emergency/presentation/pages/home_page.dart';
import 'features/emergency/presentation/pages/patient_form_page.dart';
import 'features/emergency/presentation/pages/patient_detail_page.dart';
import 'features/emergency/presentation/providers/patient_list_notifier.dart';
import 'features/emergency/presentation/providers/patient_detail_notifier.dart';
import 'features/teleconsultation/data/datasources/teleconsultation_local_datasource.dart';
import 'features/teleconsultation/data/repositories/teleconsultation_repository_impl.dart';
import 'features/teleconsultation/domain/usecases/create_consultation.dart';
import 'features/teleconsultation/domain/usecases/get_all_consultations.dart';
import 'features/teleconsultation/domain/usecases/get_consultation_by_id.dart';
import 'features/teleconsultation/domain/usecases/update_consultation.dart';
import 'features/teleconsultation/presentation/providers/consultation_notifier.dart';
import 'features/teleconsultation/presentation/pages/teleconsultation_home_page.dart';
import 'features/teleconsultation/presentation/pages/consultation_form_page.dart';
import 'features/teleconsultation/presentation/pages/consultation_chat_page.dart';
import 'features/teleconsultation/presentation/pages/consultation_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize locale data for intl package
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize data source
    final dataSource = PatientLocalDataSource.instance;
    final repository = PatientRepositoryImpl(dataSource);

    // Initialize use cases
    final getAllPatients = GetAllPatients(repository);
    final getPatientById = GetPatientById(repository);
    final insertPatient = InsertPatient(repository);
    final updatePatient = UpdatePatient(repository);

    // Initialize teleconsultation
    final consultationDataSource = TeleconsultationLocalDataSource.instance;
    final consultationRepository = TeleconsultationRepositoryImpl(consultationDataSource);
    final createConsultation = CreateConsultation(consultationRepository);
    final getAllConsultations = GetAllConsultations(consultationRepository);
    final getConsultationById = GetConsultationById(consultationRepository);
    final updateConsultation = UpdateConsultation(consultationRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PatientListNotifier(
            getAllPatients: getAllPatients,
            insertPatient: insertPatient,
            updatePatient: updatePatient,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PatientDetailNotifier(
            getPatientById: getPatientById,
            updatePatient: updatePatient,
            insertPatient: insertPatient,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ConsultationNotifier(
            createConsultation: createConsultation,
            getAllConsultations: getAllConsultations,
            getConsultationById: getConsultationById,
            updateConsultation: updateConsultation,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'E-IGD',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashPage(),
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.register: (context) => const RegisterPage(),
          AppRoutes.home: (context) => const HomePage(),
          AppRoutes.patientForm: (context) => const PatientFormPage(),
          AppRoutes.patientDetail: (context) {
            final patientId = ModalRoute.of(context)!.settings.arguments as int;
            return PatientDetailPage(patientId: patientId);
          },
          AppRoutes.teleconsultation: (context) => const TeleconsultationHomePage(),
          AppRoutes.consultationForm: (context) => const ConsultationFormPage(),
          AppRoutes.consultationChat: (context) {
            final consultationId = ModalRoute.of(context)!.settings.arguments as int;
            return ConsultationChatPage(consultationId: consultationId);
          },
          AppRoutes.consultationDetail: (context) {
            final consultationId = ModalRoute.of(context)!.settings.arguments as int;
            return ConsultationDetailPage(consultationId: consultationId);
          },
        },
      ),
    );
  }
}
