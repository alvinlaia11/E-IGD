import '../entities/consultation_message.dart';
import '../repositories/teleconsultation_repository.dart';

class SendMessage {
  final TeleconsultationRepository repository;

  SendMessage(this.repository);

  Future<int> call(ConsultationMessage message) async {
    return await repository.insertMessage(message);
  }
}

