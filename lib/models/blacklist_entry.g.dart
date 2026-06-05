// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blacklist_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlacklistEntryAdapter extends TypeAdapter<BlacklistEntry> {
  @override
  final int typeId = 0;

  @override
  BlacklistEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlacklistEntry()
      ..serialNumber = fields[0] as String
      ..denomination = fields[1] as int
      ..isActive = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, BlacklistEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.serialNumber)
      ..writeByte(1)
      ..write(obj.denomination)
      ..writeByte(2)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlacklistEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
