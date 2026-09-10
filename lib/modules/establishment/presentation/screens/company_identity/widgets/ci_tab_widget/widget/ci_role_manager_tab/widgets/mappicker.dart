import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapScreen extends StatefulWidget {
//   final LatLng initialLocation;
//   final Function(LatLng) onLocationPicked;
//
//   MapScreen({
//     required this.initialLocation,
//     required this.onLocationPicked,
//   });
//
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController _mapController;
//   LatLng? _selectedLocation;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedLocation = widget.initialLocation;
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//   }
//
//   void _onTap(LatLng location) {
//     setState(() {
//       _selectedLocation = location;
//     });
//     _mapController.animateCamera(CameraUpdate.newLatLng(location));
//   }
//
//   void _confirmLocation() {
//     if (_selectedLocation != null) {
//       widget.onLocationPicked(_selectedLocation!);
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a location')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pick a Location'),
//         actions: [
//           TextButton(
//             onPressed: _confirmLocation,
//             child: Text('Confirm'),
//             style: TextButton.styleFrom(
//               backgroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: widget.initialLocation,
//           zoom: 15,
//         ),
//         onTap: _onTap,
//         markers: _selectedLocation != null
//             ? {
//           Marker(
//             markerId: MarkerId('selected_location'),
//             position: _selectedLocation!,
//           ),
//         }
//             : {},
//       ),
//     );
//   }
// }




///////////2

// In MapScreen.dart
class MapScreen extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationPicked;

  MapScreen({
    required this.initialLocation,
    required this.onLocationPicked,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _mapController.animateCamera(CameraUpdate.newLatLng(location));
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationPicked(_selectedLocation!);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: Text('Confirm'),
            style: TextButton.styleFrom(
             backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 15,
        ),
        onTap: _onTap,
        markers: _selectedLocation != null
            ? {
          Marker(
            markerId: MarkerId('selected_location'),
            position: _selectedLocation!,
          ),
        }
            : {},
      ),
    );
  }
}
