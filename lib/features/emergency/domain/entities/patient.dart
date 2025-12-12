import '../../../../core/constants/triage_levels.dart';

class Patient {
  final int? id;
  final String nama;
  final int usia;
  final JenisKelamin jenisKelamin;
  final String keluhanUtama;
  final TriageLevel kategoriTriage;
  final StatusPenanganan statusPenanganan;
  final String? petugas;
  final DateTime waktuKedatangan;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Ambulans fields
  final double? latitude;
  final double? longitude;
  final String? alamatLengkap;
  final String? nomorTelepon;
  final String? statusAmbulans;

  Patient({
    this.id,
    required this.nama,
    required this.usia,
    required this.jenisKelamin,
    required this.keluhanUtama,
    required this.kategoriTriage,
    this.statusPenanganan = StatusPenanganan.menunggu,
    this.petugas,
    required this.waktuKedatangan,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.alamatLengkap,
    this.nomorTelepon,
    this.statusAmbulans,
  });

  Patient copyWith({
    int? id,
    String? nama,
    int? usia,
    JenisKelamin? jenisKelamin,
    String? keluhanUtama,
    TriageLevel? kategoriTriage,
    StatusPenanganan? statusPenanganan,
    String? petugas,
    DateTime? waktuKedatangan,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    String? alamatLengkap,
    String? nomorTelepon,
    String? statusAmbulans,
  }) {
    return Patient(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      usia: usia ?? this.usia,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      keluhanUtama: keluhanUtama ?? this.keluhanUtama,
      kategoriTriage: kategoriTriage ?? this.kategoriTriage,
      statusPenanganan: statusPenanganan ?? this.statusPenanganan,
      petugas: petugas ?? this.petugas,
      waktuKedatangan: waktuKedatangan ?? this.waktuKedatangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      alamatLengkap: alamatLengkap ?? this.alamatLengkap,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      statusAmbulans: statusAmbulans ?? this.statusAmbulans,
    );
  }
  
  bool get isAmbulansCall => latitude != null && longitude != null;
}

