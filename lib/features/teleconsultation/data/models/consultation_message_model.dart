import '../../domain/entities/consultation_message.dart';
import '../../../../core/constants/consultation_enums.dart';
import '../../../../core/utils/date_time_utils.dart';

class ConsultationMessageModel extends ConsultationMessage {
  ConsultationMessageModel({
    super.id,
    required super.consultationId,
    required super.senderId,
    required super.senderType,
    required super.message,
    super.messageType,
    super.fileUrl,
    required super.timestamp,
  });

  factory ConsultationMessageModel.fromMap(Map<String, dynamic> map) {
    return ConsultationMessageModel(
      id: map['id'] as int?,
      consultationId: map['consultation_id'] as int,
      senderId: map['sender_id'] as int,
      senderType: SenderType.fromString(map['sender_type'] as String),
      message: map['message'] as String,
      messageType: MessageType.fromString(map['message_type'] as String? ?? 'text'),
      fileUrl: map['file_url'] as String?,
      timestamp: DateTimeUtils.parseFromDatabase(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultation_id': consultationId,
      'sender_id': senderId,
      'sender_type': senderType.name,
      'message': message,
      'message_type': messageType.name,
      'file_url': fileUrl,
      'timestamp': DateTimeUtils.formatDateForDatabase(timestamp),
    };
  }
}

