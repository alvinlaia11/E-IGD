import '../entities/teleconsultation.dart';
import '../repositories/teleconsultation_repository.dart';

class GetAllConsultations {
  final TeleconsultationRepository repository;

  GetAllConsultations(this.repository);

  Future<List<Teleconsultation>> call() async {
    return await repository.getAllConsultations();
  }
}

