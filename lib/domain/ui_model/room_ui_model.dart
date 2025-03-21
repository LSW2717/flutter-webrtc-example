
import 'package:json_annotation/json_annotation.dart';

import '../../data/remote/rooms/model/room_model.dart';
import 'channel_ui_model.dart';

part 'room_ui_model.g.dart';

@JsonSerializable()
class RoomUiModel {
  final String roomId;
  final String userId;
  final ChannelUiModel channel;
  final String roomType;
  final String roomNameRef;
  final String roomName;
  final List<RoomMemberUiModel> roomMembers;

  RoomUiModel({
    required this.roomId,
    required this.userId,
    required this.channel,
    required this.roomType,
    required this.roomNameRef,
    required this.roomName,
    required this.roomMembers,
  });

  factory RoomUiModel.fromJson(Map<String, dynamic> json) => _$RoomUiModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoomUiModelToJson(this);
}

@JsonSerializable()
class RoomsUiModel {
  final List<RoomUiModel> rooms;
  RoomsUiModel({
    required this.rooms,
  });

  factory RoomsUiModel.fromJson(Map<String, dynamic> json) => _$RoomsUiModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoomsUiModelToJson(this);
}

@JsonSerializable()
class RoomMemberUiModel {
  final RoomMemberType type;
  final String userId;
  final String userName;
  RoomMemberUiModel({
    required this.type,
    required this.userId,
    required this.userName,
  });

  factory RoomMemberUiModel.fromJson(Map<String, dynamic> json) => _$RoomMemberUiModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoomMemberUiModelToJson(this);

}