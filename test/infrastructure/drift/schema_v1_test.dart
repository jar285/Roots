import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roots/infrastructure/drift/companion_database.dart';

import 'generated/schema.dart';

/// Schema-fixture machinery from v1 (ADR 0003 #9). With only one schema
/// version this validates that the committed v1 snapshot and the runtime
/// schema agree; every future version adds a migration test from each older
/// fixture to the newest schema.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('a database created at schema v1 matches the runtime schema', () async {
    final connection = await verifier.startAt(1);
    final db = CompanionDatabase(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 1);
  });
}
