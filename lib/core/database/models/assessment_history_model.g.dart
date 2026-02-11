// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssessmentHistoryAdapter extends TypeAdapter<AssessmentHistory> {
  @override
  final int typeId = 0;

  @override
  AssessmentHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssessmentHistory(
      id: fields[0] as String,
      assessmentType: fields[1] as String,
      assessmentTitle: fields[2] as String,
      completionDate: fields[3] as DateTime,
      totalScore: fields[4] as int,
      categoryScores: (fields[5] as Map).cast<String, dynamic>(),
      overallSeverity: fields[6] as String,
      interpretation: fields[7] as String,
      recommendations: (fields[8] as List).cast<String>(),
      durationInSeconds: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AssessmentHistory obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.assessmentType)
      ..writeByte(2)
      ..write(obj.assessmentTitle)
      ..writeByte(3)
      ..write(obj.completionDate)
      ..writeByte(4)
      ..write(obj.totalScore)
      ..writeByte(5)
      ..write(obj.categoryScores)
      ..writeByte(6)
      ..write(obj.overallSeverity)
      ..writeByte(7)
      ..write(obj.interpretation)
      ..writeByte(8)
      ..write(obj.recommendations)
      ..writeByte(9)
      ..write(obj.durationInSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssessmentHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
