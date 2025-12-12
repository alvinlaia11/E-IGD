import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetAllPatients {
  final PatientRepository repository;

  GetAllPatients(this.repository);

  Future<List<Patient>> call() async {
    return await repository.getAllPatients();
  }
}

