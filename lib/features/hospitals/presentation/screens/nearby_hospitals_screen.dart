import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asha_setu/core/utils/constants.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  // Mock data for hospitals assuming current location is a central rural node
  final LatLng _currentLocation = const LatLng(12.9716, 77.5946); // Bangalore Mock
  
  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'Primary Health Center (PHC) Alpha',
      'distance': '3.2 km',
      'latLng': const LatLng(12.9816, 77.6046),
      'type': 'PHC'
    },
    {
      'name': 'Community Health Center Beta',
      'distance': '8.5 km',
      'latLng': const LatLng(12.9516, 77.5746),
      'type': 'CHC'
    },
    {
      'name': 'District Hospital Gamma',
      'distance': '24.1 km',
      'latLng': const LatLng(13.0716, 77.6946),
      'type': 'District Hospital'
    },
  ];

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers = _hospitals.map((h) {
      return Marker(
        markerId: MarkerId(h['name']),
        position: h['latLng'],
        infoWindow: InfoWindow(title: h['name'], snippet: h['distance']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();
    
    // Add current location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('current'),
        position: _currentLocation,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      )
    );
  }

  Future<void> _launchNavigation(double lat, double lng) async {
    final Uri url = Uri.parse('google.navigation:q=$lat,$lng');
    final Uri webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: AppColors.alert,
      ),
      body: Column(
        children: [
          // Top Half: Map
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 11,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          
          // Bottom Half: List
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = _hospitals[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.alert.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_hospital, color: AppColors.alert, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hospital['name'],
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
                                      child: Text(hospital['type'], style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      hospital['distance'],
                                      style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.directions, color: Colors.blue, size: 40),
                            onPressed: () {
                              _launchNavigation(hospital['latLng'].latitude, hospital['latLng'].longitude);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
