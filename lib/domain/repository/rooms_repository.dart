
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/collection_model.dart';
import '../../data/remote/channels/api/channels_api.dart';
import '../../data/remote/channels/model/channel_model.dart';
import '../../data/remote/rooms/api/rooms_api.dart';
import '../../data/remote/rooms/model/room_model.dart';
import '../converter/room_converter.dart';
import '../ui_model/friend_ui_model.dart';
import '../ui_model/room_ui_model.dart';

part 'rooms_repository.g.dart';

@Riverpod(keepAlive: true)
RoomsRepository roomsRepository(Ref ref) {
  final roomsApi = ref.watch(roomsApiProvider);
  final channelsApi = ref.watch(channelsApiProvider);
  return RoomsRepository(
    roomsApi: roomsApi,
    channelsApi: channelsApi,
  );
}

class RoomsRepository {
  final RoomsApi roomsApi;
  final ChannelsApi channelsApi;

  RoomsRepository({
    required this.roomsApi,
    required this.channelsApi,
  });

  Future<RoomUiModel> readRoom(String roomId) async {
    try {
      final room = await roomsApi.read(roomId);

      printPrettyJson(room.roomMembers);
      return RoomConverter.toUiModel(room);
    } catch (e) {
      print('readRoom 호출 중 에러 $e');
      rethrow;
    }
  }

  Future<CollectionModel<RoomsUiModel>> getAllRooms({
    required String userId,
    int? page,
  }) async {
    try {
      final rooms = await roomsApi.search(
        data: RoomModel(userId: userId),
        page: page,
      );
      return RoomConverter.toUiModelList(rooms);
    } catch (e) {
      print('getAllRooms 호출 중 에러 $e');
      rethrow;
    }
  }

  Future<RoomUiModel> createRoom({
    required List<FriendUiModel> friends,
    required String userId,
  }) async {
    try {
      List<String> inviteUsers = [];
      List<String> roomName = [];

      for (var friend in friends) {
        inviteUsers.add(friend.friend.userId);
        roomName.add(friend.friend.userName);
      }

      final channel = await channelsApi.search(
        body: ChannelModel(
          inviteUsers: inviteUsers,
          channelOwner: userId,
          channelName: roomName.toString(),
        ),
      );

      final res = channel.embedded.channels.firstOrNull;

      if (res == null) {
        return Future.error('채널이 없습니다.');
      }
      final roomId = '$userId-${res.channelId}';

      final room = await roomsApi.read(roomId);

      return RoomConverter.toUiModel(room);
    } catch (e) {
      print('createRoom 호출 중 에러 $e');
      rethrow;
    }
  }

}
