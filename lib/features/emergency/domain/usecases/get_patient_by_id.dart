import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetPatientById {
  final PatientRepository repository;

  GetPatientById(this.repository);

  Future<Patient?> call(int id) async {
    return await repository.getPatientById(id);
  }
}

