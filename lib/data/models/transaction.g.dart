// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TxnAdapter extends TypeAdapter<Txn> {
  @override
  final int typeId = 0;

  @override
  Txn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Txn(
      id: fields[0] as String,
      type: fields[1] as String,
      amount: fields[2] as double,
      categoryId: fields[3] as String,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Txn obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TxnAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
