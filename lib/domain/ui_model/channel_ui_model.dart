
import 'package:json_annotation/json_annotation.dart';

part 'channel_ui_model.g.dart';

@JsonSerializable()
class ChannelUiModel {
  final String channelId;
  final String channelOwner;
  final List<String> inviteUsers;
  final String channelName;
  final List<String> joinUsers;

  ChannelUiModel({
    required this.channelId,
    required this.channelOwner,
    required this.inviteUsers,
    required this.channelName,
    required this.joinUsers,
  });

  factory ChannelUiModel.fromJson(Map<String, dynamic> json) =>
      _$ChannelUiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelUiModelToJson(this);
}