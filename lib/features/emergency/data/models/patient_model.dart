import '../../domain/entities/patient.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/utils/date_time_utils.dart';

class PatientModel extends Patient {
  PatientModel({
    super.id,
    required super.nama,
    required super.usia,
    required super.jenisKelamin,
    required super.keluhanUtama,
    required super.kategoriTriage,
    super.statusPenanganan,
    super.petugas,
    required super.waktuKedatangan,
    required super.createdAt,
    required super.updatedAt,
    super.latitude,
    super.longitude,
    super.alamatLengkap,
    super.nomorTelepon,
    super.statusAmbulans,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      usia: map['usia'] as int,
      jenisKelamin: JenisKelamin.fromString(map['jenis_kelamin'] as String),
      keluhanUtama: map['keluhan_utama'] as String,
      kategoriTriage: TriageLevel.fromString(map['kategori_triage'] as String),
      statusPenanganan: StatusPenanganan.fromString(
        map['status_penanganan'] as String,
      ),
      petugas: map['petugas'] as String?,
      waktuKedatangan: DateTimeUtils.parseFromDatabase(
        map['waktu_kedatangan'] as String,
      ),
      createdAt: DateTimeUtils.parseFromDatabase(
        map['created_at'] as String,
      ),
      updatedAt: DateTimeUtils.parseFromDatabase(
        map['updated_at'] as String,
      ),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      alamatLengkap: map['alamat_lengkap'] as String?,
      nomorTelepon: map['nomor_telepon'] as String?,
      statusAmbulans: map['status_ambulans'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'usia': usia,
      'jenis_kelamin': jenisKelamin.displayName,
      'keluhan_utama': keluhanUtama,
      'kategori_triage': kategoriTriage.displayName,
      'status_penanganan': statusPenanganan.displayName,
      'petugas': petugas,
      'waktu_kedatangan': DateTimeUtils.formatDateForDatabase(waktuKedatangan),
      'created_at': DateTimeUtils.formatDateForDatabase(createdAt),
      'updated_at': DateTimeUtils.formatDateForDatabase(updatedAt),
      'latitude': latitude,
      'longitude': longitude,
      'alamat_lengkap': alamatLengkap,
      'nomor_telepon': nomorTelepon,
      'status_ambulans': statusAmbulans,
    };
  }

  factory PatientModel.fromEntity(Patient patient) {
    return PatientModel(
      id: patient.id,
      nama: patient.nama,
      usia: patient.usia,
      jenisKelamin: patient.jenisKelamin,
      keluhanUtama: patient.keluhanUtama,
      kategoriTriage: patient.kategoriTriage,
      statusPenanganan: patient.statusPenanganan,
      petugas: patient.petugas,
      waktuKedatangan: patient.waktuKedatangan,
      createdAt: patient.createdAt,
      updatedAt: patient.updatedAt,
      latitude: patient.latitude,
      longitude: patient.longitude,
      alamatLengkap: patient.alamatLengkap,
      nomorTelepon: patient.nomorTelepon,
      statusAmbulans: patient.statusAmbulans,
    );
  }

  Patient toEntity() {
    return Patient(
      id: id,
      nama: nama,
      usia: usia,
      jenisKelamin: jenisKelamin,
      keluhanUtama: keluhanUtama,
      kategoriTriage: kategoriTriage,
      statusPenanganan: statusPenanganan,
      petugas: petugas,
      waktuKedatangan: waktuKedatangan,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

