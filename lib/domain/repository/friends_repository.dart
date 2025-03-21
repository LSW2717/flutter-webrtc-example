import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/collection_model.dart';
import '../../data/remote/friends/api/friends_api.dart';
import '../../data/remote/friends/model/friend_model.dart';
import '../converter/friend_converter.dart';
import '../ui_model/friend_ui_model.dart';

part 'friends_repository.g.dart';

@Riverpod(keepAlive: true)
FriendsRepository friendsRepository(Ref ref) {
  final friendsApi = ref.watch(friendsApiProvider);
  return FriendsRepository(friendsApi: friendsApi);
}

class FriendsRepository {
  final FriendsApi friendsApi;

  FriendsRepository({
    required this.friendsApi,
  });

  Future<CollectionModel<FriendsUiModel>> getAllFriends({
    required String userId,
    int? page,
  }) async {
    try {
      final friends = await friendsApi.search(
        body: FriendModel(userId: userId),
        page: page,
      );
      return FriendConverter.toUiModelList(friends);
    } catch (e) {
      print('getAllFriends 호출 중 에러 $e');
      rethrow;
    }
  }
}
