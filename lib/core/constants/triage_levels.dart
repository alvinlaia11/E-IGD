enum TriageLevel {
  merah,
  kuning,
  hijau;

  String get displayName {
    switch (this) {
      case TriageLevel.merah:
        return 'MERAH';
      case TriageLevel.kuning:
        return 'KUNING';
      case TriageLevel.hijau:
        return 'HIJAU';
    }
  }

  static TriageLevel fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MERAH':
        return TriageLevel.merah;
      case 'KUNING':
        return TriageLevel.kuning;
      case 'HIJAU':
        return TriageLevel.hijau;
      default:
        return TriageLevel.hijau;
    }
  }
}

enum StatusPenanganan {
  menunggu,
  ditangani,
  selesai;

  String get displayName {
    switch (this) {
      case StatusPenanganan.menunggu:
        return 'MENUNGGU';
      case StatusPenanganan.ditangani:
        return 'DITANGANI';
      case StatusPenanganan.selesai:
        return 'SELESAI';
    }
  }

  static StatusPenanganan fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MENUNGGU':
        return StatusPenanganan.menunggu;
      case 'DITANGANI':
        return StatusPenanganan.ditangani;
      case 'SELESAI':
        return StatusPenanganan.selesai;
      default:
        return StatusPenanganan.menunggu;
    }
  }
}

enum JenisKelamin {
  lakiLaki,
  perempuan;

  String get displayName {
    switch (this) {
      case JenisKelamin.lakiLaki:
        return 'L';
      case JenisKelamin.perempuan:
        return 'P';
    }
  }

  String get fullName {
    switch (this) {
      case JenisKelamin.lakiLaki:
        return 'Laki-laki';
      case JenisKelamin.perempuan:
        return 'Perempuan';
    }
  }

  static JenisKelamin fromString(String value) {
    switch (value.toUpperCase()) {
      case 'L':
        return JenisKelamin.lakiLaki;
      case 'P':
        return JenisKelamin.perempuan;
      default:
        return JenisKelamin.lakiLaki;
    }
  }
}

