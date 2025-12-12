import '../entities/patient.dart';

abstract class PatientRepository {
  Future<int> insertPatient(Patient patient);
  Future<List<Patient>> getAllPatients();
  Future<List<Patient>> getPatientsByDate(DateTime date);
  Future<Patient?> getPatientById(int id);
  Future<int> updatePatient(Patient patient);
  Future<int> deletePatient(int id);
}

