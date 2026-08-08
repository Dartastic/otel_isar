// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_isar/otel_isar.dart';

/// Isar exposes no per-query interceptor, so instrumentation wraps the
/// call site (or your data-layer methods). With a real Isar instance
/// each `invoke` closure below is the Isar call itself, e.g.
/// `() => isar.users.put(user)` or `() => isar.users.get(id)`.
Future<void> main() async {
  await OTel.initialize(
    serviceName: 'otel-isar-example',
    detectPlatformResources: false,
    spanProcessor: SimpleSpanProcessor(ConsoleExporter()),
  );

  // CLIENT span `isar put users` with db.system.name=isar,
  // db.operation.name=put, db.collection.name=users.
  // Real code: invoke: () => isar.users.put(user)
  final id = await tracedIsarCall<int>(
    operation: 'put',
    collection: 'users',
    invoke: () async => 1,
  );
  print('stored id $id');

  // One span around a whole write transaction.
  // Real code: isar.writeTxn(() async { ...multiple puts... })
  await tracedIsarWriteTxn<void>(() async {
    // puts/deletes inside the transaction
  });

  // Zone-scoped suppression: no spans emitted inside.
  await runWithoutIsarInstrumentationAsync(() async {
    await tracedIsarCall<void>(
      operation: 'get',
      collection: 'users',
      invoke: () async {},
    );
  });

  await OTel.shutdown();
}
