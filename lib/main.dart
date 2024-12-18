import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:gnotes/global/global.dart';
import 'package:gnotes/home/presentation/home_screen.dart';
import 'package:gnotes/splash/splash_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:workmanager/workmanager.dart';

bool biometricsAvailable = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkBioMetric();

  runApp(const MyApp());
  Workmanager().initialize(callbackDispatcher);

  Workmanager().registerPeriodicTask(
    'sync_notes_task',
    'sync_notes',
    frequency: const Duration(minutes: 15), // Sync every hour
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresDeviceIdle: false,

      requiresBatteryNotLow: true, // Avoid running on low battery
    ),
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    if (task == 'sync_notes') {
      syncNotesWithRemoteServer();
    }
    return Future.value(true);
  });
}

Future<void> syncNotesWithRemoteServer() async {
  //TODO: sync notes to some remote server
  if (Global.isEditingInProgress) {
    return;
  }

  final receivePort = ReceivePort();
  // Spawn a new isolate and pass the ReceivePort's SendPort to it
  Isolate.spawn(backgroundProcess, receivePort.sendPort);

  // Listen for messages from the isolate
  receivePort.listen((message) {
    log('Received message from isolate: $message');
    receivePort.close(); // Close the receive port when done
  });
}

// This function will run in the isolate
void backgroundProcess(SendPort sendPort) {
  // Perform task
  String result = 'syncing notes';

  // Send the result back to the main isolate using the SendPort
  sendPort.send(result);
}

checkBioMetric() async {
  final LocalAuthentication auth = LocalAuthentication();
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  log("can authenticate message : $canAuthenticate and $canAuthenticateWithBiometrics");

  if (canAuthenticate) {
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    log(availableBiometrics.toString());

    if (availableBiometrics.isNotEmpty) {
      biometricsAvailable = true;
    } else {
      biometricsAvailable = false;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: biometricsAvailable ? const SplashScreen() : const HomeScreen(),
    );
  }
}
