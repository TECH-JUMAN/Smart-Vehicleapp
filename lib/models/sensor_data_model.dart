import 'package:cloud_firestore/cloud_firestore.dart';

class SensorDataModel {
  final String id;
  final String vehicleId;
  final double? batteryVoltage; // Battery voltage
  final double? vibrationLevel; // Vibration level
  final double? coLevelPPM; // New: MQ-7 Carbon Monoxide level (ppm)
  final double?
  airQualityLevelPPM; // New: MQ-135 Air Quality level (ppm or equivalent)
  final String status; // OK, WARNING, CRITICAL
  final DateTime timestamp;
  final double? latitude; // GPS latitude
  final double? longitude; // GPS longitude

  SensorDataModel({
    required this.id,
    required this.vehicleId,
    this.batteryVoltage,
    this.vibrationLevel,
    this.coLevelPPM, // Added
    this.airQualityLevelPPM, // Added
    this.status = 'OK',
    required this.timestamp,
    this.latitude,
    this.longitude,
  });

  /// Convert model to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'batteryVoltage': batteryVoltage,
      'vibrationLevel': vibrationLevel,
      'coLevelPPM': coLevelPPM, // Added
      'airQualityLevelPPM': airQualityLevelPPM, // Added
      'status': status,
      'timestamp': Timestamp.fromDate(
        timestamp,
      ), // Store as Firestore Timestamp
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create model from Firestore Map
  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    DateTime timestampValue;

    // Handle different timestamp formats safely
    if (map['timestamp'] is Timestamp) {
      timestampValue = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      timestampValue = DateTime.parse(map['timestamp']);
    } else {
      timestampValue = DateTime.now(); // Fallback
    }

    return SensorDataModel(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      batteryVoltage: (map['batteryVoltage'] as num?)?.toDouble(),
      vibrationLevel: (map['vibrationLevel'] as num?)?.toDouble(),
      coLevelPPM: (map['coLevelPPM'] as num?)?.toDouble(), // Added
      airQualityLevelPPM: (map['airQualityLevelPPM'] as num?)
          ?.toDouble(), // Added
      status: map['status'] ?? 'OK',
      timestamp: timestampValue,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  /// status logic (battery, vibration, and gas sensors)
  String calculateStatus() {
    // --- Battery Checks ---
    if (batteryVoltage != null && batteryVoltage! < 6.5) {
      return 'CRITICAL'; // ~72% of 9V
    }
    if (batteryVoltage != null && batteryVoltage! < 7.5) {
      return 'WARNING'; // ~83% of 9V
    }

    // --- Vibration Check ---
    if (vibrationLevel != null && vibrationLevel! > 80) {
      return 'WARNING';
    }

    // --- Gas Sensor Checks (Example Thresholds) ---
    // Note: You must determine appropriate thresholds based on sensor calibration and safety standards.

    // Check for critical CO level (e.g., above 100 ppm)
    if (coLevelPPM != null && coLevelPPM! > 100) {
      return 'CRITICAL';
    }
    // Check for high CO level (e.g., above 50 ppm)
    if (coLevelPPM != null && coLevelPPM! > 50) {
      return 'WARNING';
    }

    // Check for poor air quality (e.g., high MQ-135 reading)
    // Thresholds depend heavily on what the sensor is calibrated for and what the "PPM equivalent" represents.
    if (airQualityLevelPPM != null && airQualityLevelPPM! > 200) {
      return 'WARNING';
    }

    return 'OK';
  }
}
