import '../../domain/repositories/teleconsultation_repository.dart';
import '../../domain/entities/teleconsultation.dart';
import '../../domain/entities/consultation_message.dart';
import '../models/teleconsultation_model.dart';
import '../models/consultation_message_model.dart';
import '../datasources/teleconsultation_local_datasource.dart';

class TeleconsultationRepositoryImpl implements TeleconsultationRepository {
  final TeleconsultationLocalDataSource dataSource;

  TeleconsultationRepositoryImpl(this.dataSource);

  @override
  Future<int> insertConsultation(Teleconsultation consultation) async {
    return await dataSource.insertConsultation(
      TeleconsultationModel(
        id: consultation.id,
        patientId: consultation.patientId,
        patientName: consultation.patientName,
        patientPhone: consultation.patientPhone,
        patientEmail: consultation.patientEmail,
        doctorId: consultation.doctorId,
        doctorName: consultation.doctorName,
        complaint: consultation.complaint,
        consultationType: consultation.consultationType,
        priority: consultation.priority,
        status: consultation.status,
        diagnosis: consultation.diagnosis,
        prescription: consultation.prescription,
        recommendation: consultation.recommendation,
        referredToIGD: consultation.referredToIGD,
        igdPatientId: consultation.igdPatientId,
        triageLevel: consultation.triageLevel,
        startTime: consultation.startTime,
        endTime: consultation.endTime,
        duration: consultation.duration,
        createdAt: consultation.createdAt,
        updatedAt: consultation.updatedAt,
      ),
    );
  }

  @override
  Future<List<Teleconsultation>> getAllConsultations() async {
    final models = await dataSource.getAllConsultations();
    return models;
  }

  @override
  Future<List<Teleconsultation>> getConsultationsByStatus(String status) async {
    final models = await dataSource.getConsultationsByStatus(status);
    return models;
  }

  @override
  Future<Teleconsultation?> getConsultationById(int id) async {
    return await dataSource.getConsultationById(id);
  }

  @override
  Future<int> updateConsultation(Teleconsultation consultation) async {
    return await dataSource.updateConsultation(
      TeleconsultationModel(
        id: consultation.id,
        patientId: consultation.patientId,
        patientName: consultation.patientName,
        patientPhone: consultation.patientPhone,
        patientEmail: consultation.patientEmail,
        doctorId: consultation.doctorId,
        doctorName: consultation.doctorName,
        complaint: consultation.complaint,
        consultationType: consultation.consultationType,
        priority: consultation.priority,
        status: consultation.status,
        diagnosis: consultation.diagnosis,
        prescription: consultation.prescription,
        recommendation: consultation.recommendation,
        referredToIGD: consultation.referredToIGD,
        igdPatientId: consultation.igdPatientId,
        triageLevel: consultation.triageLevel,
        startTime: consultation.startTime,
        endTime: consultation.endTime,
        duration: consultation.duration,
        createdAt: consultation.createdAt,
        updatedAt: consultation.updatedAt,
      ),
    );
  }

  @override
  Future<int> deleteConsultation(int id) async {
    return await dataSource.deleteConsultation(id);
  }

  @override
  Future<int> insertMessage(ConsultationMessage message) async {
    return await dataSource.insertMessage(
      ConsultationMessageModel(
        id: message.id,
        consultationId: message.consultationId,
        senderId: message.senderId,
        senderType: message.senderType,
        message: message.message,
        messageType: message.messageType,
        fileUrl: message.fileUrl,
        timestamp: message.timestamp,
      ),
    );
  }

  @override
  Future<List<ConsultationMessage>> getMessagesByConsultationId(int consultationId) async {
    final models = await dataSource.getMessagesByConsultationId(consultationId);
    return models;
  }

  @override
  Future<int> deleteMessage(int id) async {
    return await dataSource.deleteMessage(id);
  }
}

