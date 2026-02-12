// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 1;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      isDarkMode: fields[0] as bool,
      language: fields[1] as String,
      notificationsEnabled: fields[2] as bool,
      soundEnabled: fields[3] as bool,
      userName: fields[4] as String,
      reminderFrequency: fields[5] as int,
      biometricEnabled: fields[6] as bool,
      lastAssessmentDate: fields[7] as DateTime?,
      themeMode: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.soundEnabled)
      ..writeByte(4)
      ..write(obj.userName)
      ..writeByte(5)
      ..write(obj.reminderFrequency)
      ..writeByte(6)
      ..write(obj.biometricEnabled)
      ..writeByte(7)
      ..write(obj.lastAssessmentDate)
      ..writeByte(8)
      ..write(obj.themeMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
