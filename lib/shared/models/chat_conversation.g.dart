// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatConversationAdapter extends TypeAdapter<ChatConversation> {
  @override
  final int typeId = 10;

  @override
  ChatConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatConversation(
      id: fields[0] as String,
      title: fields[1] as String,
      messages: (fields[2] as List?)?.cast<ChatMessageHive>(),
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
      kundaliId: fields[5] as String?,
      isPinned: fields[6] as bool? ?? false,
      type: fields[7] as ConversationType? ?? ConversationType.general,
    );
  }

  @override
  void write(BinaryWriter writer, ChatConversation obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.kundaliId)
      ..writeByte(6)
      ..write(obj.isPinned)
      ..writeByte(7)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationTypeAdapter extends TypeAdapter<ConversationType> {
  @override
  final int typeId = 11;

  @override
  ConversationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConversationType.general;
      case 1:
        return ConversationType.kundaliAnalysis;
      case 2:
        return ConversationType.transitAnalysis;
      case 3:
        return ConversationType.compatibility;
      case 4:
        return ConversationType.prediction;
      case 5:
        return ConversationType.remedy;
      default:
        return ConversationType.general;
    }
  }

  @override
  void write(BinaryWriter writer, ConversationType obj) {
    switch (obj) {
      case ConversationType.general:
        writer.writeByte(0);
        break;
      case ConversationType.kundaliAnalysis:
        writer.writeByte(1);
        break;
      case ConversationType.transitAnalysis:
        writer.writeByte(2);
        break;
      case ConversationType.compatibility:
        writer.writeByte(3);
        break;
      case ConversationType.prediction:
        writer.writeByte(4);
        break;
      case ConversationType.remedy:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatMessageHiveAdapter extends TypeAdapter<ChatMessageHive> {
  @override
  final int typeId = 12;

  @override
  ChatMessageHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageHive(
      id: fields[0] as String,
      text: fields[1] as String,
      isUser: fields[2] as bool,
      timestamp: fields[3] as DateTime,
      attachmentUrl: fields[4] as String?,
      attachmentType: fields[5] as String?,
      status: fields[6] as MessageStatus? ?? MessageStatus.sent,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.isUser)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.attachmentUrl)
      ..writeByte(5)
      ..write(obj.attachmentType)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final int typeId = 13;

  @override
  MessageStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageStatus.sending;
      case 1:
        return MessageStatus.sent;
      case 2:
        return MessageStatus.delivered;
      case 3:
        return MessageStatus.error;
      default:
        return MessageStatus.sent;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    switch (obj) {
      case MessageStatus.sending:
        writer.writeByte(0);
        break;
      case MessageStatus.sent:
        writer.writeByte(1);
        break;
      case MessageStatus.delivered:
        writer.writeByte(2);
        break;
      case MessageStatus.error:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}



