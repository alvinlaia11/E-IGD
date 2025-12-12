import 'package:flutter/foundation.dart';
import '../../domain/entities/teleconsultation.dart';
import '../../domain/usecases/create_consultation.dart';
import '../../domain/usecases/get_all_consultations.dart';
import '../../domain/usecases/get_consultation_by_id.dart';
import '../../domain/usecases/update_consultation.dart';
import '../../../../core/constants/consultation_enums.dart';

class ConsultationNotifier extends ChangeNotifier {
  final CreateConsultation createConsultation;
  final GetAllConsultations getAllConsultations;
  final GetConsultationById getConsultationById;
  final UpdateConsultation updateConsultation;

  ConsultationNotifier({
    required this.createConsultation,
    required this.getAllConsultations,
    required this.getConsultationById,
    required this.updateConsultation,
  });

  List<Teleconsultation> _consultations = [];
  Teleconsultation? _selectedConsultation;
  bool _isLoading = false;
  String? _errorMessage;
  ConsultationStatus? _filterStatus;

  List<Teleconsultation> get consultations => _consultations;
  Teleconsultation? get selectedConsultation => _selectedConsultation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ConsultationStatus? get filterStatus => _filterStatus;

  // Statistics
  int get totalCount => _consultations.length;
  int get waitingCount => _consultations.where((c) => c.isWaiting).length;
  int get activeCount => _consultations.where((c) => c.isActive).length;
  int get completedCount => _consultations.where((c) => c.isCompleted).length;
  int get urgentCount => _consultations.where((c) => c.isUrgent).length;

  List<Teleconsultation> get filteredConsultations {
    if (_filterStatus == null) return _consultations;
    return _consultations.where((c) => c.status == _filterStatus).toList();
  }

  List<Teleconsultation> get waitingConsultations {
    return _consultations
        .where((c) => c.status == ConsultationStatus.menunggu)
        .toList()
      ..sort((a, b) {
        // Urgent first
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return a.startTime.compareTo(b.startTime);
      });
  }

  Future<void> loadConsultations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _consultations = await getAllConsultations();
      _sortConsultations();
    } catch (e) {
      _errorMessage = 'Gagal memuat data konsultasi';
      _consultations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createNewConsultation(Teleconsultation consultation) async {
    _errorMessage = null;
    try {
      await createConsultation(consultation);
      await loadConsultations();
    } catch (e) {
      _errorMessage = 'Gagal membuat konsultasi: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadConsultationById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedConsultation = await getConsultationById(id);
    } catch (e) {
      _errorMessage = 'Gagal memuat detail konsultasi';
      _selectedConsultation = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateConsultationStatus(Teleconsultation consultation) async {
    _errorMessage = null;
    try {
      await updateConsultation(consultation);
      await loadConsultations();
      if (_selectedConsultation?.id == consultation.id) {
        await loadConsultationById(consultation.id!);
      }
    } catch (e) {
      _errorMessage = 'Gagal memperbarui konsultasi: $e';
      notifyListeners();
      rethrow;
    }
  }

  void setFilterStatus(ConsultationStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void _sortConsultations() {
    _consultations.sort((a, b) {
      // Urgent first
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      // Then by start time (newest first)
      return b.startTime.compareTo(a.startTime);
    });
  }
}

