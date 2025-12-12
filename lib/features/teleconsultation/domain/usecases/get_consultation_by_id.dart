import '../entities/teleconsultation.dart';
import '../repositories/teleconsultation_repository.dart';

class GetConsultationById {
  final TeleconsultationRepository repository;

  GetConsultationById(this.repository);

  Future<Teleconsultation?> call(int id) async {
    return await repository.getConsultationById(id);
  }
}

