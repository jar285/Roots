import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard for the architecture invariant (spec §5.1, ADR 0001): the domain
/// has no Flutter, Drift, IO, or rendering imports. This is a lint-style
/// guard, not a behavior test: it fails the moment a forbidden import lands.
void main() {
  final forbidden = RegExp(
    r'''import\s+['"](package:flutter/|package:flutter_riverpod/|'''
    r'''package:go_router/|package:drift|package:camera|'''
    r'''package:path_provider/|package:image/|dart:io|dart:ui|dart:html)''',
  );

  test('guard itself recognizes forbidden imports', () {
    expect(
      forbidden.hasMatch("import 'package:flutter/material.dart';"),
      isTrue,
    );
    expect(forbidden.hasMatch("import 'package:drift/drift.dart';"), isTrue);
    expect(forbidden.hasMatch('import "dart:io";'), isTrue);
    expect(forbidden.hasMatch("import 'dart:math';"), isFalse);
    expect(forbidden.hasMatch("import '../model/growth_delta.dart';"), isFalse);
  });

  test('lib/domain contains only pure Dart', () {
    final domainDir = Directory('lib/domain');
    expect(
      domainDir.existsSync(),
      isTrue,
      reason: 'domain directory must exist',
    );

    final violations = <String>[];
    final dartFiles = domainDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    var scanned = 0;
    for (final file in dartFiles) {
      scanned++;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (forbidden.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(scanned, greaterThan(0), reason: 'guard must scan real files');
    expect(
      violations,
      isEmpty,
      reason: 'domain purity violations:\n${violations.join('\n')}',
    );
  });
}
