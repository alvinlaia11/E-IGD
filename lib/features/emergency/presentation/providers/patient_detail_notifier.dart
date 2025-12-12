import 'package:flutter/foundation.dart';
import '../../domain/entities/patient.dart';
import '../../domain/usecases/get_patient_by_id.dart';
import '../../domain/usecases/update_patient.dart';
import '../../domain/usecases/insert_patient.dart';

class PatientDetailNotifier extends ChangeNotifier {
  final GetPatientById getPatientById;
  final UpdatePatient updatePatient;
  final InsertPatient insertPatient;

  PatientDetailNotifier({
    required this.getPatientById,
    required this.updatePatient,
    required this.insertPatient,
  });

  Patient? _patient;
  bool _isLoading = false;
  String? _errorMessage;

  Patient? get patient => _patient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPatient(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patient = await getPatientById(id);
      if (_patient == null) {
        _errorMessage = 'Pasien tidak ditemukan';
      }
    } catch (e) {
      _errorMessage = 'Error memuat data pasien: $e';
      _patient = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePatient(Patient patient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (patient.id == null) {
        await insertPatient(patient);
      } else {
        await updatePatient(patient);
        // Reload patient after update
        await loadPatient(patient.id!);
      }
    } catch (e) {
      _errorMessage = 'Error menyimpan data: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(Patient patient, String? petugas) async {
    final updatedPatient = patient.copyWith(
      petugas: petugas,
      updatedAt: DateTime.now(),
    );
    await savePatient(updatedPatient);
  }
}

