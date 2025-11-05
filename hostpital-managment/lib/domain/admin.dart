import 'user.dart';


class Admin extends User {
  Admin({
    String? id,
    required String username,
    required String password,
  }) : super(
          id: id,
          username: username,
          password: password,
          type: UserType.admin,
        );
}