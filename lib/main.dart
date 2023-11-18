import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController severityController = TextEditingController();
  final TextEditingController situationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: severityController,
              decoration: const InputDecoration(labelText: 'Severity Status'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: situationController,
              decoration: const InputDecoration(labelText: 'Situation'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Get the user's location
                Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high);

                // Send the data to the server
                var response = await http.post(
                  Uri.parse('http://127.0.0.1:5000/data'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'coordinates': '${position.latitude},${position.longitude}',
                    'name': nameController.text,
                    'age': ageController.text,
                    'severity_status': severityController.text,
                    'situation': situationController.text,
                  }),
                );

                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapPage()),
          );
        },
        child: Icon(Icons.map),
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  LatLng? _mostRecentUserLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Fetch the data from the server
    var response = await http.get(Uri.parse('http://127.0.0.1:5000/data'));

    // Parse the response
    Map<String, dynamic> data = jsonDecode(response.body);

    // Add the markers to the map
    setState(() {
      for (var coordinates in data.keys) {
        var item = data[coordinates];
        var coords = coordinates.split(',');
        var marker = Marker(
          markerId: MarkerId(coordinates),
          position: LatLng(double.parse(coords[0]), double.parse(coords[1])),
          infoWindow: InfoWindow(
            title: item['name'],
            snippet:
                'Age: ${item['age']}, Severity Status: ${item['severity_status']}, Situation: ${item['situation']}',
          ),
        );
        _markers.add(marker);

        _mostRecentUserLocation =
            LatLng(double.parse(coords[0]), double.parse(coords[1]));
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Set the initial camera position to the most recent user location
    if (_mostRecentUserLocation != null) {
      mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_mostRecentUserLocation!, 13.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Page'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: _mostRecentUserLocation ?? LatLng(0, 0),
          zoom: 14.0,
        ),
      ),
    );
  }
}
