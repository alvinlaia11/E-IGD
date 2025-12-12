import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_local_datasource.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDataSource dataSource;

  PatientRepositoryImpl(this.dataSource);

  @override
  Future<int> insertPatient(Patient patient) async {
    final model = PatientModel.fromEntity(patient);
    return await dataSource.insertPatient(model);
  }

  @override
  Future<List<Patient>> getAllPatients() async {
    final models = await dataSource.getAllPatients();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Patient>> getPatientsByDate(DateTime date) async {
    final models = await dataSource.getPatientsByDate(date);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Patient?> getPatientById(int id) async {
    final model = await dataSource.getPatientById(id);
    return model?.toEntity();
  }

  @override
  Future<int> updatePatient(Patient patient) async {
    final model = PatientModel.fromEntity(patient);
    return await dataSource.updatePatient(model);
  }

  @override
  Future<int> deletePatient(int id) async {
    return await dataSource.deletePatient(id);
  }
}

