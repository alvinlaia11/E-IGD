import '../../features/emergency/domain/entities/patient.dart';
import 'date_time_utils.dart';

class ExportUtils {
  /// Export data pasien ke format CSV
  static String exportToCSV(List<Patient> patients, {
    DateTime? selectedDate,
    Map<String, int>? statistics,
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('LAPORAN PASIEN E-IGD');
    if (selectedDate != null) {
      buffer.writeln('Tanggal: ${DateTimeUtils.formatDate(selectedDate)}');
    }
    buffer.writeln('Generated: ${DateTimeUtils.formatDateTime(DateTime.now())}');
    buffer.writeln('');
    
    // Statistics jika ada
    if (statistics != null) {
      buffer.writeln('STATISTIK');
      buffer.writeln('Total Pasien,${statistics['total'] ?? 0}');
      buffer.writeln('MERAH,${statistics['merah'] ?? 0}');
      buffer.writeln('KUNING,${statistics['kuning'] ?? 0}');
      buffer.writeln('HIJAU,${statistics['hijau'] ?? 0}');
      buffer.writeln('MENUNGGU,${statistics['menunggu'] ?? 0}');
      buffer.writeln('DITANGANI,${statistics['ditangani'] ?? 0}');
      buffer.writeln('SELESAI,${statistics['selesai'] ?? 0}');
      if (statistics['ambulans'] != null && (statistics['ambulans'] as int) > 0) {
        buffer.writeln('Pemanggilan Ambulans,${statistics['ambulans'] ?? 0}');
        buffer.writeln('Ambulans Menunggu,${statistics['ambulans_waiting'] ?? 0}');
        buffer.writeln('Ambulans Dalam Perjalanan,${statistics['ambulans_in_progress'] ?? 0}');
        buffer.writeln('Ambulans Sampai,${statistics['ambulans_arrived'] ?? 0}');
      }
      buffer.writeln('');
    }
    
    // CSV Header
    buffer.writeln('ID,Nama,Usia,Jenis Kelamin,Keluhan Utama,Kategori Triage,Status Penanganan,Petugas,Waktu Kedatangan,Ambulans,Lokasi,Telepon,Status Ambulans');
    
    // Data
    for (var patient in patients) {
      buffer.writeln([
        patient.id ?? '',
        _escapeCSV(patient.nama),
        patient.usia,
        patient.jenisKelamin.fullName,
        _escapeCSV(patient.keluhanUtama),
        patient.kategoriTriage.displayName,
        patient.statusPenanganan.displayName,
        _escapeCSV(patient.petugas ?? '-'),
        DateTimeUtils.formatDateTime(patient.waktuKedatangan),
        patient.isAmbulansCall ? 'Ya' : 'Tidak',
        _escapeCSV(patient.alamatLengkap ?? '-'),
        _escapeCSV(patient.nomorTelepon ?? '-'),
        _escapeCSV(patient.statusAmbulans ?? '-'),
      ].join(','));
    }
    
    return buffer.toString();
  }
  
  /// Export data pasien ke format Text (readable)
  static String exportToText(List<Patient> patients, {
    DateTime? selectedDate,
    Map<String, int>? statistics,
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('=' * 60);
    buffer.writeln('LAPORAN PASIEN E-IGD');
    buffer.writeln('=' * 60);
    if (selectedDate != null) {
      buffer.writeln('Tanggal: ${DateTimeUtils.formatDate(selectedDate)}');
    }
    buffer.writeln('Generated: ${DateTimeUtils.formatDateTime(DateTime.now())}');
    buffer.writeln('');
    
    // Statistics jika ada
    if (statistics != null) {
      buffer.writeln('STATISTIK');
      buffer.writeln('-' * 60);
      buffer.writeln('Total Pasien          : ${statistics['total'] ?? 0}');
      buffer.writeln('MERAH                 : ${statistics['merah'] ?? 0}');
      buffer.writeln('KUNING                : ${statistics['kuning'] ?? 0}');
      buffer.writeln('HIJAU                 : ${statistics['hijau'] ?? 0}');
      buffer.writeln('MENUNGGU              : ${statistics['menunggu'] ?? 0}');
      buffer.writeln('DITANGANI             : ${statistics['ditangani'] ?? 0}');
      buffer.writeln('SELESAI               : ${statistics['selesai'] ?? 0}');
      if (statistics['ambulans'] != null && (statistics['ambulans'] as int) > 0) {
        buffer.writeln('');
        buffer.writeln('STATISTIK AMBULANS');
        buffer.writeln('-' * 60);
        buffer.writeln('Total Pemanggilan     : ${statistics['ambulans'] ?? 0}');
        buffer.writeln('Menunggu              : ${statistics['ambulans_waiting'] ?? 0}');
        buffer.writeln('Dalam Perjalanan      : ${statistics['ambulans_in_progress'] ?? 0}');
        buffer.writeln('Sampai                : ${statistics['ambulans_arrived'] ?? 0}');
      }
      buffer.writeln('');
    }
    
    // Data Pasien
    buffer.writeln('DATA PASIEN');
    buffer.writeln('=' * 60);
    
    if (patients.isEmpty) {
      buffer.writeln('Tidak ada data pasien');
    } else {
      for (var i = 0; i < patients.length; i++) {
        final patient = patients[i];
        buffer.writeln('');
        buffer.writeln('Pasien #${i + 1}');
        buffer.writeln('-' * 60);
        buffer.writeln('ID                    : ${patient.id ?? '-'}');
        buffer.writeln('Nama                  : ${patient.nama}');
        buffer.writeln('Usia                  : ${patient.usia} tahun');
        buffer.writeln('Jenis Kelamin         : ${patient.jenisKelamin.fullName}');
        buffer.writeln('Keluhan Utama         : ${patient.keluhanUtama}');
        buffer.writeln('Kategori Triage       : ${patient.kategoriTriage.displayName}');
        buffer.writeln('Status Penanganan     : ${patient.statusPenanganan.displayName}');
        buffer.writeln('Petugas               : ${patient.petugas ?? '-'}');
        buffer.writeln('Waktu Kedatangan      : ${DateTimeUtils.formatDateTime(patient.waktuKedatangan)}');
        if (patient.isAmbulansCall) {
          buffer.writeln('Pemanggilan Ambulans  : Ya');
          buffer.writeln('Lokasi Pickup         : ${patient.alamatLengkap ?? '-'}');
          buffer.writeln('Nomor Telepon         : ${patient.nomorTelepon ?? '-'}');
          buffer.writeln('Status Ambulans       : ${patient.statusAmbulans ?? '-'}');
          if (patient.latitude != null && patient.longitude != null) {
            buffer.writeln('Koordinat            : ${patient.latitude}, ${patient.longitude}');
          }
        }
      }
    }
    
    buffer.writeln('');
    buffer.writeln('=' * 60);
    buffer.writeln('End of Report');
    
    return buffer.toString();
  }
  
  /// Escape CSV value (handle commas and quotes)
  static String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

