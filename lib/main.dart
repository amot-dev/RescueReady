import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const RescueReadyApp());
}

class RescueReadyApp extends StatelessWidget {
  const RescueReadyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rescue Ready',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rescue Ready',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Image.asset('assets/logo.png', width: 150),
            ),
            _buildButton(
              context,
              'RESCUE ME',
              Icons.warning,
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RescueMePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              'READY TO RESCUE',
              Icons.shield,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReadyToRescuePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 24),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class RescueMePage extends StatefulWidget {
  const RescueMePage({Key? key}) : super(key: key);

  @override
  State<RescueMePage> createState() => _RescueMePageState();
}

class _RescueMePageState extends State<RescueMePage> {
  String? selectedDangerLevel;
  final List<String> dangerLevels = [
    'Grave Danger',
    'Immediate Danger',
    'Mild Danger'
  ];
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final detailController = TextEditingController();

  void submitForm() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    // Set severity
    int severity = 0;
    if (selectedDangerLevel == 'Immediate Danger') {
      severity = 1;
    } else if (selectedDangerLevel == 'Grave Danger') {
      severity = 2;
    }

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
        'severity_status': severity.toString(),
        'situation': detailController.text,
      }),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Form Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Name: ${nameController.text}'),
                Text('Age: ${ageController.text}'),
                Text('Details: ${detailController.text}'),
                Text('Danger Level: ${selectedDangerLevel ?? 'Not selected'}'),
                Text(
                    'Location: Lat ${position.latitude}, Long ${position.longitude}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rescue Me'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                  ),
                ),
                const SizedBox(height: 16),
                ListView(
                  shrinkWrap: true,
                  children: dangerLevels.map((level) {
                    return RadioListTile<String>(
                      title: Text(level),
                      value: level,
                      groupValue: selectedDangerLevel,
                      onChanged: (value) {
                        setState(() {
                          selectedDangerLevel = value;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(
                    labelText: 'Details (up to 200 words)',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: submitForm,
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReadyToRescuePage extends StatefulWidget {
  @override
  _ReadyToRescuePageState createState() => _ReadyToRescuePageState();
}

class _ReadyToRescuePageState extends State<ReadyToRescuePage> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  LatLng?
      _mostRecentUserLocation; // Variable to store the most recent user location

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
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_mostRecentUserLocation != null) {
      mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_mostRecentUserLocation!, 15.0));
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
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: _mostRecentUserLocation ?? LatLng(0, 0),
          zoom: 12.0,
        ),
      ),
    );
  }
}
