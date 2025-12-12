import '../entities/consultation_message.dart';
import '../repositories/teleconsultation_repository.dart';

class GetMessages {
  final TeleconsultationRepository repository;

  GetMessages(this.repository);

  Future<List<ConsultationMessage>> call(int consultationId) async {
    return await repository.getMessagesByConsultationId(consultationId);
  }
}

