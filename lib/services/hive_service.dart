import 'package:hive_flutter/hive_flutter.dart';
import '../models/blacklist_entry.dart';

class HiveService {
  static const String _blacklistBoxName = 'blacklist';
  static const String _seedKey = 'seeded_v2';

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
    // Normalised serials (no spaces or slashes) — two real confirmed fakes first.
    final serials = [
      'AA9334338',   // real fake ₦500
      'Y64235913',   // real fake ₦1000
      'AB12345678', 'CD87654321', 'EF11223344', 'GH99887766', 'IJ55443322',
      'KL77889900', 'MN11223300', 'OP44556677', 'QR88997700', 'ST22334455',
      'UV66778899', 'WX33445566', 'YZ11009988', 'AC55667788', 'BD99001122',
      'CE44332211', 'DF88776655', 'EG22110099', 'FH66554433', 'GI00998877',
    ];
    final denominations = [500, 1000,
      200, 500, 1000, 200, 500,
      1000, 200, 500, 1000, 200,
      500, 1000, 200, 500, 1000,
      200, 500, 1000, 200, 500,
    ];

    return List.generate(serials.length, (i) {
      return BlacklistEntry()
        ..serialNumber = serials[i]
        ..denomination = denominations[i]
        ..isActive = true;
    });
  }
}
