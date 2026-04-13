import 'package:glucpred/features/doctor/data/services/doctor_patient_service.dart';
import 'package:glucpred/features/records/data/services/records_service.dart';

class DoctorPatientRepository {
  Future<Map<String, dynamic>> getPatientsSummary() =>
      DoctorPatientService.getPatientsSummary();

  Future<Map<String, dynamic>> addPatient(int patientUserId) =>
      DoctorPatientService.assignPatient(patientUserId);

  Future<Map<String, dynamic>> removePatient(int patientUserId) =>
      DoctorPatientService.deactivatePatient(patientUserId);

  Future<Map<String, dynamic>> getPatientAlerts(
      {int? patientId, bool unreadOnly = false}) async =>
      {'success': false, 'message': 'No implementado', 'alerts': []};

  Future<Map<String, dynamic>> getPatientRecords(int patientId,
          {int limit = 20, int offset = 0}) =>
      RecordsService.getPatientHistory(patientId, limit: limit);

  Future<Map<String, dynamic>> getObservations(int patientId) =>
      DoctorPatientService.getObservations(patientId);

  Future<Map<String, dynamic>> addObservation(
          int patientId, String observation) =>
      DoctorPatientService.createObservation(patientId, observation);

  Future<Map<String, dynamic>> generateReport(int patientId) async =>
      {'success': false, 'message': 'No implementado'};
}
