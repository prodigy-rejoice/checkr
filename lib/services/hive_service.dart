import 'package:hive_flutter/hive_flutter.dart';
import '../models/blacklist_entry.dart';

class HiveService {
  static const String _blacklistBoxName = 'blacklist';
  static const String _seedKey = 'seeded_v1';

  late Box<BlacklistEntry> _blacklistBox;
  late Box<bool> _metaBox;

  Box<BlacklistEntry> get blacklistBox => _blacklistBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(BlacklistEntryAdapter());
    _blacklistBox = await Hive.openBox<BlacklistEntry>(_blacklistBoxName);
    _metaBox = await Hive.openBox<bool>('meta');
    await _seedIfFirstRun();
  }

  Future<void> _seedIfFirstRun() async {
    if (_metaBox.get(_seedKey) == true) return;

    final entries = _buildSeedEntries();
    for (final entry in entries) {
      await _blacklistBox.add(entry);
    }
    await _metaBox.put(_seedKey, true);
  }

  List<BlacklistEntry> _buildSeedEntries() {
    final serials = [
      'AB12345678', 'CD87654321', 'EF11223344', 'GH99887766',
      'IJ55443322', 'KL77889900', 'MN12398765', 'OP44556677',
      'QR98765432', 'ST23456789', 'UV34567890', 'WX45678901',
      'YZ56789012', 'AA67890123', 'BB78901234', 'CC89012345',
      'DD90123456', 'EE01234567', 'FF13579246', 'GG24681357',
    ];
    final denominations = [200, 500, 1000];

    return List.generate(serials.length, (i) {
      final entry = BlacklistEntry()
        ..serialNumber = serials[i]
        ..denomination = denominations[i % denominations.length]
        ..isActive = true;
      return entry;
    });
  }
}
