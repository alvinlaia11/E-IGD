import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/consultation_enums.dart';
import '../../domain/entities/consultation_message.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_messages.dart';
import '../../data/repositories/teleconsultation_repository_impl.dart';
import '../../data/datasources/teleconsultation_local_datasource.dart';
import '../providers/consultation_notifier.dart';
import 'package:intl/intl.dart';

class ConsultationChatPage extends StatefulWidget {
  final int consultationId;

  const ConsultationChatPage({super.key, required this.consultationId});

  @override
  State<ConsultationChatPage> createState() => _ConsultationChatPageState();
}

class _ConsultationChatPageState extends State<ConsultationChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final SendMessage _sendMessage = SendMessage(
    // Will be injected via provider
    TeleconsultationRepositoryImpl(TeleconsultationLocalDataSource.instance),
  );
  final GetMessages _getMessages = GetMessages(
    TeleconsultationRepositoryImpl(TeleconsultationLocalDataSource.instance),
  );

  List<ConsultationMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Load consultation details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationNotifier>().loadConsultationById(widget.consultationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      _messages = await _getMessages(widget.consultationId);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pesan: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessageHandler() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = ConsultationMessage(
      consultationId: widget.consultationId,
      senderId: 1, // TODO: Get from auth
      senderType: SenderType.patient,
      message: _messageController.text.trim(),
      messageType: MessageType.text,
      timestamp: DateTime.now(),
    );

    try {
      await _sendMessage(message);
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Consumer<ConsultationNotifier>(
          builder: (context, notifier, child) {
            final consultation = notifier.selectedConsultation;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  consultation?.doctorName ?? 'Menunggu dokter',
                  style: const TextStyle(fontSize: 16),
                ),
                if (consultation != null)
                  Text(
                    consultation.status.displayName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
              ],
            );
          },
        ),
        backgroundColor: AppColors.triageHijau,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text('Belum ada pesan'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ConsultationMessage message) {
    final isPatient = message.senderType == SenderType.patient;
    final timeFormat = DateFormat('HH:mm');

    return Align(
      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPatient ? AppColors.triageHijau : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isPatient ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(message.timestamp),
              style: TextStyle(
                color: isPatient ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessageHandler(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.triageHijau,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessageHandler,
            ),
          ),
        ],
      ),
    );
  }
}

