import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../../hostpital-managment/lib/domain/user.dart';

void main(){
  group('test user model', (){
    test('user object is created correctly', 
    (){
      final user = User(username: 'lyming', password: '123', type: UserType.admin);

      expect(user.username, equals('lyming'));
      expect(user.password, equals('123'));
      expect(user.type, equals(UserType.admin));

    });

    test('2 users with different id are unique', (){
      final user1 = User(username: 'lyming', password: '123', type: UserType.admin);
      final user2 = User(username: 'reach', password: '123', type: UserType.patient);

      expect(user1.id != user2.id, isTrue);

    });

  });
}