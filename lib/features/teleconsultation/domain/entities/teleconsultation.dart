import '../../../../core/constants/consultation_enums.dart';
import '../../../../core/constants/triage_levels.dart';

class Teleconsultation {
  final int? id;
  final int? patientId; // Foreign key ke Patient, nullable jika pasien baru
  final String patientName;
  final String? patientPhone;
  final String? patientEmail;
  final int? doctorId; // Foreign key ke User/Dokter
  final String? doctorName;
  final String complaint; // Keluhan utama
  final ConsultationType consultationType;
  final ConsultationPriority priority;
  final ConsultationStatus status;
  final String? diagnosis;
  final String? prescription; // JSON atau text
  final String? recommendation;
  final bool referredToIGD;
  final int? igdPatientId; // ID pasien di IGD jika dirujuk
  final TriageLevel? triageLevel; // Triage jika dirujuk
  final DateTime startTime;
  final DateTime? endTime;
  final int? duration; // dalam detik
  final DateTime createdAt;
  final DateTime updatedAt;

  Teleconsultation({
    this.id,
    this.patientId,
    required this.patientName,
    this.patientPhone,
    this.patientEmail,
    this.doctorId,
    this.doctorName,
    required this.complaint,
    required this.consultationType,
    required this.priority,
    this.status = ConsultationStatus.menunggu,
    this.diagnosis,
    this.prescription,
    this.recommendation,
    this.referredToIGD = false,
    this.igdPatientId,
    this.triageLevel,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  Teleconsultation copyWith({
    int? id,
    int? patientId,
    String? patientName,
    String? patientPhone,
    String? patientEmail,
    int? doctorId,
    String? doctorName,
    String? complaint,
    ConsultationType? consultationType,
    ConsultationPriority? priority,
    ConsultationStatus? status,
    String? diagnosis,
    String? prescription,
    String? recommendation,
    bool? referredToIGD,
    int? igdPatientId,
    TriageLevel? triageLevel,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Teleconsultation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientEmail: patientEmail ?? this.patientEmail,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      complaint: complaint ?? this.complaint,
      consultationType: consultationType ?? this.consultationType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      recommendation: recommendation ?? this.recommendation,
      referredToIGD: referredToIGD ?? this.referredToIGD,
      igdPatientId: igdPatientId ?? this.igdPatientId,
      triageLevel: triageLevel ?? this.triageLevel,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == ConsultationStatus.berlangsung;
  bool get isWaiting => status == ConsultationStatus.menunggu;
  bool get isCompleted => status == ConsultationStatus.selesai;
  bool get isUrgent => priority == ConsultationPriority.urgent;
}

