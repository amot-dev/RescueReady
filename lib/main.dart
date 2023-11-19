import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const String serverUrl = "http://207.23.216.156:5000/data";

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.withOpacity(0.5),
              Colors.lightBlue.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  // Wrap the ClipOval in a Container
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        width: 2), // Black border
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 150,
                    ),
                  ),
                ),
              ),
              _buildButton(
                context,
                'RESCUE ME',
                Icons.warning,
                Colors.red,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RescueMePage()),
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
                    MaterialPageRoute(
                        builder: (context) => ReadyToRescuePage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                'LOCAL EMERGENCIES',
                Icons.add_alert,
                Colors.orange,
                    () async {
                  const url = 'https://governmentofbc.maps.arcgis.com/apps/webappviewer/index.html?id=950b4eec577a4dc5b298a61adab41c06';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                'EMERGENCY GUIDES',
                Icons.account_balance_wallet,
                Colors.blue,
                    () async {
                  const url = 'https://www2.gov.bc.ca/gov/content/safety/emergency-management/preparedbc/guides-and-resources';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ],
          ),
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
      Uri.parse(serverUrl),
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
        title: const Text(
          'Rescue Ready',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            const Color.fromARGB(255, 145, 145, 145), // Set the background color to light grey
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
    var response = await http.get(Uri.parse(serverUrl));

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
            snippet: '',
            onTap: () {
              _showRescueRequestDialog(item);
            },
          ),
        );
        _markers.add(marker);

        _mostRecentUserLocation =
            LatLng(double.parse(coords[0]), double.parse(coords[1]));
      }
    });
  }

//   Future<List<LatLng>> fetchDirections(LatLng origin, LatLng destination) async {
//   final apiKey = 'AIzaSyCj6g1VncqL7QfbxOiaTLoWDC9u1SU1HF4'; // Replace with your actual API key
//   final apiUrl = 'https://maps.googleapis.com/maps/api/directions/json';

//   final response = await http.get(
//     Uri.parse(
//       '$apiUrl?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey',
//     ),
//   );

//   if (response.statusCode == 200) {
//     final decodedResponse = json.decode(response.body);
//     List<LatLng> points = [];

//     if (decodedResponse['status'] == 'OK') {
//       final List<dynamic> steps = decodedResponse['routes'][0]['legs'][0]['steps'];

//       for (var step in steps) {
//         final List<dynamic> polyline = step['polyline']['points'];
//         points.addAll(_decodePolyline(polyline));
//       }
//     }

//     return points;
//   } else {
//     throw Exception('Failed to load directions');
//   }
// }

// List<LatLng> _decodePolyline(String encoded) {
//   List<LatLng> points = [];
//   int index = 0;
//   int len = encoded.length;
//   int lat = 0, lng = 0;

//   while (index < len) {
//     int b, shift = 0, result = 0;

//     do {
//       b = encoded.codeUnitAt(index++) - 63;
//       result |= (b & 0x1F) << shift;
//       shift += 5;
//     } while (b >= 0x20);

//     int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lat += dlat;

//     shift = 0;
//     result = 0;

//     do {
//       b = encoded.codeUnitAt(index++) - 63;
//       result |= (b & 0x1F) << shift;
//       shift += 5;
//     } while (b >= 0x20);

//     int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lng += dlng;

//     points.add(LatLng(lat / 1E5, lng / 1E5));
//   }

//   return points;
// }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_mostRecentUserLocation != null) {
      mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_mostRecentUserLocation!, 12.0));
    }
  }

  void _showRescueRequestDialog(Map<String, dynamic> item) {
    bool isRescued = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Rescue Request'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildInfoText('Name', item['name']),
                  _buildInfoText('Age', item['age'].toString()),
                  _buildInfoText('Severity Status', item['severity_status'].toString()),
                  _buildInfoText('Situation', item['situation']),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Start Rescue'),
                  onPressed: () {
                    // TODO: Logic for initiating the rescue
                    setState(() {
                      isRescued = true;
                    });

                    // TODO: Route the user to the marker
                    _routeToMarker(item);
                  },
                ),
                TextButton(
                  child: Text('Complete Rescue'),
                  onPressed: () async {
                    // Remove the marker from the map
                    _removeMarker(item);

                    // Delete the data from the server
                    // TODO: Figure out why item['coordinates'] is null
                    var url = Uri.parse(serverUrl + item['coordinates']);
                    var response = await http.delete(url);
                    if (response.statusCode == 200) {
                      print('Data deleted successfully');
                    } else {
                      print('Failed to delete data');
                    }
                  },
                ),

                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _routeToMarker(Map<String, dynamic> item) {
    // Check if 'coordinates' property is present and is a string
    if (item.containsKey('coordinates') && item['coordinates'] is String) {
      String coordinates = item['coordinates'];
      List<String> coords = coordinates.split(',');

      if (coords.length == 2) {
        // Convert string coordinates to double values
        double lat = double.tryParse(coords[0]) ?? 0.0;
        double lng = double.tryParse(coords[1]) ?? 0.0;

        // Use the GoogleMapController to animate the camera to the marker position
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(lat, lng),
              15.0,
            ),
          );
        }
      }
    }
  }

  void _removeMarker(Map<String, dynamic> item) {
    // # TODO: Proper logic to remove the marker from the map
    setState(() {
      _markers.removeWhere(
        (marker) => marker.markerId.value == item['coordinates'],
      );
    });
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
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
