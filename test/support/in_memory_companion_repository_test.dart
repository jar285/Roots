import 'package:roots/contracts/id_source.dart';

import '../contracts/companion_repository_contract.dart';
import 'in_memory_companion_repository.dart';

class _SequentialIdSource implements IdSource {
  int _next = 0;

  @override
  String nextId() => 'id-${++_next}';
}

void main() {
  runCompanionRepositoryContractTests(
    create: () async =>
        InMemoryCompanionRepository(idSource: _SequentialIdSource()),
  );
}
