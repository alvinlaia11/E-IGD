import 'package:flutter/foundation.dart';
import '../../domain/entities/patient.dart';
import '../../domain/usecases/get_all_patients.dart';
import '../../domain/usecases/insert_patient.dart';
import '../../domain/usecases/update_patient.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/constants/app_strings.dart';

class PatientListNotifier extends ChangeNotifier {
  final GetAllPatients getAllPatients;
  final InsertPatient insertPatient;
  final UpdatePatient updatePatient;

  PatientListNotifier({
    required this.getAllPatients,
    required this.insertPatient,
    required this.updatePatient,
  });

  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TriageLevel? _selectedTriage;
  bool _filterAmbulansOnly = false;
  String? _errorMessage;

  List<Patient> get patients => _filteredPatients;
  List<Patient> get allPatients => _patients;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TriageLevel? get selectedTriage => _selectedTriage;
  bool get filterAmbulansOnly => _filterAmbulansOnly;
  String? get errorMessage => _errorMessage;

  int get merahCount => _patients.where((p) => p.kategoriTriage == TriageLevel.merah).length;
  int get kuningCount => _patients.where((p) => p.kategoriTriage == TriageLevel.kuning).length;
  int get hijauCount => _patients.where((p) => p.kategoriTriage == TriageLevel.hijau).length;

  bool get hasEmergencyWaiting => _patients.any(
        (p) => p.kategoriTriage == TriageLevel.merah &&
            p.statusPenanganan == StatusPenanganan.menunggu,
      );

  // Ambulans statistics
  int get ambulansCallCount => _patients.where((p) => p.isAmbulansCall).length;
  int get ambulansWaitingCount => _patients.where((p) => 
    p.isAmbulansCall && 
    (p.statusAmbulans == AppStrings.menungguAmbulans || p.statusAmbulans == null)
  ).length;
  
  bool get hasAmbulansWaiting => ambulansWaitingCount > 0;

  // Status statistics
  int get ditanganiCount => _patients.where((p) => 
    p.statusPenanganan == StatusPenanganan.ditangani
  ).length;

  Future<void> loadPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patients = await getAllPatients();
      _sortAndFilterPatients();
    } catch (e) {
      _errorMessage = 'Gagal memuat data pasien';
      _patients = [];
      _filteredPatients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPatient(Patient patient) async {
    _errorMessage = null;
    try {
      await insertPatient(patient);
      await loadPatients();
    } catch (e) {
      _errorMessage = 'Gagal menambahkan pasien: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePatientStatus(Patient patient) async {
    _errorMessage = null;
    try {
      await updatePatient(patient);
      await loadPatients();
    } catch (e) {
      _errorMessage = 'Gagal memperbarui data pasien: $e';
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      _filterAmbulansOnly = false; // Reset ambulans filter when searching
    }
    _sortAndFilterPatients();
    notifyListeners();
  }

  void setSelectedTriage(TriageLevel? triage) {
    _selectedTriage = triage;
    if (triage != null) {
      _filterAmbulansOnly = false; // Reset ambulans filter when filtering by triage
    }
    _sortAndFilterPatients();
    notifyListeners();
  }

  void setFilterAmbulansOnly(bool filter) {
    _filterAmbulansOnly = filter;
    _sortAndFilterPatients();
    notifyListeners();
  }

  void _sortAndFilterPatients() {
    _filteredPatients = List.from(_patients);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      _filteredPatients = _filteredPatients.where((p) {
        return p.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by triage
    if (_selectedTriage != null) {
      _filteredPatients = _filteredPatients.where((p) {
        return p.kategoriTriage == _selectedTriage;
      }).toList();
    }

    // Filter by ambulans only
    if (_filterAmbulansOnly) {
      _filteredPatients = _filteredPatients.where((p) {
        return p.isAmbulansCall;
      }).toList();
    }

    // Sort by priority: MERAH, KUNING, HIJAU
    _filteredPatients.sort((a, b) {
      final priorityA = _getPriority(a.kategoriTriage);
      final priorityB = _getPriority(b.kategoriTriage);
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return b.waktuKedatangan.compareTo(a.waktuKedatangan);
    });
  }

  int _getPriority(TriageLevel triage) {
    switch (triage) {
      case TriageLevel.merah:
        return 1;
      case TriageLevel.kuning:
        return 2;
      case TriageLevel.hijau:
        return 3;
      default:
        return 3; // Default to lowest priority
    }
  }
}

