import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetPatientsByDate {
  final PatientRepository repository;

  GetPatientsByDate(this.repository);

  Future<List<Patient>> call(DateTime date) async {
    return await repository.getPatientsByDate(date);
  }
}

