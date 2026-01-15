// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_category_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionCategoryDtoAdapter
    extends TypeAdapter<TransactionCategoryDto> {
  @override
  final int typeId = 4;

  @override
  TransactionCategoryDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionCategoryDto(
      id: fields[0] as int,
      userId: fields[1] as int?,
      title: fields[2] as String,
      icon: fields[3] as String,
      color: fields[4] as String,
      type: fields[5] as TransactionCategoryType,
      isSystem: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionCategoryDto obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.isSystem)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionCategoryTypeAdapter
    extends TypeAdapter<TransactionCategoryType> {
  @override
  final int typeId = 3;

  @override
  TransactionCategoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionCategoryType.income;
      case 1:
        return TransactionCategoryType.expense;
      default:
        return TransactionCategoryType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionCategoryType obj) {
    switch (obj) {
      case TransactionCategoryType.income:
        writer.writeByte(0);
        break;
      case TransactionCategoryType.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
