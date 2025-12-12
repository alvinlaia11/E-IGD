import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class InsertPatient {
  final PatientRepository repository;

  InsertPatient(this.repository);

  Future<int> call(Patient patient) async {
    return await repository.insertPatient(patient);
  }
}

