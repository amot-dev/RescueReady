import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'global_data.dart'; // Ensure you have this file in your project

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
                  MaterialPageRoute(
                      builder: (context) => const ReadyToRescuePage()),
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

    setState(() {
      GlobalData.rescueRequests.add(
        RescueRequest(
          name: nameController.text,
          age: ageController.text,
          detail: detailController.text,
          dangerLevel: selectedDangerLevel ?? 'Not selected',
          location: LatLng(position.latitude, position.longitude),
        ),
      );
      print(GlobalData.rescueRequests); // For debugging purposes
    });

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
  const ReadyToRescuePage({Key? key}) : super(key: key);

  @override
  _ReadyToRescuePageState createState() => _ReadyToRescuePageState();
}

class _ReadyToRescuePageState extends State<ReadyToRescuePage> {
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    updateMarkers();
  }

  void updateMarkers() {
    setState(() {
      markers = GlobalData.rescueRequests.map((request) {
        return Marker(
          markerId: MarkerId(request.name),
          position: request.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              request.dangerLevel == 'Grave Danger'
                  ? BitmapDescriptor.hueRed
                  : request.dangerLevel == 'Immediate Danger'
                      ? BitmapDescriptor.hueOrange
                      : BitmapDescriptor.hueYellow),
          onTap: () => showRequestDetails(context, request),
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready to Rescue'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(51.5, -0.09), // Default position
          zoom: 12.0,
        ),
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddRequestForm(context),
        child: const Icon(Icons.add_location),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.startFloat, // Button to bottom left
    );
  }

  void showRequestDetails(BuildContext context, RescueRequest request) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Rescue Request Details'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Name: ${request.name}'),
                  Text('Age: ${request.age}'),
                  Text('Details: ${request.detail}'),
                  Text('Danger Level: ${request.dangerLevel}'),
                  Text(
                      'Location: Lat ${request.location.latitude}, Long ${request.location.longitude}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void openAddRequestForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Rescue Request'),
          content: AddRequestForm(onFormSubmit: updateMarkers),
        );
      },
    );
  }
}

class AddRequestForm extends StatefulWidget {
  final VoidCallback onFormSubmit;

  const AddRequestForm({Key? key, required this.onFormSubmit})
      : super(key: key);

  @override
  _AddRequestFormState createState() => _AddRequestFormState();
}

class _AddRequestFormState extends State<AddRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _detailsController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  String _dangerLevel = 'Mild Danger';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter age';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _detailsController,
            decoration: const InputDecoration(labelText: 'Details'),
            maxLines: 3,
          ),
          TextFormField(
            controller: _latitudeController,
            decoration: const InputDecoration(labelText: 'Latitude'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter latitude';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _longitudeController,
            decoration: const InputDecoration(labelText: 'Longitude'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter longitude';
              }
              return null;
            },
          ),
          DropdownButtonFormField(
            value: _dangerLevel,
            decoration: const InputDecoration(labelText: 'Danger Level'),
            items: <String>['Grave Danger', 'Immediate Danger', 'Mild Danger']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _dangerLevel = newValue!;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  GlobalData.rescueRequests.add(
                    RescueRequest(
                      name: _nameController.text,
                      age: _ageController.text,
                      detail: _detailsController.text,
                      dangerLevel: _dangerLevel,
                      location: LatLng(
                          double.tryParse(_latitudeController.text) ?? 0.0,
                          double.tryParse(_longitudeController.text) ?? 0.0),
                    ),
                  );
                  widget.onFormSubmit(); // Update markers
                  Navigator.of(context).pop(); // Close the form
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
