import 'package:flutter_test/flutter_test.dart';

import 'package:artistry_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email validator accepts valid emails', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('test.user@domain.co'), isNull);
    });

    test('email validator rejects invalid emails', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('password validator enforces rules', () {
      expect(Validators.password('Abcdefg1'), isNull);
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('nouppercase1'), isNotNull);
      expect(Validators.password('NoNumbers'), isNotNull);
      expect(Validators.password(null), isNotNull);
    });

    test('username validator enforces rules', () {
      expect(Validators.username('valid_user'), isNull);
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('has spaces'), isNotNull);
      expect(Validators.username(null), isNotNull);
    });
  });
}
