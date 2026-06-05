import 'package:hive/hive.dart';

part 'blacklist_entry.g.dart';

@HiveType(typeId: 0)
class BlacklistEntry extends HiveObject {
  @HiveField(0)
  late String serialNumber;

  @HiveField(1)
  late int denomination;

  @HiveField(2)
  late bool isActive;
}
