import '../../data/remote/channels/model/channel_model.dart';
import '../ui_model/channel_ui_model.dart';

class ChannelConverter {
  static ChannelUiModel toUiModel(ChannelModel channel) {
    return ChannelUiModel(
      channelId: channel.channelId ?? "",
      channelOwner: channel.channelOwner ?? "",
      inviteUsers: channel.inviteUsers ?? [],
      channelName: channel.channelName ?? "",
      joinUsers: channel.joinUsers ?? [],
    );
  }
}
