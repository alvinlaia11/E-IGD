import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_list_notifier.dart';

class PatientFormPage extends StatefulWidget {
  final Patient? patient;

  const PatientFormPage({super.key, this.patient});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _keluhanController = TextEditingController();
  final _petugasController = TextEditingController();

  TriageLevel? _selectedTriage;
  JenisKelamin _selectedGender = JenisKelamin.lakiLaki;
  StatusPenanganan _selectedStatus = StatusPenanganan.menunggu;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      final p = widget.patient!;
      // Prevent editing if status is SELESAI
      if (p.statusPenanganan == StatusPenanganan.selesai) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data pasien dengan status SELESAI tidak dapat diubah'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
          }
        });
        return;
      }
      _namaController.text = p.nama;
      _usiaController.text = p.usia.toString();
      _keluhanController.text = p.keluhanUtama;
      _petugasController.text = p.petugas ?? '';
      _selectedTriage = p.kategoriTriage;
      _selectedGender = p.jenisKelamin;
      _selectedStatus = p.statusPenanganan;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _keluhanController.dispose();
    _petugasController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    // Prevent saving if original patient status is SELESAI
    if (widget.patient != null && 
        widget.patient!.statusPenanganan == StatusPenanganan.selesai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pasien dengan status SELESAI tidak dapat diubah'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedTriage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.triageWajib)),
      );
      return;
    }

    final now = DateTime.now();
    final patient = Patient(
      id: widget.patient?.id,
      nama: _namaController.text.trim(),
      usia: int.parse(_usiaController.text.trim()),
      jenisKelamin: _selectedGender,
      keluhanUtama: _keluhanController.text.trim(),
      kategoriTriage: _selectedTriage!,
      statusPenanganan: _selectedStatus,
      petugas: _petugasController.text.trim().isEmpty
          ? null
          : _petugasController.text.trim(),
      waktuKedatangan: widget.patient?.waktuKedatangan ?? now,
      createdAt: widget.patient?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final notifier = context.read<PatientListNotifier>();
      if (widget.patient == null) {
        await notifier.addPatient(patient);
      } else {
        await notifier.updatePatientStatus(patient);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pasien berhasil disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patient == null
              ? AppStrings.tambahPasien
              : AppStrings.editPasien,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: AppStrings.namaPasien,
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.namaWajib;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usiaController,
                decoration: const InputDecoration(
                  labelText: AppStrings.usia,
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.usiaWajib;
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return AppStrings.usiaInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<JenisKelamin>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: AppStrings.jenisKelamin,
                  prefixIcon: Icon(Icons.wc),
                ),
                items: JenisKelamin.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender.fullName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keluhanController,
                decoration: const InputDecoration(
                  labelText: AppStrings.keluhanUtama,
                  prefixIcon: Icon(Icons.medical_services),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TriageLevel>(
                value: _selectedTriage,
                decoration: const InputDecoration(
                  labelText: AppStrings.kategoriTriage,
                  prefixIcon: Icon(Icons.flag),
                ),
                items: TriageLevel.values.map((triage) {
                  return DropdownMenuItem(
                    value: triage,
                    child: Text(triage.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTriage = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return AppStrings.triageWajib;
                  }
                  return null;
                },
              ),
              if (widget.patient != null) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<StatusPenanganan>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: AppStrings.statusPenanganan,
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: StatusPenanganan.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _petugasController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.petugas,
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                text: AppStrings.simpan,
                onPressed: _savePatient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

