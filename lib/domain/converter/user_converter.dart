import '../../data/remote/users/model/user_model.dart';
import '../ui_model/user_ui_model.dart';

class UserConverter {
  static UserUiModel toUiModel(UserModel user) {
    return UserUiModel(
      userId: user.userId ?? "",
      userName: user.userName ?? "",
    );
  }
}
