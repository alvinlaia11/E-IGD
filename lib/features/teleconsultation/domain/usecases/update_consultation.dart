import '../entities/teleconsultation.dart';
import '../repositories/teleconsultation_repository.dart';

class UpdateConsultation {
  final TeleconsultationRepository repository;

  UpdateConsultation(this.repository);

  Future<int> call(Teleconsultation consultation) async {
    return await repository.updateConsultation(consultation);
  }
}

