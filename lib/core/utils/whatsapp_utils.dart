import 'package:url_launcher/url_launcher.dart';

class WhatsAppUtils {
  static const String whatsappNumber = '+6288260367323';

  /// Format pesan konsultasi untuk WhatsApp
  static String formatConsultationMessage({
    required String nama,
    String? phone,
    String? email,
    required String keluhan,
    required String jenisKonsultasi,
    required String prioritas,
    String? informasiTambahan,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('🩺 *FORMULIR KONSULTASI MEDIS*');
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('👤 *DATA PASIEN*');
    buffer.writeln('Nama Lengkap: $nama');
    if (phone != null && phone.isNotEmpty) {
      buffer.writeln('Nomor Telepon: $phone');
    }
    if (email != null && email.isNotEmpty) {
      buffer.writeln('Email: $email');
    }
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('📋 *INFORMASI KONSULTASI*');
    buffer.writeln('Jenis Konsultasi: $jenisKonsultasi');
    buffer.writeln('Prioritas: $prioritas');
    buffer.writeln('');
    buffer.writeln('💬 *KELUHAN UTAMA*');
    buffer.writeln(keluhan);
    buffer.writeln('');
    if (informasiTambahan != null && informasiTambahan.isNotEmpty) {
      buffer.writeln('📝 *INFORMASI TAMBAHAN*');
      buffer.writeln(informasiTambahan);
      buffer.writeln('');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('_Pesan ini dikirim otomatis dari aplikasi E-IGD_');
    
    return buffer.toString();
  }

  /// Buka WhatsApp dengan nomor dan pesan
  static Future<void> openWhatsApp({
    String? message,
  }) async {
    try {
      String url;
      
      // Hapus tanda + dan spasi dari nomor
      final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[+\s]'), '');
      
      if (message != null && message.isNotEmpty) {
        final encodedMessage = Uri.encodeComponent(message);
        url = 'https://wa.me/$cleanNumber?text=$encodedMessage';
      } else {
        url = 'https://wa.me/$cleanNumber';
      }

      final uri = Uri.parse(url);
      
      // Coba buka dengan external application
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: coba dengan platform default
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      // Jika masih error, coba format alternatif
      try {
        final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[+\s]'), '');
        final uri = Uri.parse('whatsapp://send?phone=$cleanNumber${message != null ? '&text=${Uri.encodeComponent(message)}' : ''}');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e2) {
        throw 'Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstall di perangkat Anda.';
      }
    }
  }

  /// Buka WhatsApp dengan pesan konsultasi yang sudah diformat
  static Future<void> openWhatsAppWithConsultation({
    required String nama,
    String? phone,
    String? email,
    required String keluhan,
    required String jenisKonsultasi,
    required String prioritas,
    String? informasiTambahan,
  }) async {
    final message = formatConsultationMessage(
      nama: nama,
      phone: phone,
      email: email,
      keluhan: keluhan,
      jenisKonsultasi: jenisKonsultasi,
      prioritas: prioritas,
      informasiTambahan: informasiTambahan,
    );
    
    await openWhatsApp(message: message);
  }
}

