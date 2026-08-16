import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';
import '../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';
import 'dart:html' as html; // For browser back button

class MapScreen extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationPicked;

  MapScreen({required this.initialLocation, required this.onLocationPicked});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    html.window.onPopState.listen((event) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  ///old
  void _confirmSelection() {
    widget.onLocationPicked(_selectedLocation);
    print("Picked Location: $_selectedLocation");
    Navigator.of(context).pop(_selectedLocation);
  }
  ///updated
  // void _confirmSelection() {
  //   if (!mounted) return; // Ensure the widget is still active
  //
  //   if (_selectedLocation != null) {
  //     widget.onLocationPicked(_selectedLocation!);
  //     debugPrint("Picked Location: $_selectedLocation");
  //
  //     if (Navigator.canPop(context)) {
  //       Navigator.of(context).pop(_selectedLocation);
  //     }
  //   } else {
  //     debugPrint("No location selected");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: _onTap,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('selectedLocation'),
                  position: _selectedLocation,
                ),
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 30,
              children: [
                CustomElevatedButton(
                  width: AppSize.s120,
                  height: AppSize.s32,
                  text: "Cancel",
                  textColor: ColorManager.blueprime,
                  style: TextStyle(color:  ColorManager.blueprime),
                  color: ColorManager.white,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                CustomElevatedButton(
                width: AppSize.s120,
                height: AppSize.s32,
                  text: "Confirm",
                  color: ColorManager.blueprime,
                  onPressed: _confirmSelection,
                ),
              ],
            )
          ),
        ],
      ),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: ColorManager.blueprime,
  //       title: Text('Pick Location',style: TableHeading.customTextStyle(context)),
  //       actions: [
  //         IconButton(
  //           icon: Icon(Icons.check,color: ColorManager.white),
  //           onPressed: _confirmSelection,
  //         ),
  //       ],
  //     ),
  //     body: GoogleMap(
  //       onMapCreated: _onMapCreated,
  //       onTap: _onTap,
  //       initialCameraPosition: CameraPosition(
  //         target: _selectedLocation,
  //         zoom: 14.0,
  //       ),
  //       markers: {
  //         Marker(
  //           markerId: MarkerId('selectedLocation'),
  //           position: _selectedLocation,
  //         ),
  //       },
  //     ),
  //   );
  // }
}
