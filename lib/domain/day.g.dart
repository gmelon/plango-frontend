// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayAdapter extends TypeAdapter<Day> {
  @override
  final int typeId = 2;

  @override
  Day read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Day(
      fields[0] as DateTime,
    )
      ..scheduleList = (fields[1] as List).cast<Schedule>()
      ..diaryList = (fields[2] as List).cast<Diary>()
      ..lastUsedId = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, Day obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.scheduleList)
      ..writeByte(2)
      ..write(obj.diaryList)
      ..writeByte(3)
      ..write(obj.lastUsedId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
