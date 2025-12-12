import '../entities/teleconsultation.dart';
import '../repositories/teleconsultation_repository.dart';

class CreateConsultation {
  final TeleconsultationRepository repository;

  CreateConsultation(this.repository);

  Future<int> call(Teleconsultation consultation) async {
    return await repository.insertConsultation(consultation);
  }
}

