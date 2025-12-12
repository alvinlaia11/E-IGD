import '../../domain/entities/teleconsultation.dart';
import '../../../../core/constants/consultation_enums.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/utils/date_time_utils.dart';

class TeleconsultationModel extends Teleconsultation {
  TeleconsultationModel({
    super.id,
    super.patientId,
    required super.patientName,
    super.patientPhone,
    super.patientEmail,
    super.doctorId,
    super.doctorName,
    required super.complaint,
    required super.consultationType,
    required super.priority,
    super.status,
    super.diagnosis,
    super.prescription,
    super.recommendation,
    super.referredToIGD,
    super.igdPatientId,
    super.triageLevel,
    required super.startTime,
    super.endTime,
    super.duration,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TeleconsultationModel.fromMap(Map<String, dynamic> map) {
    return TeleconsultationModel(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int?,
      patientName: map['patient_name'] as String,
      patientPhone: map['patient_phone'] as String?,
      patientEmail: map['patient_email'] as String?,
      doctorId: map['doctor_id'] as int?,
      doctorName: map['doctor_name'] as String?,
      complaint: map['complaint'] as String,
      consultationType: ConsultationType.fromString(map['consultation_type'] as String),
      priority: ConsultationPriority.fromString(map['priority'] as String),
      status: ConsultationStatus.fromString(map['status'] as String),
      diagnosis: map['diagnosis'] as String?,
      prescription: map['prescription'] as String?,
      recommendation: map['recommendation'] as String?,
      referredToIGD: (map['referred_to_igd'] as int? ?? 0) == 1,
      igdPatientId: map['igd_patient_id'] as int?,
      triageLevel: map['triage_level'] != null 
          ? TriageLevel.fromString(map['triage_level'] as String)
          : null,
      startTime: DateTimeUtils.parseFromDatabase(map['start_time'] as String),
      endTime: map['end_time'] != null 
          ? DateTimeUtils.parseFromDatabase(map['end_time'] as String)
          : null,
      duration: map['duration'] as int?,
      createdAt: DateTimeUtils.parseFromDatabase(map['created_at'] as String),
      updatedAt: DateTimeUtils.parseFromDatabase(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'patient_email': patientEmail,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'complaint': complaint,
      'consultation_type': consultationType.name,
      'priority': priority.name,
      'status': status.name,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'recommendation': recommendation,
      'referred_to_igd': referredToIGD ? 1 : 0,
      'igd_patient_id': igdPatientId,
      'triage_level': triageLevel?.name,
      'start_time': DateTimeUtils.formatDateForDatabase(startTime),
      'end_time': endTime != null ? DateTimeUtils.formatDateForDatabase(endTime!) : null,
      'duration': duration,
      'created_at': DateTimeUtils.formatDateForDatabase(createdAt),
      'updated_at': DateTimeUtils.formatDateForDatabase(updatedAt),
    };
  }
}

