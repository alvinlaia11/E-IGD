import '../../../../core/constants/consultation_enums.dart';

class ConsultationMessage {
  final int? id;
  final int consultationId;
  final int senderId;
  final SenderType senderType;
  final String message;
  final MessageType messageType;
  final String? fileUrl;
  final DateTime timestamp;

  ConsultationMessage({
    this.id,
    required this.consultationId,
    required this.senderId,
    required this.senderType,
    required this.message,
    this.messageType = MessageType.text,
    this.fileUrl,
    required this.timestamp,
  });

  ConsultationMessage copyWith({
    int? id,
    int? consultationId,
    int? senderId,
    SenderType? senderType,
    String? message,
    MessageType? messageType,
    String? fileUrl,
    DateTime? timestamp,
  }) {
    return ConsultationMessage(
      id: id ?? this.id,
      consultationId: consultationId ?? this.consultationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

