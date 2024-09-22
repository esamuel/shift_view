import '../models/shift.dart';
import '../models/settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<List<Shift>> getShifts() async {
    // Implement database logic to fetch shifts
    return [];
  }

  Future<Settings?> getSettings() async {
    // Implement database logic to fetch settings
    return null;
  }

  Future<void> insertSettings(Settings settings) async {
    // Implement database logic to insert settings
  }

  Future<void> insertShift(Shift shift) async {
    // Implement database logic to insert shift
  }

  Future<void> updateShift(Shift shift) async {
    // Implement database logic to update shift
  }

  Future<void> deleteShift(String id) async {
    // Implement database logic to delete shift
  }

  Future<void> updateSettings(Settings settings) async {
    // Implement database logic to update settings
  }
}