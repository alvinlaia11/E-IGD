import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/teleconsultation_model.dart';
import '../models/consultation_message_model.dart';

class TeleconsultationLocalDataSource {
  static final TeleconsultationLocalDataSource instance = TeleconsultationLocalDataSource._init();
  static Database? _database;

  TeleconsultationLocalDataSource._init();

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
      version: 3, // Update version untuk menambah tabel konsultasi
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

    // Create consultations table
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
    if (oldVersion < 3) {
      // Add consultations table
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

  // Consultation CRUD
  Future<int> insertConsultation(TeleconsultationModel consultation) async {
    final db = await database;
    return await db.insert('consultations', consultation.toMap());
  }

  Future<List<TeleconsultationModel>> getAllConsultations() async {
    final db = await database;
    final result = await db.query(
      'consultations',
      orderBy: 'start_time DESC',
    );
    return result.map((map) => TeleconsultationModel.fromMap(map)).toList();
  }

  Future<List<TeleconsultationModel>> getConsultationsByStatus(String status) async {
    final db = await database;
    final result = await db.query(
      'consultations',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'start_time DESC',
    );
    return result.map((map) => TeleconsultationModel.fromMap(map)).toList();
  }

  Future<TeleconsultationModel?> getConsultationById(int id) async {
    final db = await database;
    final result = await db.query(
      'consultations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return TeleconsultationModel.fromMap(result.first);
  }

  Future<int> updateConsultation(TeleconsultationModel consultation) async {
    final db = await database;
    return await db.update(
      'consultations',
      consultation.toMap(),
      where: 'id = ?',
      whereArgs: [consultation.id],
    );
  }

  Future<int> deleteConsultation(int id) async {
    final db = await database;
    // Delete messages first
    await db.delete(
      'consultation_messages',
      where: 'consultation_id = ?',
      whereArgs: [id],
    );
    // Then delete consultation
    return await db.delete(
      'consultations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Message CRUD
  Future<int> insertMessage(ConsultationMessageModel message) async {
    final db = await database;
    return await db.insert('consultation_messages', message.toMap());
  }

  Future<List<ConsultationMessageModel>> getMessagesByConsultationId(int consultationId) async {
    final db = await database;
    final result = await db.query(
      'consultation_messages',
      where: 'consultation_id = ?',
      whereArgs: [consultationId],
      orderBy: 'timestamp ASC',
    );
    return result.map((map) => ConsultationMessageModel.fromMap(map)).toList();
  }

  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete(
      'consultation_messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

