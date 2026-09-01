import 'package:uuid/uuid.dart';

import '../contracts/id_source.dart';

/// Production id source: RFC 4122 v4 UUIDs.
class UuidIdSource implements IdSource {
  const UuidIdSource();

  static const Uuid _uuid = Uuid();

  @override
  String nextId() => _uuid.v4();
}
