import 'package:flutter_test/flutter_test.dart';

import 'package:roots/infrastructure/uuid_id_source.dart';

void main() {
  group('UuidIdSource', () {
    test('produces RFC 4122 v4 ids', () {
      final id = UuidIdSource().nextId();

      expect(
        id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('does not repeat', () {
      final source = UuidIdSource();
      final ids = {for (var i = 0; i < 1000; i++) source.nextId()};

      expect(ids, hasLength(1000));
    });
  });
}
