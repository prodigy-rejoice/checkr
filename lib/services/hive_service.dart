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
      'AB12345678', 'CD87654321', 'EF11223344', 'GH99887766', 'IJ55443322',
      'KL77889900', 'MN11223300', 'OP44556677', 'QR88997700', 'ST22334455',
      'UV66778899', 'WX33445566', 'YZ11009988', 'AC55667788', 'BD99001122',
      'CE44332211', 'DF88776655', 'EG22110099', 'FH66554433', 'GI00998877',
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
