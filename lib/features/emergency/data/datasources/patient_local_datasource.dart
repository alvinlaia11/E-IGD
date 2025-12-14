import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient_model.dart';
import '../../../../core/utils/date_time_utils.dart';

class PatientLocalDataSource {
  static final PatientLocalDataSource instance = PatientLocalDataSource._init();
  static Database? _database;

  PatientLocalDataSource._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('emergency.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Update to version 3 to include consultations table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textNullableType = 'TEXT';
    const integerNullableType = 'INTEGER';

    // Create patients table
    await db.execute('''
      CREATE TABLE patients (
        id $idType,
        nama $textType,
        usia $integerType,
        jenis_kelamin $textType,
        keluhan_utama $textType,
        kategori_triage $textType,
        status_penanganan $textType,
        petugas $textNullableType,
        waktu_kedatangan $textType,
        created_at $textType,
        updated_at $textType,
        latitude REAL,
        longitude REAL,
        alamat_lengkap $textNullableType,
        nomor_telepon $textNullableType,
        status_ambulans $textNullableType
      )
    ''');

    // Create consultations table for teleconsultation feature
    await db.execute('''
      CREATE TABLE consultations (
        id $idType,
        patient_id $integerNullableType,
        patient_name $textType,
        patient_phone $textNullableType,
        patient_email $textNullableType,
        doctor_id $integerNullableType,
        doctor_name $textNullableType,
        complaint $textType,
        consultation_type $textType,
        priority $textType,
        status $textType,
        diagnosis $textNullableType,
        prescription $textNullableType,
        recommendation $textNullableType,
        referred_to_igd $integerType DEFAULT 0,
        igd_patient_id $integerNullableType,
        triage_level $textNullableType,
        start_time $textType,
        end_time $textNullableType,
        duration $integerNullableType,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // Create consultation_messages table
    await db.execute('''
      CREATE TABLE consultation_messages (
        id $idType,
        consultation_id $integerType,
        sender_id $integerType,
        sender_type $textType,
        message $textType,
        message_type $textType DEFAULT 'text',
        file_url $textNullableType,
        timestamp $textType
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for ambulans
      await db.execute('ALTER TABLE patients ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE patients ADD COLUMN longitude REAL');
      await db.execute('ALTER TABLE patients ADD COLUMN alamat_lengkap TEXT');
      await db.execute('ALTER TABLE patients ADD COLUMN nomor_telepon TEXT');
      await db.execute('ALTER TABLE patients ADD COLUMN status_ambulans TEXT');
    }
    if (oldVersion < 3) {
      // Add consultations table for teleconsultation feature
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const integerType = 'INTEGER NOT NULL';
      const textNullableType = 'TEXT';
      const integerNullableType = 'INTEGER';

      await db.execute('''
        CREATE TABLE IF NOT EXISTS consultations (
          id $idType,
          patient_id $integerNullableType,
          patient_name $textType,
          patient_phone $textNullableType,
          patient_email $textNullableType,
          doctor_id $integerNullableType,
          doctor_name $textNullableType,
          complaint $textType,
          consultation_type $textType,
          priority $textType,
          status $textType,
          diagnosis $textNullableType,
          prescription $textNullableType,
          recommendation $textNullableType,
          referred_to_igd $integerType DEFAULT 0,
          igd_patient_id $integerNullableType,
          triage_level $textNullableType,
          start_time $textType,
          end_time $textNullableType,
          duration $integerNullableType,
          created_at $textType,
          updated_at $textType
        )
      ''');

      // Add consultation_messages table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS consultation_messages (
          id $idType,
          consultation_id $integerType,
          sender_id $integerType,
          sender_type $textType,
          message $textType,
          message_type $textType DEFAULT 'text',
          file_url $textNullableType,
          timestamp $textType
        )
      ''');
    }
  }

  Future<int> insertPatient(PatientModel patient) async {
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  Future<List<PatientModel>> getAllPatients() async {
    final db = await database;
    final result = await db.query(
      'patients',
      orderBy: 'waktu_kedatangan DESC',
    );
    return result.map((map) => PatientModel.fromMap(map)).toList();
  }

  Future<List<PatientModel>> getPatientsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final startStr = DateTimeUtils.formatDateForDatabase(startOfDay);
    final endStr = DateTimeUtils.formatDateForDatabase(endOfDay);
    final result = await db.query(
      'patients',
      where: "waktu_kedatangan >= ? AND waktu_kedatangan <= ?",
      whereArgs: [startStr, endStr],
      orderBy: 'waktu_kedatangan DESC',
    );
    return result.map((map) => PatientModel.fromMap(map)).toList();
  }

  Future<PatientModel?> getPatientById(int id) async {
    final db = await database;
    final result = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return PatientModel.fromMap(result.first);
  }

  Future<int> updatePatient(PatientModel patient) async {
    final db = await database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

