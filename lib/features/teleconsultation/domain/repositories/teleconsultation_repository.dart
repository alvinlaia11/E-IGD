import '../entities/teleconsultation.dart';
import '../entities/consultation_message.dart';

abstract class TeleconsultationRepository {
  Future<int> insertConsultation(Teleconsultation consultation);
  Future<List<Teleconsultation>> getAllConsultations();
  Future<List<Teleconsultation>> getConsultationsByStatus(String status);
  Future<Teleconsultation?> getConsultationById(int id);
  Future<int> updateConsultation(Teleconsultation consultation);
  Future<int> deleteConsultation(int id);
  
  // Messages
  Future<int> insertMessage(ConsultationMessage message);
  Future<List<ConsultationMessage>> getMessagesByConsultationId(int consultationId);
  Future<int> deleteMessage(int id);
}

