# RescueReady
RescueReady is a Flutter application designed to assist in emergency situations. The app provides a platform for users to request help, offer assistance, and access information about local emergencies and emergency guides.

## Features
- Rescue Me: Users can send a distress signal when they are in need of help.
- Ready to Rescue: Users can indicate their availability to provide assistance in emergency situations.
- Local Emergencies: Users can view information about local emergencies.
- Emergency Guides: Users can access guides and instructions for dealing with various emergency situations.

## Installation
To run the app, you need to have Flutter installed on your machine. Once you have Flutter installed, you can clone the repository and run the app using the Flutter CLI.
```bash
git clone https://github.com/your-repo/rescue-ready.git
cd rescue-ready
flutter run
```

## Usage
The app has a simple user interface with four main options:

- Rescue Me: When you click this button, you will be navigated to the RescueMePage.
- Ready to Rescue: When you click this button, you will be navigated to the ReadyToRescuePage.
- Local Emergencies: When you click this button, the app will open a web page with information about local emergencies.
- Emergency Guides: When you click this button, the app will open a web page with various emergency guides.

## Dependencies
The app uses the following packages:

- http: Used for making HTTP requests.
- geolocator: Used for accessing the device’s location.
- google_maps_flutter: Used for displaying Google Maps.
- url_launcher: Used for launching URLs in the mobile platform.
