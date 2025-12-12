enum ConsultationType {
  umum,
  spesialis,
  gawatDarurat;

  String get displayName {
    switch (this) {
      case ConsultationType.umum:
        return 'Konsultasi Umum';
      case ConsultationType.spesialis:
        return 'Konsultasi Spesialis';
      case ConsultationType.gawatDarurat:
        return 'Konsultasi Gawat Darurat';
    }
  }

  static ConsultationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'umum':
        return ConsultationType.umum;
      case 'spesialis':
        return ConsultationType.spesialis;
      case 'gawatdarurat':
      case 'gawat_darurat':
        return ConsultationType.gawatDarurat;
      default:
        return ConsultationType.umum;
    }
  }
}

enum ConsultationPriority {
  normal,
  urgent;

  String get displayName {
    switch (this) {
      case ConsultationPriority.normal:
        return 'Normal';
      case ConsultationPriority.urgent:
        return 'Urgent';
    }
  }

  static ConsultationPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'urgent':
        return ConsultationPriority.urgent;
      case 'normal':
      default:
        return ConsultationPriority.normal;
    }
  }
}

enum ConsultationStatus {
  menunggu,
  berlangsung,
  selesai,
  dibatalkan;

  String get displayName {
    switch (this) {
      case ConsultationStatus.menunggu:
        return 'MENUNGGU';
      case ConsultationStatus.berlangsung:
        return 'BERLANGSUNG';
      case ConsultationStatus.selesai:
        return 'SELESAI';
      case ConsultationStatus.dibatalkan:
        return 'DIBATALKAN';
    }
  }

  static ConsultationStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MENUNGGU':
        return ConsultationStatus.menunggu;
      case 'BERLANGSUNG':
        return ConsultationStatus.berlangsung;
      case 'SELESAI':
        return ConsultationStatus.selesai;
      case 'DIBATALKAN':
        return ConsultationStatus.dibatalkan;
      default:
        return ConsultationStatus.menunggu;
    }
  }
}

enum MessageType {
  text,
  image,
  video,
  file,
  system;

  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Video';
      case MessageType.file:
        return 'File';
      case MessageType.system:
        return 'System';
    }
  }

  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

enum SenderType {
  patient,
  doctor;

  String get displayName {
    switch (this) {
      case SenderType.patient:
        return 'Pasien';
      case SenderType.doctor:
        return 'Dokter';
    }
  }

  static SenderType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'doctor':
      case 'dokter':
        return SenderType.doctor;
      case 'patient':
      case 'pasien':
      default:
        return SenderType.patient;
    }
  }
}

