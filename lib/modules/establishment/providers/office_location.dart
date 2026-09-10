import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';

class LocationProvider extends ChangeNotifier {
  LatLng _selectedLocation = const LatLng(37.7749, -122.4194);
  double? _latitude;
  double? _longitude;

  LatLng? get selectedLocation => _selectedLocation;
  double? get latitude => _latitude;
  double? get longitude => _longitude;


  List<ServiceList> _selectedServices = [];
  String? _checkboxError;

  List<ServiceList> get selectedServices => _selectedServices;
  String? get checkboxError => _checkboxError;

  bool isSelected(String serviceId) {
    return _selectedServices.any((service) => service.serviceId == serviceId);
  }

  void toggleService(String serviceId) {
    if (isSelected(serviceId)) {
      _selectedServices.removeWhere((service) => service.serviceId == serviceId);
    } else {
      _selectedServices.add(ServiceList(serviceId: serviceId, npiNumber: '', medicareProviderId: '', hcoNumId: ''));
    }

    _checkboxError = _selectedServices.isEmpty ? "Please select at least one service" : null;
    notifyListeners();
  }

  void updateLocation(LatLng location) {
    _selectedLocation = location;
    _latitude = location.latitude;
    _longitude = location.longitude;
    notifyListeners();
  }
  void clearAllData(){
    _latitude = null;
    _longitude = null;
    _selectedServices.clear();
    notifyListeners();
  }
  String get formattedLatLong {
    if (_latitude != null && _longitude != null) {
      return 'Lat: ${_latitude!.toStringAsFixed(4)}, Long: ${_longitude!.toStringAsFixed(4)}';
    } else {
      return 'Lat/Long not selected';
    }
  }
}
