import '../app/app.locator.dart';
import '../models/blacklist_entry.dart';
import '../services/hive_service.dart';

class BlacklistRepository {
  final _hiveService = locator<HiveService>();

  bool isBlacklisted(String serial) {
    final box = _hiveService.blacklistBox;
    for (final entry in box.values) {
      if (entry.serialNumber == serial && entry.isActive) {
        return true;
      }
    }
    return false;
  }

  Future<void> addToBlacklist(String serial, int denomination) async {
    final entry = BlacklistEntry()
      ..serialNumber = serial
      ..denomination = denomination
      ..isActive = true;
    await _hiveService.blacklistBox.add(entry);
  }

  List<BlacklistEntry> getAllEntries() {
    return _hiveService.blacklistBox.values.toList();
  }
}
