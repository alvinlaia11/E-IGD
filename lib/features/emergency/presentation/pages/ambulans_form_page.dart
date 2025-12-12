import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_list_notifier.dart';

class AmbulansFormPage extends StatefulWidget {
  const AmbulansFormPage({super.key});

  @override
  State<AmbulansFormPage> createState() => _AmbulansFormPageState();
}

class _AmbulansFormPageState extends State<AmbulansFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _kondisiController = TextEditingController();
  final _nomorTeleponController = TextEditingController();
  final _catatanController = TextEditingController();
  final _alamatController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(-6.2088, 106.8456); // Default: Jakarta
  String _alamatLengkap = '';
  bool _isLoadingLocation = false;
  bool _isLoadingAddress = false;
  JenisKelamin _selectedGender = JenisKelamin.lakiLaki;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _kondisiController.dispose();
    _nomorTeleponController.dispose();
    _catatanController.dispose();
    _alamatController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Request permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.mengizinkanAksesLokasi),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.lokasiTidakTersedia),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // Get address from coordinates
      await _getAddressFromCoordinates(_selectedLocation);
      
      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation, 15.0),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mendapatkan lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        setState(() {
          _alamatLengkap = address;
          _alamatController.text = address;
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _alamatLengkap = '${location.latitude}, ${location.longitude}';
          _alamatController.text = _alamatLengkap;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _alamatLengkap = '${location.latitude}, ${location.longitude}';
        _alamatController.text = _alamatLengkap;
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedLocation = position.target;
    });
  }

  Future<void> _onCameraIdle() async {
    await _getAddressFromCoordinates(_selectedLocation);
  }

  Future<void> _saveAmbulansCall() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    String keluhanUtama = 'Panggilan Ambulans - ${_kondisiController.text.trim()}';
    if (_catatanController.text.trim().isNotEmpty) {
      keluhanUtama += ' - Catatan: ${_catatanController.text.trim()}';
    }

    final patient = Patient(
      nama: _namaController.text.trim(),
      usia: int.parse(_usiaController.text.trim()),
      jenisKelamin: _selectedGender,
      keluhanUtama: keluhanUtama,
      kategoriTriage: TriageLevel.merah, // Auto-set MERAH untuk ambulans
      statusPenanganan: StatusPenanganan.menunggu,
      waktuKedatangan: now,
      createdAt: now,
      updatedAt: now,
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      alamatLengkap: _alamatLengkap.isNotEmpty ? _alamatLengkap : _alamatController.text.trim(),
      nomorTelepon: _nomorTeleponController.text.trim(),
      statusAmbulans: AppStrings.menungguAmbulans,
    );

    try {
      final notifier = context.read<PatientListNotifier>();
      await notifier.addPatient(patient);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.ambulansBerhasilDipanggil),
            backgroundColor: AppColors.statusSelesai,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.layananAmbulans),
        backgroundColor: AppColors.triageMerah,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.triageMerah.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Emergency Alert Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.triageMerah,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.triageMerah.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PANGGILAN AMBULANS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Pilih lokasi pickup di peta',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Google Maps Widget
                Container(
                  height: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation,
                            zoom: 15.0,
                          ),
                          onCameraMove: _onCameraMove,
                          onCameraIdle: _onCameraIdle,
                          markers: {
                            Marker(
                              markerId: const MarkerId('pickup_location'),
                              position: _selectedLocation,
                              draggable: true,
                              onDragEnd: (LatLng newPosition) {
                                setState(() {
                                  _selectedLocation = newPosition;
                                });
                                _getAddressFromCoordinates(newPosition);
                              },
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed,
                              ),
                            ),
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          mapType: MapType.normal,
                        ),
                        // Current Location Button
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: AppColors.triageMerah,
                            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                            child: _isLoadingLocation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.my_location, color: Colors.white),
                          ),
                        ),
                        // Instruction Text
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.triageMerah,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppStrings.geserPinUntukPilihLokasi,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Alamat Display
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _isLoadingAddress
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Mengambil alamat...'),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.triageMerah, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _alamatLengkap.isNotEmpty
                                    ? _alamatLengkap
                                    : 'Pilih lokasi di peta',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _alamatLengkap.isNotEmpty
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 16),

                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nama Pasien
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.namaPasien,
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.namaWajib;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Usia
                      TextFormField(
                        controller: _usiaController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.usia,
                          prefixIcon: Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.usiaWajib;
                          }
                          if (int.tryParse(value) == null) {
                            return AppStrings.usiaInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Jenis Kelamin
                      DropdownButtonFormField<JenisKelamin>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: AppStrings.jenisKelamin,
                          prefixIcon: Icon(Icons.wc),
                          filled: true,
                          fillColor: Colors.white,
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

                      // Kondisi Pasien
                      TextFormField(
                        controller: _kondisiController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.kondisiPasien,
                          prefixIcon: Icon(Icons.medical_services),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Contoh: Pingsan, Luka berat, dll',
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kondisi pasien wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nomor Telepon
                      TextFormField(
                        controller: _nomorTeleponController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.nomorTeleponKontak,
                          prefixIcon: Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Contoh: 081234567890',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.nomorTeleponWajib;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Alamat Lengkap (read-only, dari map)
                      TextFormField(
                        controller: _alamatController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.alamatLengkap,
                          prefixIcon: Icon(Icons.location_on),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      // Catatan Tambahan
                      TextFormField(
                        controller: _catatanController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.catatanTambahan,
                          prefixIcon: Icon(Icons.note),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Catatan tambahan (opsional)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Info Auto-set
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.triageMerah.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.triageMerah.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.triageMerah,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Triage otomatis: MERAH | Status: MENUNGGU AMBULANS',
                                style: TextStyle(
                                  color: AppColors.triageMerah,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Panggil Ambulans
                      PrimaryButton(
                        text: AppStrings.panggilAmbulans,
                        onPressed: _saveAmbulansCall,
                        backgroundColor: AppColors.triageMerah,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

