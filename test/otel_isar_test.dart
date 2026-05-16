// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_isar/otel_isar.dart';
import 'package:test/test.dart';

class _MemorySpanExporter implements SpanExporter {
  final List<Span> spans = [];
  bool _shutdown = false;

  @override
  Future<void> export(List<Span> s) async {
    if (_shutdown) return;
    spans.addAll(s);
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> shutdown() async {
    _shutdown = true;
  }
}

Map<String, Object> _attrs(Span span) =>
    {for (final a in span.attributes.toList()) a.key: a.value};

void main() {
  group('tracedIsarCall', () {
    late _MemorySpanExporter exporter;

    setUp(() async {
      await OTel.reset();
      exporter = _MemorySpanExporter();
      await OTel.initialize(
        serviceName: 'isar-otel-test',
        detectPlatformResources: false,
        spanProcessor: SimpleSpanProcessor(exporter),
      );
    });

    tearDown(() async {
      await OTel.shutdown();
      await OTel.reset();
    });

    test('emits CLIENT span with db.* + collection', () async {
      await tracedIsarCall<int>(
        operation: 'put',
        collection: 'users',
        invoke: () async => 1,
      );

      final span = exporter.spans.single;
      expect(span.kind, equals(SpanKind.client));
      expect(span.name, equals('isar put users'));
      final attrs = _attrs(span);
      expect(attrs['db.system'], equals('isar'));
      expect(attrs['db.operation'], equals('put'));
      expect(attrs['db.collection.name'], equals('users'));
    });

    test('write/read txn helpers emit correctly-named spans', () async {
      await tracedIsarWriteTxn<void>(() async {});
      await tracedIsarReadTxn<void>(() async {});
      final names = exporter.spans.map((s) => s.name).toList();
      expect(names, equals(['isar write_txn', 'isar read_txn']));
    });

    test('exception flips span to Error', () async {
      await expectLater(
        tracedIsarCall<void>(
          operation: 'put',
          collection: 'users',
          invoke: () async => throw StateError('locked'),
        ),
        throwsStateError,
      );
      expect(exporter.spans.single.status, equals(SpanStatusCode.Error));
    });

    test('runWithoutIsarInstrumentationAsync bypasses spans', () async {
      await runWithoutIsarInstrumentationAsync(() async {
        await tracedIsarCall<int>(
          operation: 'put',
          collection: 'users',
          invoke: () async => 1,
        );
      });
      expect(exporter.spans, isEmpty);
    });
  });
}
